import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aqua_sentinel/constants/constants.dart';
import 'package:aqua_sentinel/utils/circular_progress_bar.dart';
import 'package:aqua_sentinel/utils/line_chart.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../apivariables.dart';

final String _geminiApiKey =
    YOUR_GEMINI_API_KEY; // Replace with your Gemini API key

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String? status = 'Healthy';
  double? ph = 7.2, tds = 115, turbidity = 0.4;

  String? generatedMessage;
  String? tip;
  bool _isLoading = true;

  // Water usage data
  final double currentMonthUsage = 1200;
  final double monthlyGoal = 1412;
  final double usagePercent = 85;
  final double pastMonthsTotal = 7500;

  @override
  void initState() {
    super.initState();
    _fetchGeminiInsight();
  }

  Future<void> _fetchGeminiInsight() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
      );

      final prompt =
          '''Analyze the following water usage data for a user and provide a personalized sustainability message and a water-saving pro tip.

Water Usage Data:
- Current Month Usage: ${currentMonthUsage}L ($usagePercent% of monthly goal of ${monthlyGoal}L)
- Water Quality Status: $status
- pH Level: $ph
- TDS: $tds ppm
- Turbidity: $turbidity NTU
- Past 9 Months Total Usage: ${pastMonthsTotal}L

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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = 'Nikhil';

    return Expanded(
      child: ListView(
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
            child:
                //water quality
                Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status: $status",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 43, 153, 47),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Excellent!",
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
                      "Your water quality is within the optimal range for consumption and daily use. No contaminants detected.",
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
                            Text("$ph"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "TDS",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("$tds ppm"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Turbidity",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("$turbidity NTU"),
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
                            'Great job, $user!',
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
                SizedBox(height: 20),
                CircularProgressDisplay(value: 0.50, label: '1200L'),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You\'ve used 85% of your monthly goal.',
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
                          'Last 9 Months',
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
                          '7500 L',
                          style: kWaterFlowTextStyle.copyWith(fontSize: 21),
                        ),
                      ],
                    ),
                    WaterUsageChart(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
