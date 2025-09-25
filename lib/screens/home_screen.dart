import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart'; // AppState
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17) {
      greeting = 'Good evening';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          // === Data Calculation ===
          final totalIncome = appState.transactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);

          final totalExpense = appState.transactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);

          final totalBalance = totalIncome - totalExpense;

          final recentTransactions =
          appState.transactions.reversed.take(4).toList();

          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // === Custom App Bar ===
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
                            const Color(0xFF0A0E21),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                                        '$greeting!',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Here's your financial overview",
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
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
                        // === Enhanced Balance Card ===
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
                                color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
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
                                        'Total Balance',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: Text(
                                          _isBalanceVisible
                                              ? formatter.format(totalBalance)
                                              : '••••••••',
                                          key: ValueKey(_isBalanceVisible),
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: totalBalance >= 0
                                                ? const Color(0xFF00D4FF)
                                                : const Color(0xFFFF6B6B),
                                            shadows: [
                                              Shadow(
                                                color: totalBalance >= 0
                                                    ? const Color(0xFF00D4FF).withValues(alpha: 0.5)
                                                    : const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isBalanceVisible = !_isBalanceVisible;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        _isBalanceVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: totalBalance >= 0
                                      ? const Color(0xFF00D4FF).withValues(alpha: 0.15)
                                      : const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: totalBalance >= 0
                                        ? const Color(0xFF00D4FF).withValues(alpha: 0.3)
                                        : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      totalBalance >= 0
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      size: 16,
                                      color: totalBalance >= 0
                                          ? const Color(0xFF00D4FF)
                                          : const Color(0xFFFF6B6B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      totalBalance >= 0
                                          ? 'Positive balance'
                                          : 'Negative balance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                        color: totalBalance >= 0
                                            ? const Color(0xFF00D4FF)
                                            : const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // === Enhanced Income & Expense Cards ===
                        Row(
                          children: [
                            Expanded(
                              child: _EnhancedSummaryCard(
                                icon: Icons.trending_up,
                                iconColor: const Color(0xFF00D4FF),
                                backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                                label: 'Income',
                                value: _isBalanceVisible
                                    ? formatter.format(totalIncome)
                                    : '••••••',
                                valueColor: const Color(0xFF00D4FF),
                                isVisible: _isBalanceVisible,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _EnhancedSummaryCard(
                                icon: Icons.trending_down,
                                iconColor: const Color(0xFFFF6B6B),
                                backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                label: 'Expenses',
                                value: _isBalanceVisible
                                    ? formatter.format(totalExpense)
                                    : '••••••',
                                valueColor: const Color(0xFFFF6B6B),
                                isVisible: _isBalanceVisible,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // === Recent Transactions Section ===
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => appState.updateSelectedIndex(1),
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('See All'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF00D4FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        recentTransactions.isEmpty
                            ? _EmptyTransactionsWidget()
                            : Column(
                          children: recentTransactions.map((transaction) {
                            return _EnhancedTransactionCard(
                              transaction: transaction,
                              formatter: formatter,
                              isVisible: _isBalanceVisible,
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 100), // Bottom padding for navigation
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
}

// === Enhanced Summary Card ===
class _EnhancedSummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final Color valueColor;
  final bool isVisible;

  const _EnhancedSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
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
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(isVisible),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: valueColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === Enhanced Transaction Card ===
class _EnhancedTransactionCard extends StatelessWidget {
  final dynamic transaction;
  final intl.NumberFormat formatter;
  final bool isVisible;

  const _EnhancedTransactionCard({
    required this.transaction,
    required this.formatter,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (transaction.type == 'income'
                  ? const Color(0xFF00D4FF).withValues(alpha: 0.15)
                  : const Color(0xFFFF6B6B).withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: transaction.type == 'income'
                    ? const Color(0xFF00D4FF).withValues(alpha: 0.3)
                    : const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              transaction.type == 'income'
                  ? Icons.add
                  : Icons.remove,
              color: transaction.type == 'income'
                  ? const Color(0xFF00D4FF)
                  : const Color(0xFFFF6B6B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isVisible
                      ? '${transaction.type == 'income' ? '+' : '-'}${formatter.format(transaction.amount)}'
                      : '••••••',
                  key: ValueKey(isVisible),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: transaction.type == 'income'
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFFFF6B6B),
                    shadows: [
                      Shadow(
                        color: transaction.type == 'income'
                            ? const Color(0xFF00D4FF).withValues(alpha: 0.4)
                            : const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === Empty Transactions Widget ===
class _EmptyTransactionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first transaction',
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
}