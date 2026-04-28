#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <time.h>

// --- WiFi & Firebase Credentials ---
#define WIFI_SSID "Aqua Sentinel"
#define WIFI_PASSWORD "openhouse2026"
#define FIREBASE_HOST "aqua-sentinel-90685-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "BvBwZ6gQmV0XYxWZwVSgkocAfgiTbsFBz0tzIjHy"

// --- Pin Definitions ---
const int sensor1Pin    = 27;   // INLET  (S1)
const int sensor2Pin    = 14;   // OUTLET (S2)
const int buzzerPin     = 26;
const int pumpRelayPin  = 25;
const int pumpButtonPin = 13;
#define ONBOARD_LED    2
#define PH_PIN         34
#define TDS_PIN        32
#define TURBIDITY_PIN  33

// --- OLED ---
Adafruit_SH1106G display = Adafruit_SH1106G(128, 64, &Wire, -1);

// --- Sensor Calibration ---
const float PULSES_PER_LITER = 413.0;
#define ADC_RES 4095.0
#define VREF    3.3
float ph_offset = 22.25, ph_slope = -5.70;
float temperature = 25.0, tds_factor = 0.5;
const float CLEAR_WATER_ADC = 2717.6, ADC_PER_NTU = -18.189;

// --- Shared State ---
volatile unsigned long totalPulses1 = 0, totalPulses2 = 0;
bool   isPumpOn     = false;
bool   leakDetected = false;
float  flow1 = 0, flow2 = 0, vol2 = 0;
float  totalWasted  = 0.0;
bool   wifiEnabled  = false;

// -------------------------------------------------------
// ISRs — IRAM only, touch nothing except counters
// -------------------------------------------------------
void IRAM_ATTR increase1() { totalPulses1++; }
void IRAM_ATTR increase2() { totalPulses2++; }

// -------------------------------------------------------
// Analog sensor helpers
// -------------------------------------------------------
float getPH() {
  long a = 0;
  for (int i = 0; i < 10; i++) a += analogRead(PH_PIN);
  return constrain(((a / 10.0) * (VREF / ADC_RES)) * ph_slope + ph_offset, 0.0, 14.0);
}
float getTDS() {
  float a = 0;
  for (int i = 0; i < 10; i++) a += analogRead(TDS_PIN);
  float v = (a / 10.0) * (VREF / ADC_RES) / (1.0 + 0.02 * (temperature - 25.0));
  return constrain((133.42 * pow(v, 3) - 255.86 * pow(v, 2) + 857.39 * v) * tds_factor, 0.0, 50000.0);
}
float getTurbidity() {
  float a = 0;
  for (int i = 0; i < 20; i++) a += analogRead(TURBIDITY_PIN);
  float k = constrain((a / 20.0 - CLEAR_WATER_ADC) / ADC_PER_NTU, 0.0, 150.0);
  return constrain((k * 10.0) / 150.0, 0.0, 10.0);
}

// -------------------------------------------------------
// ONLINE MODE globals
// -------------------------------------------------------
FirebaseData   fbData, streamData;
FirebaseConfig config;
FirebaseAuth   auth;
bool   streamActive = false;
unsigned long lastFB = 0;
String lastLeakTime = "None";

void streamCallback(StreamData data) {
  if (data.dataType() == "boolean") {
    bool newState = data.boolData();
    if (newState && !isPumpOn) {
      // Pump just turned ON via Firebase — pumpStart handled in loopOnline
    }
    isPumpOn = newState;
    digitalWrite(pumpRelayPin, isPumpOn ? LOW : HIGH);
  }
}

void handleLED_online() {
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(ONBOARD_LED, (millis() / 100) % 2);
  } else if (!streamActive) {
    digitalWrite(ONBOARD_LED, (millis() / 200) % 2);
  } else if (millis() - lastFB < 1000) {
    digitalWrite(ONBOARD_LED, (millis() / 1000) % 2);
  } else {
    digitalWrite(ONBOARD_LED, HIGH);
  }
}

