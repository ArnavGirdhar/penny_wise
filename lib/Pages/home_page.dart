import 'dart:ffi';
import 'dart:io';

import 'package:chat_app_final/Components/my_list_tile.dart';
import 'package:chat_app_final/Database/expense_database.dart';
import 'package:chat_app_final/Helper/helper_function.dart';
import 'package:chat_app_final/bar_graph/bar_graph.dart';
import 'package:chat_app_final/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Modles/expense.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<int, double>>? _monthlyTotalFuture;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshGraph();
  }



  void refreshGraph() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
  }

  //open new expense bar
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),

            //user input -> expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            )
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),
          //save button
          _createNewExpenseButton()
        ],
      ),
    );
  }

  //open edit box
  void openEditBox(Expense expense) {
    //pre-fill existing values into text fields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //user input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),

            //user input -> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),
          //save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
        ),
        actions: [
          //cancel button
          _cancelButton(),
          //delete button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      //get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      //calculate the number of months since first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //only display the expenses for the current month
      Future<double?> getCurrentMonthExpense() async {
        return Provider.of<ExpenseDatabase>(context, listen: false).currentMonthExpense;
      }
      //double? currentMonthExpense=Provider.of<ExpenseDatabase>(context).currentMonthExpense;

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double?>(future: getCurrentMonthExpense(), builder: (context,snapshot) {
              //loaded
              if(snapshot.connectionState==ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //amount total
                    Text('\₹${value.currentMonthExpense?.toStringAsFixed(0) ?? '0'}',style: GoogleFonts.bebasNeue(),),

                    //month
                    Text(getCurrentMonthName(),style: GoogleFonts.bebasNeue(),),
                  ],
                );
              }
              else{
                return const Text("Loading...",style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),);
              }
            }),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                //graph UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                      future: _monthlyTotalFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final monthlyTotals = snapshot.data ?? {};
                          List<double> monthlySummary = List.generate(
                              monthCount,
                              (index) =>
                                  monthlyTotals[startMonth + index] ?? 0.0);


                              double? currentMonthExpense=monthlyTotals[currentMonth];
                              Provider.of<ExpenseDatabase>(context,listen:false).setCurrentMonthExpense(currentMonthExpense);
                              //print("current month total is $currentMonthExpense");
                              //print("monthly summary is $monthlyTotals");
                              //print("current month is $currentMonth");

                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth,
                          );
                        } else {
                          return const Center(
                            child: Text("Loading..."),
                          );
                        }
                      }),
                ),
                const SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: value.allExpense.length,
                      itemBuilder: (context, index) {
                        Expense individualExpense = value.allExpense[index];
                        print(individualExpense.currMon);
                        return MyListTile(
                            title: individualExpense.name,
                            trailing: formatAmount(individualExpense.amount),
                            currMon: individualExpense.currMon,
                            onEditPressed: (context) =>
                                openEditBox(individualExpense),
                            onDeletePressed: (context) =>
                                openDeleteBox(individualExpense),
                          );
                      }),
                ),
              ],
            ),
          ));
    });
  }

  //CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  //SAVE BUTTON
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //only save when there is something in the text field
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              currMon: getCurrentMonthName(),
              date: DateTime.now());

          //save to database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          refreshGraph();

          //clear controllers
          amountController.clear();
          nameController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  //EDIT BUTTON
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //edit expense
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              currMon: getCurrentMonthName(),
              date: DateTime.now());
          int existingId = expense.id;

          //save to database
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          refreshGraph();

          //clear controllers
          amountController.clear();
          nameController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  //DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshGraph();
      },
      child: const Text("Delete"),
    );
  }
}
