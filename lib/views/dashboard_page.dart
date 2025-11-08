import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/todo_controller.dart';
import '../models/todo.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoController controller = Get.find<TodoController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.shade200,
        surfaceTintColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.status == LoadingState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.totalTodos == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Data Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create some todos to see your statistics',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Todos',
                      value: controller.totalTodos.toString(),
                      icon: Icons.list_alt,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Completed',
                      value: controller.completedTodos.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Pending',
                      value: controller.pendingTodos.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Completion Rate',
                      value:
                          '${controller.completionPercentage.toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Completion Progress Chart
              ChartCard(
                title: 'Completion Progress',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: controller.completedTodos.toDouble(),
                          title: 'Completed\n${controller.completedTodos}',
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: controller.pendingTodos.toDouble(),
                          title: 'Pending\n${controller.pendingTodos}',
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Priority Distribution Chart
              ChartCard(
                title: 'Priority Distribution',
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: controller.todosByPriority.values.isNotEmpty
                          ? controller.todosByPriority.values
                                  .reduce((a, b) => a > b ? a : b)
                                  .toDouble() +
                              1
                          : 1,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final priorities = TodoPriority.values;
                              if (value.toInt() >= 0 &&
                                  value.toInt() < priorities.length) {
                                return Text(
                                  priorities[value.toInt()].label,
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          TodoPriority.values.asMap().entries.map((entry) {
                        final priority = entry.value;
                        final count = controller.todosByPriority[priority] ?? 0;
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: count.toDouble(),
                              color: _getPriorityColor(priority),
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Weekly Completion Trend
              ChartCard(
                title: 'Weekly Completion Trend',
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final weeklyData =
                                  controller.todosCompletedByWeek;
                              final keys = weeklyData.keys.toList();
                              if (value.toInt() >= 0 &&
                                  value.toInt() < keys.length) {
                                return Text(
                                  keys[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.todosCompletedByWeek.values
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            return FlSpot(
                                entry.key.toDouble(), entry.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.urgent:
        return Colors.purple;
    }
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // lighter shadow
            blurRadius: 3, // smaller blur
            offset: const Offset(0, 1), // smaller offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // lighter shadow
            blurRadius: 3, // smaller blur
            offset: const Offset(0, 1), // smaller offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
