import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/utils/circular_progress_bar.dart';
import 'package:aqua_sentinel/utils/line_chart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../apivariables.dart';
import 'package:aqua_sentinel/sensor_data.dart';

final String _geminiApiKey = YOUR_GEMINI_API_KEY;

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String? generatedMessage;
  String? tip;
  late bool _isLoading;
  late bool _isLoadingQuality;

  final double monthlyGoal = 1412;

  // Debounce: wait 15 s of no new updates before calling Gemini
  static const Duration _debounceDuration = Duration(seconds: 15);
  // Only call if totalVolume changed by at least this many litres since last call
  static const double _significantChangeLiters = 5.0;

  Timer? _debounceTimer;
  // totalVolume at the time of the last successful Gemini call.
  // -1 means Gemini has never been called this session.
  double _lastGeminiVolume = -1;

  @override
  void initState() {
    super.initState();
    // Restore cached state so we don't show loading again
    _isLoadingQuality = !sensorData.hasData;
    _isLoading = sensorData.geminiMessage == null;
    generatedMessage = sensorData.geminiMessage;
    tip = sensorData.geminiTip;

    // If we already have a cached insight, mark volume as "seen" so we
    // don't re-call just because the app restarted.
    if (sensorData.geminiMessage != null) {
      _lastGeminiVolume = sensorData.totalVolume;
    }

    sensorData.notifier.addListener(_onSensorUpdate);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    sensorData.notifier.removeListener(_onSensorUpdate);
    super.dispose();
  }

  void _onSensorUpdate() {
    setState(() {
      _isLoadingQuality = false;
    });
    _scheduleGeminiIfNeeded();
  }

  /// Resets the debounce window on every sensor update.
  /// After 15 s of silence, fires Gemini only if there was a significant
  /// change in totalVolume since the last call.
  void _scheduleGeminiIfNeeded() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      final vol = sensorData.totalVolume;
      final change = (vol - _lastGeminiVolume).abs();
      final neverCalled = _lastGeminiVolume < 0;
      if (neverCalled || change >= _significantChangeLiters) {
        _fetchGeminiInsight();
      }
    });
  }

  /// Calls the Gemini API immediately. Cancels any pending debounce timer so
  /// a manual refresh doesn't race with a scheduled call.
  Future<void> _fetchGeminiInsight() async {
    _debounceTimer?.cancel();
    // Snapshot the volume we're generating an insight for.
    final volumeAtCall = sensorData.totalVolume;

    final usagePercent = monthlyGoal > 0
        ? (volumeAtCall / monthlyGoal * 100).clamp(0, 100)
        : 0;

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
      );

      final prompt =
          '''Analyze the following water usage data for a user and provide a personalized sustainability message and a water-saving pro tip.

Water Usage Data:
- Current Month Usage: ${volumeAtCall.toStringAsFixed(1)}L (${usagePercent.toStringAsFixed(0)}% of monthly goal of ${monthlyGoal.toInt()}L)
- Water Quality Status: ${sensorData.status}
- pH Level: ${sensorData.ph.toStringAsFixed(2)}
- TDS: ${sensorData.tds.toStringAsFixed(2)} ppm
- Turbidity: ${sensorData.turbidity.toStringAsFixed(2)} NTU
- Total Volume Recorded: ${volumeAtCall.toStringAsFixed(1)}L

Respond ONLY in valid JSON format with exactly two fields:
{
  "message": "A short personalized encouraging message (2-3 sentences) about their water usage and sustainability habits",
  "tip": "A single actionable pro tip to help save water"
}''';

      final response = await model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = responseText.substring(jsonStart, jsonEnd);
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        setState(() {
          generatedMessage = parsed['message'] as String?;
          tip = parsed['tip'] as String?;
          sensorData.geminiMessage = generatedMessage;
          sensorData.geminiTip = tip;
          _lastGeminiVolume = volumeAtCall;
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format from Gemini');
      }
    } catch (e) {
      debugPrint('Error fetching Gemini insight: $e');
      setState(() {
        generatedMessage =
            'Unable to load personalized insights right now. Keep tracking your usage to stay on top of your sustainability goals!';
        tip =
            'Turn off the tap while brushing your teeth to save up to 8 gallons of water per day.';
        // Record volume so a transient error doesn't cause immediate retries
        _lastGeminiVolume = volumeAtCall;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // var user = sensorData.userName;
    final isHealthy = sensorData.status == 'Healthy';
    final statusColor = isHealthy
        ? const Color.fromARGB(255, 43, 153, 47)
        : Colors.red;
    final usagePercent = monthlyGoal > 0
        ? (sensorData.totalVolume / monthlyGoal * 100).clamp(0, 100)
        : 0.0;
    final usageFraction = (sensorData.totalVolume / monthlyGoal).clamp(
      0.0,
      1.0,
    );

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _fetchGeminiInsight,
        color: Colors.blue,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsGeometry.symmetric(horizontal: 22, vertical: 20),
        children: [
          Container(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(18),
            ),
            child: _isLoadingQuality
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Status: ${sensorData.status}",
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isHealthy ? "Excellent!" : "Caution!",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        isHealthy
                            ? "Your water quality is within the optimal range for consumption and daily use. No contaminants detected."
                            : "Your water quality is outside the safe range. Avoid consuming this water without treatment.",
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                "pH",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(sensorData.ph.toStringAsFixed(2)),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "TDS",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("${sensorData.tds.toStringAsFixed(2)} ppm"),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Turbidity",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${sensorData.turbidity.toStringAsFixed(2)} NTU",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 20),

          //gemini api
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFE3F2FD), const Color(0xFFF0F7FF)],
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Icon
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.blue,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Great job, ${sensorData.userName}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Main Content Text
                      Text(generatedMessage ?? ''),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.black12, thickness: 1),
                      const SizedBox(height: 16),
                      // Pro Tip Section
                      Text(
                        'PRO TIP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 20),

          //water usage
          Container(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'This Month\'s Usage',
                      style: kCardHeadingTextStyle.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text("Maximum Monthly Goal: ${monthlyGoal.toInt()}L"),
                SizedBox(height: 20),
                CircularProgressDisplay(
                  value: usageFraction.toDouble(),
                  label: '${sensorData.totalVolume.toStringAsFixed(0)}L',
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You\'ve used ${usagePercent.toStringAsFixed(0)}% of your monthly goal.',
                      style: kCardHeadingTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          //past months usage
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 15),
                  Text(
                    'Past Months Usage',
                    style: kWaterFlowTextStyle.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsetsGeometry.only(
                  top: 20,
                  left: 18,
                  right: 18,
                  bottom: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Usage',
                          style: kCardHeadingTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Recent Readings',
                          style: kCardHeadingTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${sensorData.totalVolume.toStringAsFixed(1)} L',
                          style: kWaterFlowTextStyle.copyWith(fontSize: 21),
                        ),
                      ],
                    ),
                    WaterUsageChart(data: sensorData.flowHistory),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}