// -------------------------------------------------------
// ONLINE LOOP
// Original logic preserved. getLocalTime() works because
// NTP was synced during setup().
// -------------------------------------------------------
void loopOnline() {
  unsigned long currentMillis = millis();
  handleLED_online();

  // Non-blocking buzzer
  static unsigned long buzzerMillisO = 0;
  static bool buzzerStateO = LOW;
  if (leakDetected) {
    if (currentMillis - buzzerMillisO >= 200) {
      buzzerMillisO = currentMillis;
      buzzerStateO  = !buzzerStateO;
      digitalWrite(buzzerPin, buzzerStateO);
    }
  } else {
    buzzerStateO = LOW;
    digitalWrite(buzzerPin, LOW);
  }

  // Button + track pump ON transitions for pumpStart
  static bool lastBO       = HIGH;
  static bool prevPumpOn   = false;
  static unsigned long pumpStartO = 0;
  bool b = digitalRead(pumpButtonPin);
  if (b == LOW && lastBO == HIGH) {
    isPumpOn = !isPumpOn;
    digitalWrite(pumpRelayPin, isPumpOn ? LOW : HIGH);
    Firebase.setBool(fbData, "/sensors/pump", isPumpOn);
    delay(200);
  }
  lastBO = b;
  if (isPumpOn && !prevPumpOn) pumpStartO = currentMillis;  // rising edge
  prevPumpOn = isPumpOn;

  // 1-second tick
  static unsigned long prevMO  = 0;
  static unsigned long prevP1O = 0, prevP2O = 0;
  if (currentMillis - prevMO >= 1000) {
    prevMO = currentMillis;

    noInterrupts();
    unsigned long c1 = totalPulses1;
    unsigned long c2 = totalPulses2;
    interrupts();

    flow1 = ((c1 - prevP1O) / PULSES_PER_LITER) * 60000.0;
    flow2 = ((c2 - prevP2O) / PULSES_PER_LITER) * 60000.0;
    prevP1O = c1;
    prevP2O = c2;
    vol2 = (c2 / PULSES_PER_LITER) * 1000.0;

    leakDetected = false;
    if (isPumpOn && (currentMillis - pumpStartO >= 3000)) {
      if (flow1 > 100.0 && flow2 < (flow1 * 0.85)) {
        leakDetected = true;
        totalWasted += (flow1 - flow2) / 60.0;
        struct tm ti;
        if (getLocalTime(&ti)) {  // safe: NTP synced
          char buf[20];
          strftime(buf, 20, "%H:%M:%S", &ti);
          lastLeakTime = String(buf);
        }
      }
    }

    display.clearDisplay();
    display.setCursor(26, 0);  display.println("Aqua Sentinel");
    display.drawLine(0, 9, 128, 9, SH110X_WHITE);
    display.setCursor(0, 14);
    display.printf("PH:%.1f TDS:%d TB:%.1f", getPH(), (int)getTDS(), getTurbidity());
    display.setCursor(0, 28);
    display.printf("In:%.0f Out:%.0f mL/m", flow1, flow2);
    display.setCursor(0, 42);
    display.printf("Total Vol: %.0f mL", vol2);
    display.setCursor(0, 56);
    if (leakDetected) display.printf("LEAK! Wasted:%.0f mL", totalWasted);
    else display.println(isPumpOn ? "STATUS: PUMP RUNNING" : "STATUS: PUMP OFF");
    display.display();
  }

  // Firebase push every 5 seconds
  if (currentMillis - lastFB >= 5000) {
    lastFB = currentMillis;
    FirebaseJson j;
    j.set("flow_sensor_1", flow1);  j.set("flow_sensor_2", flow2);
    j.set("ph", getPH());           j.set("tds", getTDS());
    j.set("turbidity", getTurbidity());
    j.set("total_volume", vol2);    j.set("total_leaked", totalWasted);
    j.set("leak_status", leakDetected);
    j.set("leak_timestamp", lastLeakTime);
    Firebase.updateNode(fbData, "/sensors", j);
  }
}

