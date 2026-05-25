import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ChartScreen({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xff6C3CC9),
      const Color(0xffFF9800),
      const Color(0xff4CAF50),
      const Color(0xff2196F3),
      const Color(0xffF44336),
      const Color(0xffE91E63),
      const Color(0xff009688),
      const Color(0xff3F51B5),
    ];

    final categories =
        categoryTotals.entries.toList();

    // SORT DESCENDING
    categories.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    double totalExpense = 0;

    for (var item in categories) {
      totalExpense += item.value;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,

        title: const Text(
          'Expense Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          child: Column(
            children: [

              // TOP CARD
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 28,
                ),

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xff5E35B1),
                      Color(0xff7E57C2),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple
                          .withOpacity(0.18),

                      blurRadius: 14,
                      offset:
                          const Offset(0, 7),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const Text(
                      'Total Expenses',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '\$${totalExpense.toStringAsFixed(2)}',

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // CHART CARD
              Container(
                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey.shade300,

                      blurRadius: 10,
                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    SizedBox(
                      height: 320,

                      child: Stack(
                        alignment: Alignment.center,

                        children: [

                          PieChart(
                            PieChartData(

                              centerSpaceRadius:
                                  65,

                              sectionsSpace: 4,

                              pieTouchData:
                                  PieTouchData(
                                enabled: true,
                              ),

                              sections:
                                  List.generate(
                                categories.length,
                                (index) {

                                  final category =
                                      categories[
                                          index];

                                  final percentage =
                                      ((category.value /
                                                  totalExpense) *
                                              100)
                                          .toStringAsFixed(
                                        1,
                                      );

                                  return PieChartSectionData(
                                    color: colors[
                                        index %
                                            colors
                                                .length],

                                    value:
                                        category
                                            .value,

                                    radius: 110,

                                    title:
                                        '$percentage%',

                                    titleStyle:
                                        const TextStyle(
                                      color: Colors
                                          .white,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // CENTER TEXT
                          Column(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              const Text(
                                'Spent',

                                style: TextStyle(
                                  color:
                                      Colors.grey,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(
                                  height: 6),

                              Text(
                                '\$${totalExpense.toStringAsFixed(0)}',

                                style:
                                    const TextStyle(
                                  color: Colors
                                      .deepPurple,

                                  fontSize: 32,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // CATEGORY LIST
              ListView.builder(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: categories.length,

                itemBuilder: (context, index) {

                  final category =
                      categories[index];

                  final percentage =
                      ((category.value /
                                  totalExpense) *
                              100)
                          .toStringAsFixed(1);

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),

                    padding:
                        const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.08),

                          blurRadius: 10,

                          offset:
                              const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        // COLOR DOT
                        Container(
                          width: 18,
                          height: 18,

                          decoration:
                              BoxDecoration(
                            color: colors[
                                index %
                                    colors.length],

                            shape:
                                BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // CATEGORY INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                category.key,

                                style:
                                    const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                '$percentage% of total',

                                style:
                                    TextStyle(
                                  color: Colors
                                      .grey.shade600,

                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // AMOUNT
                        Text(
                          '\$${category.value.toStringAsFixed(2)}',

                          style:
                              const TextStyle(
                            color:
                                Colors.deepPurple,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}