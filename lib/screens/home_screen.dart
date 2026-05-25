import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/categories.dart';
import 'add_expense_screen.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  final _dbRef =
      FirebaseDatabase.instance.ref();

  User? user;

  bool selectionMode = false;

  Set<String> selectedDocs = {};

  // MONTHLY BUDGET
  double monthlyBudget = 0;

  @override
  void initState() {
    super.initState();

    user = _auth.currentUser;

    _loadBudget();
  }

  // LOAD SAVED BUDGET
  Future<void> _loadBudget() async {
    final snapshot = await _dbRef
        .child('users')
        .child(user!.uid)
        .child('monthlyBudget')
        .get();

    if (snapshot.exists) {
      setState(() {
        monthlyBudget =
            (snapshot.value as num)
                .toDouble();
      });
    }
  }

  // SAVE BUDGET
  Future<void> _saveBudget(
    double budget,
  ) async {
    await _dbRef
        .child('users')
        .child(user!.uid)
        .child('monthlyBudget')
        .set(budget);

    setState(() {
      monthlyBudget = budget;
    });
  }

  DatabaseReference getExpensesRef() {
    return _dbRef
        .child('users')
        .child(user!.uid)
        .child('expenses');
  }

  Future<void> _deleteExpense(
    String docId,
  ) async {
    await getExpensesRef()
        .child(docId)
        .remove();
  }

  void _refreshExpenses() {
    setState(() {});
  }

  // SET BUDGET DIALOG
  void _setBudgetDialog() {
    TextEditingController
        budgetController =
        TextEditingController(
      text: monthlyBudget == 0
          ? ''
          : monthlyBudget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),

          title: const Text(
            'Set Monthly Budget',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller:
                budgetController,

            keyboardType:
                TextInputType.number,

            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.account_balance_wallet,
                color: Colors.deepPurple,
              ),

              hintText: 'Enter budget',

              filled: true,

              fillColor:
                  Colors.deepPurple.shade50,

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                borderSide:
                    BorderSide.none,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepPurple,

                foregroundColor:
                    Colors.white,
              ),

              onPressed: () async {
                double budget =
                    double.tryParse(
                          budgetController
                              .text,
                        ) ??
                        0;

                await _saveBudget(
                  budget,
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username =
        user?.displayName ?? "User";

    return Scaffold(
      backgroundColor:
          const Color(0xffF5F5F5),

      // APPBAR
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(85),

        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff5E35B1),
                Color(0xff7E57C2),
              ],
            ),
          ),

          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),

              child: Row(
                children: [
                  // WELCOME TEXT
                  Expanded(
                    child: Text(
                      'Welcome, $username 👋',

                      maxLines: 1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 17,
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 6),

                  // WALLET
                  _topActionButton(
                    icon: Icons
                        .account_balance_wallet,

                    tooltip:
                        "Set Budget",

                    onTap:
                        _setBudgetDialog,
                  ),

                  const SizedBox(
                      width: 6),

                  // CHART
                  _topActionButton(
                    icon:
                        Icons.pie_chart,

                    tooltip:
                        "View Chart",

                    onTap: () {
                      Map<String, double>
                          categoryTotals = {};

                      getExpensesRef()
                          .once()
                          .then((snapshot) {
                        final data =
                            snapshot
                                .snapshot
                                .value;

                        if (data !=
                            null) {
                          final rawData =
                              data as Map<
                                  dynamic,
                                  dynamic>;

                          rawData.forEach(
                            (
                              key,
                              value,
                            ) {
                              final category =
                                  value[
                                          'category'] ??
                                      'Other';

                              final amount =
                                  (value['amount'] ??
                                          0)
                                      .toDouble();

                              if (categoryTotals
                                  .containsKey(
                                      category)) {
                                categoryTotals[
                                        category] =
                                    categoryTotals[
                                            category]! +
                                        amount;
                              } else {
                                categoryTotals[
                                    category] = amount;
                              }
                            },
                          );

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (
                                context,
                              ) =>
                                      ChartScreen(
                                categoryTotals:
                                    categoryTotals,
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),

                  const SizedBox(
                      width: 6),

                  // REFRESH
                  _topActionButton(
                    icon:
                        Icons.refresh,

                    tooltip:
                        "Refresh",

                    onTap:
                        _refreshExpenses,
                  ),

                  const SizedBox(
                      width: 6),

                  // LOGOUT
                  _topActionButton(
                    icon:
                        Icons.logout,

                    tooltip:
                        "Logout",

                    onTap: () async {
                      await _auth
                          .signOut();

                      if (mounted) {
                        Navigator
                            .pushReplacementNamed(
                          context,
                          '/',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // BODY
      body: StreamBuilder<
          DatabaseEvent>(
        stream:
            getExpensesRef().onValue,

        builder:
            (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot
                      .data!
                      .snapshot
                      .value ==
                  null) {
            return const Center(
              child: Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            );
          }

          final rawData = snapshot
                  .data!
                  .snapshot
                  .value
              as Map<dynamic, dynamic>;

          final expenses =
              rawData.entries.toList();

          double totalExpenses = 0;

          for (var expense
              in expenses) {
            totalExpenses +=
                (expense.value[
                            'amount'] ??
                        0)
                    .toDouble();
          }

          double remainingBalance =
              monthlyBudget -
                  totalExpenses;

          return Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),

            child: Column(
              children: [
                // TOP CARD
                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(22),

                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xff5E35B1),
                        Color(0xff7E57C2),
                      ],
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      24,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .deepPurple
                            .withOpacity(
                          0.2,
                        ),

                        blurRadius: 12,

                        offset:
                            const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      _buildBudgetRow(
                        'Monthly Budget',
                        monthlyBudget,
                      ),

                      const SizedBox(
                          height: 16),

                      _buildBudgetRow(
                        'Total Expenses',
                        totalExpenses,
                      ),

                      const SizedBox(
                          height: 16),

                      _buildBudgetRow(
                        'Remaining Balance',
                        remainingBalance,
                      ),

                      // WARNING MESSAGE
                      if (monthlyBudget >
                              0 &&
                          remainingBalance <=
                              20)
                        Container(
                          margin:
                              const EdgeInsets.only(
                            top: 18,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                14,
                            vertical: 12,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors
                                .orangeAccent
                                .withOpacity(
                              0.15,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),

                            border: Border.all(
                              color: Colors
                                  .orangeAccent,
                            ),
                          ),

                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color:
                                    Colors.orangeAccent,
                              ),

                              SizedBox(
                                  width: 10),

                              Expanded(
                                child: Text(
                                  'Warning! Your budget is running low.',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 18),

                // EXPENSE LIST
                Expanded(
                  child:
                      ListView.builder(
                    itemCount:
                        expenses.length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final docId =
                          expenses[index]
                              .key;

                      final data =
                          Map<String,
                              dynamic>.from(
                        expenses[index]
                            .value,
                      );

                      final category =
                          data['category'] ??
                              'Other';

                      final title =
                          data['title'] ??
                              category;

                      final expenseDate =
                          data['date'] ??
                              '';

                      final amount =
                          ((data['amount'] ??
                                      0)
                                  as num)
                              .toDouble();

                      return Card(
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 14,
                        ),

                        elevation: 4,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                14,
                            vertical: 8,
                          ),

                          leading:
                              Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              10,
                            ),

                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .deepPurple
                                  .withOpacity(
                                0.1,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),

                            child: Text(
                              getCategoryEmoji(
                                category,
                              ),

                              style:
                                  const TextStyle(
                                fontSize:
                                    24,
                              ),
                            ),
                          ),

                          title: Text(
                            title,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,

                              fontSize:
                                  18,
                            ),
                          ),

                          subtitle: Text(
                            '$category • $expenseDate',
                          ),

                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [
                              Text(
                                '\$${amount.toStringAsFixed(2)}',

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  fontSize:
                                      16,
                                ),
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.edit,
                                  color: Colors
                                      .blue,
                                ),

                                onPressed:
                                    () {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder:
                                          (
                                        context,
                                      ) =>
                                              AddExpenseScreen(
                                        expenseId:
                                            docId,
                                        existingData:
                                            data,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color: Colors
                                      .red,
                                ),

                                onPressed:
                                    () =>
                                        _deleteExpense(
                                  docId,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // FLOATING BUTTON
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,

        onPressed: () {
          Navigator.pushNamed(
            context,
            '/addExpense',
          );
        },

        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
    );
  }

  // TOP BUTTON
  Widget _topActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),

        onTap: onTap,

        child: Container(
          width: 38,
          height: 38,

          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(
              12,
            ),

            border: Border.all(
              color: Colors.white
                  .withOpacity(0.18),
            ),
          ),

          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  // BUDGET ROW
  Widget _buildBudgetRow(
    String title,
    double amount,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

      children: [
        Text(
          title,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        Text(
          '\$${amount.toStringAsFixed(2)}',

          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}