// -------------------------------------------------------
// LOCAL LOOP
// Completely isolated — zero WiFi, zero Firebase,
// zero getLocalTime(). This is what was blocking before.
// Modelled directly on the proven working local code.
// -------------------------------------------------------
void loopLocal() {
  unsigned long currentMillis = millis();

  digitalWrite(ONBOARD_LED, LOW);

  // Non-blocking buzzer
  static unsigned long buzzerMillisL = 0;
  static bool buzzerStateL = LOW;
  if (leakDetected) {
    if (currentMillis - buzzerMillisL >= 200) {
      buzzerMillisL = currentMillis;
      buzzerStateL  = !buzzerStateL;
      digitalWrite(buzzerPin, buzzerStateL);
    }
  } else {
    buzzerStateL = LOW;
    digitalWrite(buzzerPin, LOW);
  }

  // Button
  static bool lastBL = HIGH;
  static unsigned long pumpStartL = 0;
  bool b = digitalRead(pumpButtonPin);
  if (b == LOW && lastBL == HIGH) {
    isPumpOn = !isPumpOn;
    digitalWrite(pumpRelayPin, isPumpOn ? LOW : HIGH);
    if (isPumpOn) pumpStartL = currentMillis;
    delay(200);
  }
  lastBL = b;

  // 1-second tick
  static unsigned long prevML  = 0;
  static unsigned long prevP1L = 0, prevP2L = 0;
  if (currentMillis - prevML >= 1000) {
    prevML = currentMillis;

    noInterrupts();
    unsigned long c1 = totalPulses1;
    unsigned long c2 = totalPulses2;
    interrupts();

    unsigned long pulses1 = c1 - prevP1L;
    unsigned long pulses2 = c2 - prevP2L;
    prevP1L = c1;
    prevP2L = c2;

    // Exact formula from working local code
    flow1 = ((pulses1 / PULSES_PER_LITER) * 60.0) * 1000.0;
    flow2 = ((pulses2 / PULSES_PER_LITER) * 60.0) * 1000.0;
    vol2  = (c2 / PULSES_PER_LITER) * 1000.0;

    // Leak detection — NO getLocalTime(), that was the root cause of blocking
    leakDetected = false;
    if (isPumpOn && (currentMillis - pumpStartL >= 3000)) {
      if (flow1 > 100.0 && flow2 < (flow1 * 0.85)) {
        leakDetected = true;
        float wastedThisSec = (flow1 - flow2) / 60.0;
        if (wastedThisSec > 0) totalWasted += wastedThisSec;
      }
    }

    display.clearDisplay();
    display.setCursor(26, 0);  display.println("Aqua Sentinel");
    display.drawLine(0, 9, 128, 9, SH110X_WHITE);
    display.setCursor(0, 14);
    display.printf("PH:%.1f TDS:%d TB:%.1f", getPH(), (int)getTDS(), getTurbidity());
    display.setCursor(0, 28);
    display.printf("In:%.0f Out:%.0f mL/m", flow1, flow2);
    display.setCursor(0, 42);
    display.printf("Total Vol: %.0f mL", vol2);
    display.setCursor(0, 56);
    if (leakDetected) display.printf("LEAK! Wasted:%.0f mL", totalWasted);
    else display.println(isPumpOn ? "STATUS: PUMP RUNNING" : "STATUS: PUMP OFF");
    display.display();
  }
}

