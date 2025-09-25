import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:finance_manager/models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _sortBy = 'Date';
  bool _isSearchVisible = false;
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _searchSlideAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _searchSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hardcoded theme colors from home_screen.dart
    const positiveAccent = Color(0xFF00D4FF);
    const negativeAccent = Color(0xFFFF6B6B);
    const surfaceStart = Color(0xFF1A1F3A);
    const surfaceEnd = Color(0xFF151929);
    const backgroundColor = Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          final filteredTransactions = _filterTransactions(appState);
          final formatter = intl.NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // === Enhanced App Bar with Animated Search ===
                SliverAppBar(
                  expandedHeight: _isSearchVisible ? 200 : 140,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Transactions',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Track your financial activity',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      _buildHeaderButton(
                                        icon: _isSearchVisible ? Icons.search_off : Icons.search,
                                        onTap: _toggleSearch,
                                        isActive: _isSearchVisible,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildHeaderButton(
                                        icon: Icons.sort,
                                        onTap: () => _showSortBottomSheet(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (_isSearchVisible) ...[
                                const SizedBox(height: 20),
                                AnimatedBuilder(
                                  animation: _searchSlideAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _searchSlideAnimation.value),
                                      child: Opacity(
                                        opacity: _searchAnimationController.value,
                                        child: _buildEnhancedSearchBar(positiveAccent),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // === Enhanced Stats & Filter Section ===
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(filteredTransactions, formatter, positiveAccent, negativeAccent, surfaceStart, surfaceEnd),
                        const SizedBox(height: 20),
                        _buildFilterChips(context, positiveAccent),
                      ],
                    ),
                  ),
                ),

                // === Transactions List ===
                filteredTransactions.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(context, positiveAccent))
                    : _buildGroupedTransactionsList(
                        context, filteredTransactions, formatter, appState, surfaceStart, surfaceEnd, positiveAccent, negativeAccent),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ----------------------
  /// 🔹 Enhanced UI Builders
  /// ----------------------

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: Colors.white.withValues(alpha: 0.28))
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildEnhancedSearchBar(Color positiveAccent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            letterSpacing: 0.3,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<Transaction> transactions, intl.NumberFormat formatter, Color positiveAccent, Color negativeAccent, Color surfaceStart, Color surfaceEnd) {
    final total = transactions.fold<double>(0, (sum, t) {
      return sum + (t.type == 'income' ? t.amount : -t.amount);
    });

    final income = transactions.where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final expense = transactions.where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceStart,
            surfaceEnd,
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
            color: (total >= 0 ? positiveAccent : negativeAccent).withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${transactions.length} transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: total >= 0 ? positiveAccent.withValues(alpha: 0.15) : negativeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: total >= 0 ? positiveAccent.withValues(alpha: 0.3) : negativeAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      total >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: total >= 0 ? positiveAccent : negativeAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${total >= 0 ? '+' : ''}${formatter.format(total)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: total >= 0 ? positiveAccent : negativeAccent,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (transactions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard(
                    'Income',
                    formatter.format(income),
                    positiveAccent,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard(
                    'Expense',
                    formatter.format(expense),
                    negativeAccent,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
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

  Widget _buildFilterChips(BuildContext context, Color primary) {
    final filters = [
      {'name': 'All', 'icon': Icons.list},
      {'name': 'Income', 'icon': Icons.trending_up},
      {'name': 'Expense', 'icon': Icons.trending_down},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? primary : Colors.white.withValues(alpha: 0.06),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.22),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.receipt_long_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'No transactions found'
                : 'No transactions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Start tracking your expenses and income',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.72),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionsList(
      BuildContext context,
      List<Transaction> transactions,
      intl.NumberFormat formatter,
      AppState appState,
      Color surfaceStart,
      Color surfaceEnd,
      Color positiveAccent,
      Color negativeAccent,
      ) {
    final groupedTransactions = _groupTransactionsByDate(transactions);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final dayTransactions = groupedTransactions[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateKey, dayTransactions, formatter, positiveAccent, negativeAccent),
              ...dayTransactions.map((transaction) =>
                  _buildEnhancedTransactionCard(transaction, formatter, appState, positiveAccent, negativeAccent, surfaceStart, surfaceEnd)),
              const SizedBox(height: 8),
            ],
          );
        },
        childCount: groupedTransactions.length,
      ),
    );
  }

  Widget _buildDateHeader(String date, List<Transaction> transactions, intl.NumberFormat formatter, Color positiveAccent, Color negativeAccent) {
    final total = transactions.fold<double>(0, (sum, t) {
      return sum + (t.type == 'income' ? t.amount : -t.amount);
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: total >= 0 ? positiveAccent.withValues(alpha: 0.08) : negativeAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: total >= 0 ? positiveAccent.withValues(alpha: 0.2) : negativeAccent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${total >= 0 ? '+' : ''}${formatter.format(total)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: total >= 0 ? positiveAccent : negativeAccent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTransactionCard(
      Transaction transaction,
      intl.NumberFormat formatter,
      AppState appState,
      Color positiveAccent,
      Color negativeAccent,
      Color surfaceStart,
      Color surfaceEnd,
      ) {
    final isIncome = transaction.type == 'income';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceStart, surfaceEnd],
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
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                negativeAccent.withValues(alpha: 0),
                negativeAccent,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 24),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context, transaction);
        },
        onDismissed: (direction) {
          _deleteTransaction(appState, transaction);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? positiveAccent.withValues(alpha: 0.15) : negativeAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isIncome ? positiveAccent.withValues(alpha: 0.3) : negativeAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isIncome ? Icons.add : Icons.remove,
              color: isIncome ? positiveAccent : negativeAccent,
              size: 20,
            ),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Text(
            transaction.category,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.72),
              letterSpacing: 0.2,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? positiveAccent : negativeAccent,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: (isIncome ? positiveAccent : negativeAccent).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    intl.DateFormat('HH:mm').format(transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showDeleteConfirmation(context, transaction).then((confirmed) {
                  if (confirmed == true) {
                    _deleteTransaction(appState, transaction);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: negativeAccent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: negativeAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: negativeAccent,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.02),
                Colors.white.withValues(alpha: 0.01),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.sort,
                      color: const Color(0xFF00D4FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...[
                {'name': 'Date', 'icon': Icons.calendar_today},
                {'name': 'Amount', 'icon': Icons.attach_money},
                {'name': 'Title', 'icon': Icons.text_fields},
              ].map((sort) {
                final isSelected = _sortBy == sort['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00D4FF).withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      sort['icon'] as IconData,
                      color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withValues(alpha: 0.78),
                    ),
                    title: Text(
                      sort['name'] as String,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 0.3,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: const Color(0xFF00D4FF))
                        : null,
                    onTap: () {
                      setState(() => _sortBy = sort['name'] as String);
                      Navigator.pop(context);
                    },
                  ),
                );
              })
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.delete, color: const Color(0xFFFF6B6B), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Delete Transaction', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text('Are you sure you want to delete "${transaction.title}"?', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(AppState appState, Transaction transaction) {
    appState.deleteTransaction(transaction.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${transaction.title} deleted successfully',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            appState.addTransaction(transaction);
          },
        ),
      ),
    );
  }

  /// ----------------------
  /// 🔹 Helper Methods
  /// ----------------------

  List<Transaction> _filterTransactions(AppState appState) {
    final filtered = appState.transactions.where((transaction) {
      final matchesFilter =
          _selectedFilter == 'All' ||
              (_selectedFilter == 'Income' && transaction.type == 'income') ||
              (_selectedFilter == 'Expense' && transaction.type == 'expense');

      final matchesSearch = transaction.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          transaction.category
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Amount':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Date':
      default:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return filtered;
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    final now = DateTime.now();

    for (final transaction in transactions) {
      final date = transaction.date;
      String dateKey;

      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateKey = 'Today';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        dateKey = 'Yesterday';
      } else {
        dateKey = intl.DateFormat('MMM dd, yyyy').format(date);
      }

      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return grouped;
  }
}