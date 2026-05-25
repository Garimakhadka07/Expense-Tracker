import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../utils/categories.dart';

class AddExpenseScreen extends StatefulWidget {

  final String? expenseId;
  final Map<String, dynamic>? existingData;

  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.existingData,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'Food';

  bool _isLoading = false;

  bool get isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode && widget.existingData != null) {

      _titleController.text =
          widget.existingData!['title'] ?? '';

      _amountController.text =
          widget.existingData!['amount'].toString();

      _selectedCategory =
          widget.existingData!['category'] ?? 'Food';
    }
  }

  Future<void> _addExpense() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final amountText = _amountController.text.trim();

    final title = _titleController.text.trim().isEmpty
        ? _selectedCategory
        : _titleController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
        ),
      );
      return;
    }

    final normalised = amountText.replaceAll(',', '.');
    final amount = double.tryParse(normalised);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      final formattedDate =
          DateFormat('yyyy/MM/dd - EEEE').format(now);

      if (isEditMode) {

        await _dbRef
            .child('users')
            .child(user.uid)
            .child('expenses')
            .child(widget.expenseId!)
            .update({
          'title': title,
          'amount': amount,
          'category': _selectedCategory,
          'date': formattedDate,
          'timestamp': now.toString(),
        });

      } else {

        await _dbRef
            .child('users')
            .child(user.uid)
            .child('expenses')
            .push()
            .set({
          'title': title,
          'amount': amount,
          'category': _selectedCategory,
          'date': formattedDate,
          'timestamp': now.toString(),
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);

        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? 'Edit Expense'
              : 'Add Expense',

          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        backgroundColor: Colors.deepPurple,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: kCategories.map((cat) {

                  final isSelected =
                      _selectedCategory == cat['name'];

                  return GestureDetector(

                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['name']!;
                      });
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey[200],

                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Text(cat['emoji']!),

                          const SizedBox(width: 6),

                          Text(
                            cat['name']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _amountController,

                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: InputDecoration(
                  labelText: 'Amount',

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _titleController,

                decoration: InputDecoration(
                  labelText: 'Title (optional)',

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )

                  : SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurple,

                          foregroundColor:
                              Colors.white,
                        ),

                        onPressed: _addExpense,

                        child: Text(
                          isEditMode
                              ? 'Update Expense'
                              : 'Add Expense',

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}