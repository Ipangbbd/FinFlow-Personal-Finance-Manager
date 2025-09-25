import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:finance_manager/main.dart';
import 'package:finance_manager/models/transaction.dart';
import 'package:intl/intl.dart' as intl;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  String _transactionType = 'income';
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF00D4FF),
            ),
            dialogBackgroundColor: const Color(0xFF1A1F3A),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _handleAddTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final appState = provider.Provider.of<AppState>(context, listen: false);
    final newTransaction = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _descriptionController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory ?? 'Uncategorized',
      type: _transactionType,
    );

    appState.addTransaction(newTransaction);

    // Reset form with animation
    _animationController.reset();
    _animationController.forward();

    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _transactionType = 'income';
    });

    // Enhanced success feedback using theme accent
    const successColor = Color(0xFF00D4FF);

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
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Transaction added successfully!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hardcoded theme colors from home_screen.dart
    const primary = Color(0xFF00D4FF);
    const expenseColor = Color(0xFFFF6B6B);
    const surfaceStart = Color(0xFF1A1F3A);
    const surfaceEnd = Color(0xFF151929);
    const backgroundColor = Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
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
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'Add Transaction',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Track your income and expenses',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: provider.Consumer<AppState>(
              builder: (_, appState, __) {
                return AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Transaction Type Section
                                _EnhancedSectionCard(
                                  title: 'Transaction Type',
                                  icon: Icons.swap_horiz,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _EnhancedTransactionTypeCard(
                                          label: 'Income',
                                          icon: Icons.trending_up,
                                          isSelected: _transactionType == 'income',
                                          selectedColor: primary,
                                          onTap: () => setState(() => _transactionType = 'income'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _EnhancedTransactionTypeCard(
                                          label: 'Expense',
                                          icon: Icons.trending_down,
                                          isSelected: _transactionType == 'expense',
                                          selectedColor: expenseColor,
                                          onTap: () => setState(() => _transactionType = 'expense'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Amount Section
                                _EnhancedSectionCard(
                                  title: 'Amount',
                                  icon: Icons.attach_money,
                                  child: Container(
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
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: primary.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.attach_money,
                                            color: primary,
                                            size: 20,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an amount';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Please enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Description Section
                                _EnhancedSectionCard(
                                  title: 'Description',
                                  icon: Icons.description,
                                  child: Container(
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
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _descriptionController,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'What was this for?',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          letterSpacing: 0.2,
                                        ),
                                        prefixIcon: Container(
                                          margin: const EdgeInsets.all(12),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: primary.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.description,
                                            color: primary,
                                            size: 20,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                      ),
                                      validator: (value) => value == null || value.isEmpty
                                          ? 'Please enter a description'
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Category Section
                                _EnhancedSectionCard(
                                  title: 'Category',
                                  icon: Icons.category,
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: appState.categories
                                        .map((cat) => _EnhancedCategoryChip(
                                              category: cat.name,
                                              isSelected: cat.name == _selectedCategory,
                                              onSelected: (selected) {
                                                setState(() => _selectedCategory =
                                                    selected ? cat.name : null);
                                              },
                                            ))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Date Section
                                _EnhancedSectionCard(
                                  title: 'Date',
                                  icon: Icons.calendar_today,
                                  child: GestureDetector(
                                    onTap: () => _pickDate(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
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
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: primary.withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today,
                                              color: primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            intl.DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white.withValues(alpha: 0.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Submit Button
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primary,
                                          primary.withValues(alpha: 0.86),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.28),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _handleAddTransaction,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_circle, color: Colors.white, size: 24),
                                          SizedBox(width: 12),
                                          Text(
                                            'Add Transaction',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Section Card
class _EnhancedSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _EnhancedSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  icon,
                  color: const Color(0xFF00D4FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// Enhanced Transaction Type Card
class _EnhancedTransactionTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _EnhancedTransactionTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? selectedColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? selectedColor : Colors.white.withValues(alpha: 0.72),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Category Chip
class _EnhancedCategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _EnhancedCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D4FF) : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}