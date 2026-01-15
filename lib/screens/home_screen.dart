import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  double _totalExpenses = 0.0;
  int _selectedFilter = 0; // 0: All, 1: Today, 2: This Week, 3: This Month
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month'];
  final List<String> _categories = [
    'All Categories',
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Lainnya',
  ];
  String _selectedCategory = 'All Categories';

  @override
  void initState() {
    super.initState();
    // Sample data
    _addSampleData();
    _calculateTotal();
  }

  void _addSampleData() {
    _expenses.addAll([
      Expense.create(
        title: 'Makan Siang',
        amount: 45000,
        category: 'Makanan & Minuman',
        description: 'Nasi padang di kantin',
        colorIndex: 0,
      ),
      Expense.create(
        title: 'Bensin Motor',
        amount: 30000,
        category: 'Transportasi',
        description: 'Pertamax',
        colorIndex: 1,
      ),
      Expense.create(
        title: 'Belanja Bulanan',
        amount: 250000,
        category: 'Belanja',
        description: 'Sayur dan buah',
        colorIndex: 2,
      ),
      Expense.create(
        title: 'Nonton Bioskop',
        amount: 80000,
        category: 'Hiburan',
        description: 'Film Avengers',
        colorIndex: 3,
      ),
      Expense.create(
        title: 'Vitamin',
        amount: 120000,
        category: 'Kesehatan',
        description: 'Vitamin C dan D',
        colorIndex: 4,
      ),
    ]);
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.add(expense);
      _calculateTotal();
    });
  }

  void _deleteExpense(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _expenses.removeWhere((expense) => expense.id == id);
                _calculateTotal();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _calculateTotal() {
    _totalExpenses = _expenses.fold(
      0.0,
      (previousValue, expense) => previousValue + expense.amount,
    );
  }

  List<Expense> get _filteredExpenses {
    List<Expense> filtered = List.from(_expenses);

    // Filter by date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    switch (_selectedFilter) {
      case 1: // Today
        filtered = filtered
            .where(
              (expense) =>
                  DateTime(
                    expense.date.year,
                    expense.date.month,
                    expense.date.day,
                  ) ==
                  today,
            )
            .toList();
        break;
      case 2: // This Week
        filtered = filtered
            .where((expense) => expense.date.isAfter(weekAgo))
            .toList();
        break;
      case 3: // This Month
        filtered = filtered
            .where((expense) => expense.date.isAfter(monthAgo))
            .toList();
        break;
    }

    // Filter by category
    if (_selectedCategory != 'All Categories') {
      filtered = filtered
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Statistics
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Expense Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Pengeluaran',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_totalExpenses.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              icon: Icons.receipt_long,
                              value: _expenses.length.toString(),
                              label: 'Transactions',
                            ),
                            _buildStatItem(
                              icon: Icons.trending_up,
                              value:
                                  'Rp ${_getAverageExpense().toStringAsFixed(0)}',
                              label: 'Average',
                            ),
                            _buildStatItem(
                              icon: Icons.calendar_today,
                              value: _getTodayExpenses().toStringAsFixed(0),
                              label: 'Today',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _filters.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filters[index]),
                        selected: _selectedFilter == index,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = selected ? index : 0;
                          });
                        },
                        selectedColor: const Color(0xFF6C63FF),
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedFilter == index
                              ? Colors.white
                              : const Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Category Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF6C63FF),
                    ),
                    underline: const SizedBox(),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Expense List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredExpenses.length} items',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Expense List
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first expense to get started',
                          style: TextStyle(color: Color(0xFFCCCCCC)),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredExpenses.length,
                      itemBuilder: (context, index) {
                        return ExpenseCard(
                          expense: _filteredExpenses[index],
                          onDelete: _deleteExpense,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          if (result != null && result is Expense) {
            _addExpense(result);
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  double _getAverageExpense() {
    if (_expenses.isEmpty) return 0;
    return _totalExpenses / _expenses.length;
  }

  double _getTodayExpenses() {
    final today = DateTime.now();
    return _expenses
        .where(
          (expense) =>
              expense.date.year == today.year &&
              expense.date.month == today.month &&
              expense.date.day == today.day,
        )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