// -------------------------------------------------------
// SETUP
// -------------------------------------------------------
void setup() {
  Serial.begin(115200);

  pinMode(sensor1Pin,    INPUT_PULLUP);
  pinMode(sensor2Pin,    INPUT_PULLUP);
  pinMode(pumpButtonPin, INPUT_PULLUP);
  pinMode(pumpRelayPin,  OUTPUT);
  pinMode(buzzerPin,     OUTPUT);
  pinMode(ONBOARD_LED,   OUTPUT);

  digitalWrite(pumpRelayPin, HIGH);
  digitalWrite(buzzerPin,    LOW);
  analogSetAttenuation(ADC_11db);

  attachInterrupt(digitalPinToInterrupt(sensor1Pin), increase1, RISING);
  attachInterrupt(digitalPinToInterrupt(sensor2Pin), increase2, RISING);

  display.begin(0x3c, true);
  display.clearDisplay();
  display.setTextColor(SH110X_WHITE);
  display.setTextSize(1);

  // WiFi with 20-second countdown
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  unsigned long wifiStart = millis();
  const unsigned long WIFI_TIMEOUT_MS = 60000;
  int lastCountdown = -1;

  while (WiFi.status() != WL_CONNECTED) {
    unsigned long elapsed = millis() - wifiStart;
    if (elapsed >= WIFI_TIMEOUT_MS) break;

    int countdown = (int)((WIFI_TIMEOUT_MS - elapsed) / 1000) + 1;
    if (countdown != lastCountdown) {
      lastCountdown = countdown;
      display.clearDisplay();
      display.setCursor(25, 10); display.println("Aqua Sentinel");
      display.drawLine(0, 20, 128, 20, SH110X_WHITE);
      display.setCursor(10, 28); display.println("Connecting WiFi...");
      int cdX = (countdown >= 10) ? 46 : 52;
      display.setCursor(cdX, 40); display.setTextSize(2);
      display.print(countdown); display.println("s");
      display.setTextSize(1);
      display.display();
    }
    digitalWrite(ONBOARD_LED, (millis() / 100) % 2);
    delay(10);
  }

  if (WiFi.status() == WL_CONNECTED) {
    wifiEnabled = true;

    display.clearDisplay();
    display.setCursor(25, 10); display.println("Aqua Sentinel");
    display.drawLine(0, 20, 128, 20, SH110X_WHITE);
    display.setCursor(19, 32); display.println("WiFi Connected!");
    display.setCursor(10, 44); display.println("Starting Stream...");
    display.display();

    configTime(18000, 0, "pool.ntp.org");

    config.host = FIREBASE_HOST;
    config.signer.tokens.legacy_token = FIREBASE_AUTH;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    if (Firebase.beginStream(streamData, "/sensors/pump")) {
      Firebase.setStreamCallback(streamData, streamCallback, [](bool t) {});
      streamActive = true;
    }

    display.clearDisplay();
    display.setCursor(25, 10); display.println("Aqua Sentinel");
    display.drawLine(0, 20, 128, 20, SH110X_WHITE);
    display.setCursor(28, 35); display.println("SYSTEM READY");
    display.display();
    delay(1500);

  } else {
    WiFi.disconnect(true);
    WiFi.mode(WIFI_OFF);
    btStop();

    display.clearDisplay();
    display.setCursor(25, 10); display.println("Aqua Sentinel");
    display.drawLine(0, 20, 128, 20, SH110X_WHITE);
    display.setCursor(28, 30); display.println("WiFi Failed!");
    display.setCursor(10, 44); display.println("Running LOCAL mode");
    display.display();
    delay(2000);

    display.clearDisplay();
    display.setCursor(25, 10); display.println("Aqua Sentinel");
    display.drawLine(0, 20, 128, 20, SH110X_WHITE);
    display.setCursor(28, 32); display.println("SYSTEM READY");
    display.setCursor(28, 46); display.println("(Local Only)");
    display.display();
    delay(1500);
  }
}

// -------------------------------------------------------
// LOOP
// -------------------------------------------------------
void loop() {
  if (wifiEnabled) {
    loopOnline();
  } else {
    loopLocal();
  }
}
