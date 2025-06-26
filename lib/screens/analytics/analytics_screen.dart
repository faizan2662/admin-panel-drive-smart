import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedTimeRange = 'Last 30 days';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildUserDistributionChart(),
            const SizedBox(height: 24),
            _buildGrowthTrendCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Analytics & Reports',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTimeRange,
                  items: const [
                    DropdownMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
                    DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
                    DropdownMenuItem(value: 'Last 90 days', child: Text('Last 90 days')),
                    DropdownMenuItem(value: 'Last year', child: Text('Last year')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTimeRange = value!;
                    });
                  },
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              // child: ElevatedButton.icon(
              //   onPressed: () {},
              //   icon: const Icon(Icons.download, size: 18),
              //   label: const Text('Export'),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.transparent,
              //     shadowColor: Colors.transparent,
              //     foregroundColor: Colors.white,
              //   ),
              // ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        return Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Users',
                '${stats['totalUsers'] ?? 0}',
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Trainers',
                '${stats['totalTrainers'] ?? 0}',
                Icons.school,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Trainees',
                '${stats['totalTrainees'] ?? 0}',
                Icons.person,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOverviewCard(
                'Organizations',
                '${stats['totalOrganizations'] ?? 0}',
                Icons.business,
                Colors.purple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDistributionChart() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        final totalUsers = stats['totalUsers'] ?? 0;
        final trainers = stats['totalTrainers'] ?? 0;
        final trainees = stats['totalTrainees'] ?? 0;
        final organizations = stats['totalOrganizations'] ?? 0;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildSimpleBarChart(trainers, trainees, organizations, totalUsers),
                          const SizedBox(height: 20),
                          _buildChartLegend(trainers, trainees, organizations),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildDistributionStats(trainers, trainees, organizations, totalUsers),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleBarChart(int trainers, int trainees, int organizations, int total) {
    final maxValue = [trainers, trainees, organizations].reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar('Trainers', trainers, maxValue, Colors.green),
          _buildBar('Trainees', trainees, maxValue, Colors.orange),
          _buildBar('Organizations', organizations, maxValue, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, int maxValue, Color color) {
    final height = maxValue > 0 ? (value / maxValue) * 150 : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(int trainers, int trainees, int organizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Trainers', trainers, Colors.green),
        _buildLegendItem('Trainees', trainees, Colors.orange),
        _buildLegendItem('Organizations', organizations, Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionStats(int trainers, int trainees, int organizations, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatItem('Trainers', trainers, total, Colors.green),
        const SizedBox(height: 12),
        _buildStatItem('Trainees', trainees, total, Colors.orange),
        const SizedBox(height: 12),
        _buildStatItem('Organizations', organizations, total, Colors.purple),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total > 0 ? value / total : 0,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildGrowthTrendCharts() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Trends (Last 12 Months)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildTrendChart(
              'Trainer Growth Trends',
              Colors.green,
              Icons.school,
              provider.getTrainerGrowthData(),
            ),
            const SizedBox(height: 24),
            _buildTrendChart(
              'Trainee Growth Trends',
              Colors.orange,
              Icons.person,
              provider.getTraineeGrowthData(),
            ),
            const SizedBox(height: 24),
            _buildTrendChart(
              'Organization Growth Trends',
              Colors.purple,
              Icons.business,
              provider.getOrganizationGrowthData(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendChart(String title, Color color, IconData icon, List<double> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Y-axis labels
                Container(
                  width: 40,
                  height: 200,
                  child: _buildYAxisLabels(data),
                ),
                // Chart area
                Expanded(
                  child: Container(
                    height: 200,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: LineChartPainter(data, color),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: _buildMonthLabels(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYAxisLabels(List<double> data) {
    if (data.isEmpty) return Container();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);

    // Create 5 evenly spaced labels
    final labels = <String>[];
    for (int i = 4; i >= 0; i--) {
      final value = minValue + (maxValue - minValue) * (i / 4);
      labels.add(value.round().toString());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: labels.map((label) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildMonthLabels() {
    const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: months.map((month) => Text(
        month,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      )).toList(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LineChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw vertical grid lines
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = range > 0
          ? size.height - ((data[i] - minValue) / range) * size.height
          : size.height / 2;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 4, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
