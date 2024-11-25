import 'package:ase_project/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Daily Points Chart
              Text(
                'Daily Points',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 200, child: DailyPointsChart()),
              Text('Blue Line: Daily Points Earned', style: TextStyle(fontSize: 12)),
              SizedBox(height: 24),

              // Accumulated Points Chart
              Text(
                'Accumulated Points',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 200, child: AccumulatedPointsChart()),
              Text('Green Line: Total Points Accumulated Over Time', style: TextStyle(fontSize: 12)),
              SizedBox(height: 24),

              // Weekly View Chart
              Text(
                'Weekly Points',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 200, child: WeeklyViewChart()),
              Text('Orange Bars: Points Earned Each Week', style: TextStyle(fontSize: 12)),
              SizedBox(height: 24),

              // Monthly View Chart
              Text(
                'Monthly Points',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 200, child: MonthlyViewChart()),
              Text('Purple Bars: Points Earned Each Month', style: TextStyle(fontSize: 12)),
              SizedBox(height: 24),

              // Comparison Chart
              Text(
                'Comparison',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 200, child: ComparisonChart()),
              Text('Red Line: Data Set 1 | Blue Line: Data Set 2', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// Example chart widgets. Replace with actual implementations.
class DailyPointsChart extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: taskService.getDailyPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final spots = data.entries
            .toList()
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value.toDouble()))
            .toList();

        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
                barWidth: 4,
                isStrokeCapRound: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccumulatedPointsChart extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: taskService.getAccumulatedPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final spots = data
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value['points'].toDouble()))
            .toList();

        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                barWidth: 4,
                isStrokeCapRound: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeeklyViewChart extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: taskService.getWeeklyPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final bars = data.entries
            .map((entry) => BarChartGroupData(
                x: entry.key,
                barRods: [BarChartRodData(toY: entry.value.toDouble(), gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]))]))
            .toList();

        return BarChart(BarChartData(barGroups: bars));
      },
    );
  }
}

class MonthlyViewChart extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: taskService.getMonthlyPoints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final bars = data.entries
            .map((entry) => BarChartGroupData(
                x: entry.key,
                barRods: [BarChartRodData(toY: entry.value.toDouble(), gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]))]))
            .toList();

        return BarChart(BarChartData(barGroups: bars));
      },
    );
  }
}

class ComparisonChart extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: taskService.getComparisonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Vérifiez les données reçues
        final data = snapshot.data ?? {};
        final beforeDueDate = data['completedBeforeDueDate'] ?? 0;
        final afterDueDate = data['completedAfterDueDate'] ?? 0;

        // Ajout de logs pour débogage
        print('Before Due: $beforeDueDate');
        print('After Due: $afterDueDate');

        if (beforeDueDate == 0 && afterDueDate == 0) {
          return Center(child: Text('No data available.'));
        }

        return BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: beforeDueDate.toDouble(),
                    gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                    width: 16, // Assurez-vous que la largeur est définie
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: afterDueDate.toDouble(),
                    gradient: LinearGradient(colors: [Colors.red, Colors.deepOrange]),
                    width: 16, // Assurez-vous que la largeur est définie
                  ),
                ],
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Ajustez la taille réservée pour plus de clarté
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return Text('Before Due', style: TextStyle(fontSize: 12));
                      case 1:
                        return Text('After Due', style: TextStyle(fontSize: 12));
                      default:
                        return Text('');
                    }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            gridData: FlGridData(show: false), // Désactive les lignes de grille pour plus de clarté
            minY: 0, // Fixez la valeur minimale pour l'axe Y
            maxY: (beforeDueDate > afterDueDate ? beforeDueDate : afterDueDate).toDouble() + 5, // Ajoutez un padding
          ),
        );
      },
    );
  }
}