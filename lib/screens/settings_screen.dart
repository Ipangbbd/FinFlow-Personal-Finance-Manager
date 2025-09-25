import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import 'package:finance_manager/main.dart';
import 'package:finance_manager/models/category.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
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
    const primary = Color(0xFF00D4FF);
    const danger = Color(0xFFFF6B6B);
    // const surfaceStart = Color(0xFF1A1F3A);
    // const surfaceEnd = Color(0xFF151929);
    const backgroundColor = Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // === Enhanced App Bar ===
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A5F),
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
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Settings',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Manage your finance app',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                      size: 28,
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
                        // === Quick Stats Cards ===
                        _buildQuickStatsSection(appState, primary),
                        const SizedBox(height: 32),

                        // === Data Management Section ===
                        _buildModernSection(
                          context: context,
                          title: 'Data Management',
                          icon: Icons.storage,
                          iconColor: primary,
                          children: [
                            _buildModernTile(
                              context: context,
                              icon: Icons.download_rounded,
                              title: 'Export Data',
                              subtitle: 'Download your financial data',
                              iconColor: const Color(0xFF00FFA3),
                              onTap: () => _showSnack(context, 'Export data not implemented.'),
                            ),
                            _buildModernTile(
                              context: context,
                              icon: Icons.upload_rounded,
                              title: 'Import Data',
                              subtitle: 'Restore from backup',
                              iconColor: const Color(0xFFFFD166),
                              onTap: () => _showSnack(context, 'Import data not implemented.'),
                            ),
                            _buildModernTile(
                              context: context,
                              icon: Icons.category_rounded,
                              title: 'Manage Categories',
                              subtitle: '${appState.categories.length} categories available',
                              iconColor: const Color(0xFF6A4C93),
                              onTap: () => _showManageCategoriesDialog(context, appState),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // === Statistics Section ===
                        _buildModernSection(
                          context: context,
                          title: 'Statistics',
                          icon: Icons.analytics,
                          iconColor: const Color(0xFF118AB2),
                          children: [
                            _buildModernTile(
                              context: context,
                              icon: Icons.receipt_long_rounded,
                              title: 'Total Transactions',
                              subtitle: '${appState.transactions.length} recorded transactions',
                              iconColor: const Color(0xFF06D6A0),
                              onTap: () => _showTransactionStatsDialog(context, appState),
                            ),
                            _buildModernTile(
                              context: context,
                              icon: Icons.pie_chart_rounded,
                              title: 'Category Usage',
                              subtitle: 'View category statistics',
                              iconColor: const Color(0xFFF72585),
                              onTap: () => _showCategoryStatsDialog(context, appState),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // === Support Section ===
                        _buildModernSection(
                          context: context,
                          title: 'Support',
                          icon: Icons.help_center,
                          iconColor: const Color(0xFFFF6B6B),
                          children: [
                            _buildModernTile(
                              context: context,
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              subtitle: 'Get help with using the app',
                              iconColor: primary,
                              onTap: () => _showHelpDialog(context),
                            ),
                            _buildModernTile(
                              context: context,
                              icon: Icons.info_outline_rounded,
                              title: 'About',
                              subtitle: 'App version and information',
                              iconColor: Colors.white.withValues(alpha: 0.7),
                              onTap: () => _showAboutDialog(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // === Danger Zone ===
                        _buildDangerSection(context, appState, danger),

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

  Widget _buildQuickStatsSection(AppState appState, Color primary) {
    final incomeTransactions = appState.transactions.where((t) => t.type == 'income').length;
    final expenseTransactions = appState.transactions.where((t) => t.type == 'expense').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.receipt_long,
                label: 'Transactions',
                value: '${appState.transactions.length}',
                color: primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.category,
                label: 'Categories',
                value: '${appState.categories.length}',
                color: const Color(0xFF00FFA3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.arrow_upward,
                label: 'Income',
                value: '$incomeTransactions',
                color: const Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickStatCard(
                icon: Icons.arrow_downward,
                label: 'Expenses',
                value: '$expenseTransactions',
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F3A),
            Color(0xFF151929),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
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
              fontSize: 24,
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

  Widget _buildModernSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1F3A),
                Color(0xFF151929),
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
            children: List.generate(
              children.length * 2 - 1,
                  (i) => i.isEven
                  ? children[i ~/ 2]
                  : Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
                indent: 20,
                endIndent: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerSection(BuildContext context, AppState appState, Color danger) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F3A),
            Color(0xFF151929),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: danger.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: danger.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: danger.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.warning, color: danger, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: danger,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1F3A),
                  Color(0xFF151929),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: danger.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showClearAllDataConfirmation(context, appState),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: danger.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.delete_forever, color: danger, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clear All Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: danger,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Permanently delete all data',
                              style: TextStyle(
                                fontSize: 14,
                                color: danger.withValues(alpha: 0.8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: danger.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Dialog Methods ===

  void _showTransactionStatsDialog(BuildContext context, AppState appState) {
    final incomeCount = appState.transactions.where((t) => t.type == 'income').length;
    final expenseCount = appState.transactions.where((t) => t.type == 'expense').length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text(
              'Transaction Statistics',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Transactions', '${appState.transactions.length}', Icons.receipt_long),
            const SizedBox(height: 12),
            _buildStatRow('Income Transactions', '$incomeCount', Icons.arrow_upward),
            const SizedBox(height: 12),
            _buildStatRow('Expense Transactions', '$expenseCount', Icons.arrow_downward),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCategoryStatsDialog(BuildContext context, AppState appState) {
    final categoryUsage = <String, int>{};
    for (var transaction in appState.transactions) {
      categoryUsage[transaction.category] = (categoryUsage[transaction.category] ?? 0) + 1;
    }

    final sortedCategories = categoryUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.pie_chart, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text('Category Statistics', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${entry.value} transactions', style: const TextStyle(color: Colors.white70)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.help, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text('Help & Support', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Add transactions using the + button', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('• View analytics in the Analytics tab', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('• Manage categories in Settings', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text('• Export your data for backup', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text('About', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Finance Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text(
              'A simple and elegant finance tracking app to help you manage your personal finances.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  void _showManageCategoriesDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.category, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text('Manage Categories', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.categories.length,
            itemBuilder: (_, index) {
              final category = appState.categories[index];
              return Card(
                color: const Color(0xFF151929),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF00D4FF).withValues(alpha: 0.1),
                    child: const Icon(Icons.category, color: Color(0xFF00D4FF)),
                  ),
                  title: Text(category.name, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
                    onPressed: () {
                      appState.deleteCategory(category.id);
                      Navigator.of(context).pop();
                      _showManageCategoriesDialog(context, appState);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddCategoryDialog(context, appState);
            },
            child: const Text('Add New'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.add_circle, color: Color(0xFF00D4FF)),
            SizedBox(width: 8),
            Text('Add New Category', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white30),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManageCategoriesDialog(context, appState);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: controller.text,
                );
                appState.addCategory(newCategory);
                Navigator.of(context).pop();
                _showManageCategoriesDialog(context, appState);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFFF6B6B)),
            SizedBox(width: 8),
            Text(
              'Clear All Data',
              style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete all your financial data? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await appState.clearAllData();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              _showSnack(context, 'All data cleared successfully!');
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00D4FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}