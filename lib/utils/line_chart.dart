import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- Data Structure ---
class WaterUsageData {
  final int month;
  final double usage;
  WaterUsageData(this.month, this.usage);
}

// --- Sample Data ---
final List<WaterUsageData> _sampleData = [
  WaterUsageData(0, 0),
  WaterUsageData(1, 40),
  WaterUsageData(2, 10),
  WaterUsageData(3, 30),
  WaterUsageData(4, 20),
  WaterUsageData(5, 50),
  WaterUsageData(6, 40),
  WaterUsageData(7, 60),
  WaterUsageData(8, 20),
];

// --- Chart Widget ---
class WaterUsageChart extends StatelessWidget {
  const WaterUsageChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // This padding will give space around the chart
      // and allow the AspectRatio to fill the available horizontal space.
      padding: const EdgeInsets.all(0),
      child: AspectRatio(
        aspectRatio: 2.0, // Adjust this ratio to control the chart's shape
        child: LineChart(mainData()),
      ),
    );
  }

  // Define the main chart data configuration
  LineChartData mainData() {
    return LineChartData(
      //Remove Border
      borderData: FlBorderData(
        show: false, // This hides the border
      ),

      // --- REMOVE GRID LINES ---
      gridData: const FlGridData(
        show: false, // Set to false to hide all grid lines
      ),

      // --- REMOVE ALL AXIS TITLES/LABELS ---
      titlesData: const FlTitlesData(
        show: false, // Set to false to hide all axis titles (numbers/labels)
      ),

      // Remove any default touch functionality if you want a static graph
      lineTouchData: const LineTouchData(enabled: false),

      // --- Axis Limits (Adjust these based on your data range) ---
      minX: 0,
      maxX: 8, // From month 0 to 9
      minY: 0,
      maxY: 70, // Max usage is 60, so set a little higher for visual comfort
      // --- Line and Area Configuration ---
      lineBarsData: [
        LineChartBarData(
          spots: _sampleData
              .map((data) => FlSpot(data.month.toDouble(), data.usage))
              .toList(),
          isCurved:
              false, // Set to true for a smoother curve, like your original image
          // Line Styling (The blue line)
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ), // Hide the individual data dots
          // Area Styling (The shaded effect)
          belowBarData: BarAreaData(
            show: true,
            // Using a gradient for a smoother transition from dark to light blue
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(
                  0.8,
                ), // Darker blue at the top of the area
                Colors.blue.withOpacity(
                  0.1,
                ), // Lighter blue at the bottom of the area
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
