import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';

final List<String> allMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  int _touchedIndex = -1;
  int _selectedTimeRange = 0; // 0: All Time, 1: Last 3 Months, 2: Last Month
  bool _showIncomeInChart = true;
  bool _showExpenseInChart = true;
  bool _showNetInChart = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  final List<String> timeRanges = ['All Time', 'Last 3 Months', 'Last Month'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _tabController = TabController(length: 3, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use hardcoded theme colors from home_screen.dart
    const primary = Color(0xFF00D4FF);
    const surfaceStart = Color(0xFF1A1F3A);
    const surfaceEnd = Color(0xFF151929);
    const backgroundColor = Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          final filteredTransactions = _getFilteredTransactions(appState);
          final totalIncome = _calculateTotal(filteredTransactions, 'income');
          final totalExpense = _calculateTotal(filteredTransactions, 'expense');
          final netWorth = totalIncome - totalExpense;
          final categoryExpenses = _groupExpensesByCategory(filteredTransactions);
          final sortedCategoryExpenses = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final monthlyIncome = _groupTransactionsByMonth(filteredTransactions, 'income');
          final monthlyExpense = _groupTransactionsByMonth(filteredTransactions, 'expense');
          final allMonths = _getAllMonths(monthlyIncome, monthlyExpense);
          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // === Enhanced App Bar (styled like home) ===
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1E3A5F),
                            backgroundColor,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Flexible(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Analytics',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Insights into your finances',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () => _showTimeRangeBottomSheet(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.access_time, color: Colors.white, size: 14),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  timeRanges[_selectedTimeRange],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.3,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.7), size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // === Content ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Summary Section ===
                        _buildSummarySection(context, totalIncome, totalExpense, netWorth, formatter),
                        const SizedBox(height: 32),
                        // === Tab Section ===
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [surfaceStart, surfaceEnd],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: primary.withValues(alpha: 0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Tab Bar
                              Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                                  indicator: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  tabs: const [
                                    Tab(text: 'Overview'),
                                    Tab(text: 'Categories'),
                                    Tab(text: 'Trends'),
                                  ],
                                ),
                              ),
                              // Tab Content
                              SizedBox(
                                height: 400,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOverviewTab(context, totalIncome, totalExpense, formatter, filteredTransactions, primary),
                                    _buildCategoriesTab(context, sortedCategoryExpenses, formatter, totalExpense),
                                    _buildTrendsTab(context, monthlyIncome, monthlyExpense, allMonths),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, double totalIncome, double totalExpense, double netWorth, intl.NumberFormat formatter) {
    final isPositive = netWorth >= 0;
    const incomeColor = Color(0xFF00D4FF);
    const expenseColor = Color(0xFFFF6B6B);
    final netColor = isPositive ? incomeColor : expenseColor;

    return Column(
      children: [
        // Main balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3A),
                const Color(0xFF151929),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: netColor.withValues(alpha: 0.1),
                blurRadius: 40,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Worth',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatter.format(netWorth),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: netColor,
                          shadows: [
                            Shadow(
                              color: netColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: netColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: netColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: netColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPositive ? 'Profit' : 'Loss',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: netColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Income and Expense cards
        Row(
          children: [
            Expanded(
              child: _buildMiniSummaryCard(
                context,
                icon: Icons.trending_up,
                label: 'Income',
                value: formatter.format(totalIncome),
                color: incomeColor,
                backgroundColor: incomeColor.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMiniSummaryCard(
                context,
                icon: Icons.trending_down,
                label: 'Expenses',
                value: formatter.format(totalExpense),
                color: expenseColor,
                backgroundColor: expenseColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniSummaryCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A),
            const Color(0xFF151929),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, double totalIncome, double totalExpense, intl.NumberFormat formatter, List<dynamic> transactions, Color primary) {
    final savings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Savings rate progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1F3A),
                  const Color(0xFF151929),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Savings Rate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: savingsRate / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(savings),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    shadows: [
                      Shadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Transactions',
                  '${transactions.length}',
                  Icons.receipt_long,
                  const Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Avg. Income',
                  formatter.format(totalIncome / max(1, transactions.where((t) => t.type == 'income').length)),
                  Icons.trending_up,
                  const Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  'Avg. Expense',
                  formatter.format(totalExpense / max(1, transactions.where((t) => t.type == 'expense').length)),
                  Icons.trending_down,
                  const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  'Categories',
                  '${_groupExpensesByCategory(transactions).length}',
                  Icons.category,
                  const Color(0xFF00D4FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, List<MapEntry<String, double>> sortedCategoryExpenses, intl.NumberFormat formatter, double totalExpense) {
    if (sortedCategoryExpenses.isEmpty || totalExpense == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 16),
            Text(
              'No expense data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding expenses to see category breakdown',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          // Pie Chart
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Chart
                    Expanded(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse?.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sections: sortedCategoryExpenses.take(6).toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final amount = data.value;
                              final isTouched = index == _touchedIndex;
                              final radius = isTouched ? 70.0 : 60.0;
                              final percentage = (amount / totalExpense) * 100;
                              return PieChartSectionData(
                                color: _getCategoryColor(index),
                                value: amount,
                                title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                                radius: radius,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ),
                    // Legend
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: sortedCategoryExpenses.take(6).toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            final categoryName = data.key;
                            final amount = data.value;
                            final percentage = (amount / totalExpense) * 100;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(index),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          categoryName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withValues(alpha: 0.7),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context, Map<String, double> monthlyIncome, Map<String, double> monthlyExpense, List<String> allMonths) {
    if (allMonths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 16),
            Text(
              'No trend data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more transactions to see trends',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Monthly Trends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChartToggle('Income', const Color(0xFF00D4FF), _showIncomeInChart, (value) {
                          setState(() => _showIncomeInChart = value);
                        }),
                        const SizedBox(width: 8),
                        _buildChartToggle('Expense', const Color(0xFFFF6B6B), _showExpenseInChart, (value) {
                          setState(() => _showExpenseInChart = value);
                        }),
                        const SizedBox(width: 8),
                        _buildChartToggle('Net', const Color(0xFF00D4FF), _showNetInChart, (value) {
                          setState(() => _showNetInChart = value);
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildEnhancedTrendsChart(monthlyIncome, monthlyExpense, allMonths),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(String label, Color color, bool isSelected, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTrendsChart(Map<String, double> monthlyIncome, Map<String, double> monthlyExpense, List<String> allMonths) {
    final maxY = [
      monthlyIncome.values.isEmpty ? 0.0 : monthlyIncome.values.reduce(max),
      monthlyExpense.values.isEmpty ? 0.0 : monthlyExpense.values.reduce(max),
    ].reduce(max) * 1.2;

    List<LineChartBarData> lineBars = [];

    if (_showIncomeInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final income = monthlyIncome[month] ?? 0.0;
          return FlSpot(index, income);
        }).toList(),
        isCurved: true,
        color: const Color(0xFF00D4FF),
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: const Color(0xFF00D4FF),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF00D4FF).withValues(alpha: 0.08),
        ),
      ));
    }

    if (_showExpenseInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final expense = monthlyExpense[month] ?? 0.0;
          return FlSpot(index, expense);
        }).toList(),
        isCurved: true,
        color: const Color(0xFFFF6B6B),
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: const Color(0xFFFF6B6B),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
        ),
      ));
    }

    if (_showNetInChart) {
      lineBars.add(LineChartBarData(
        spots: allMonths.asMap().entries.map((entry) {
          final index = entry.key.toDouble();
          final month = entry.value;
          final net = (monthlyIncome[month] ?? 0.0) - (monthlyExpense[month] ?? 0.0);
          return FlSpot(index, net);
        }).toList(),
        isCurved: true,
        color: const Color(0xFF00D4FF),
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: const Color(0xFF00D4FF),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
      ));
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY == 0 ? 1 : maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < allMonths.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      allMonths[index].substring(0, 3),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY == 0 ? 1 : maxY / 5,
              reservedSize: 60,
              getTitlesWidget: (value, _) => Text(
                intl.NumberFormat.compactCurrency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(value),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final month = allMonths[spot.x.toInt()];
                final formatter = intl.NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );
                Color color = const Color(0xFF00D4FF);
                String label = 'Net';
                if (spot.barIndex == 0 && _showIncomeInChart) {
                  color = const Color(0xFF00D4FF);
                  label = 'Income';
                } else if (spot.barIndex == 1 && _showExpenseInChart) {
                  color = const Color(0xFFFF6B6B);
                  label = 'Expense';
                }
                return LineTooltipItem(
                  '$month\n$label: ${formatter.format(spot.y)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: lineBars,
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Color(0xFF00D4FF),
      Color(0xFFFF6B6B),
      Color(0xFF00FFA3),
      Color(0xFFFFD166),
      Color(0xFF6A4C93),
      Color(0xFF118AB2),
      Color(0xFFF72585),
      Color(0xFF06D6A0),
    ];
    return colors[index % colors.length];
  }

  void _showTimeRangeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1F3A),
                const Color(0xFF151929),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Time Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              ...timeRanges.asMap().entries.map((entry) {
                final index = entry.key;
                final range = entry.value;
                return ListTile(
                  leading: Icon(
                    index == 0 ? Icons.all_inclusive :
                    index == 1 ? Icons.calendar_view_month : Icons.calendar_today,
                    color: Colors.white,
                  ),
                  title: Text(range, style: const TextStyle(color: Colors.white)),
                  trailing: _selectedTimeRange == index
                      ? Icon(Icons.check, color: const Color(0xFF00D4FF))
                      : null,
                  onTap: () {
                    setState(() => _selectedTimeRange = index);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// ----------------------
  /// 🔹 Helper Methods
  /// ----------------------
  List<dynamic> _getFilteredTransactions(AppState appState) {
    final now = DateTime.now();
    return appState.transactions.where((transaction) {
      switch (_selectedTimeRange) {
        case 1: // Last 3 months
          return transaction.date.isAfter(DateTime(now.year, now.month - 3, now.day));
        case 2: // Last month
          return transaction.date.isAfter(DateTime(now.year, now.month - 1, now.day));
        default: // All time
          return true;
      }
    }).toList();
  }

  double _calculateTotal(List<dynamic> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> _groupExpensesByCategory(List<dynamic> transactions) {
    final Map<String, double> categoryExpenses = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
      categoryExpenses.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    return categoryExpenses;
  }

  Map<String, double> _groupTransactionsByMonth(List<dynamic> transactions, String type) {
    final Map<String, double> monthlyData = {};
    for (var t in transactions.where((t) => t.type == type)) {
      final monthYear = intl.DateFormat('MMM yyyy').format(t.date);
      monthlyData.update(monthYear, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    return monthlyData;
  }

  List<String> _getAllMonths(Map<String, double> monthlyIncome, Map<String, double> monthlyExpense) {
    final months = {...monthlyIncome.keys, ...monthlyExpense.keys}.toList();
    months.sort((a, b) => intl.DateFormat('MMM yyyy')
        .parse(a)
        .compareTo(intl.DateFormat('MMM yyyy').parse(b)));
    return months;
  }
}