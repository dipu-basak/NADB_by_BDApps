import 'dart:io';

void main(){
    stdout.write("Income: ");
    double income = double.tryParse(stdin.readLineSync() ?? "0") ?? 0;

    List<Map<String, double>> expenses = [
        {"Food": 0},
        {"Rent": 0},
        {"Transport": 0}
    ];

    for (var expense in expenses) {
        String category = expense.keys.first;
        stdout.write("$category Expense: ");
        double amount = double.tryParse(stdin.readLineSync() ?? "0") ?? 0;
        expense[category] = amount;
    }
    double totalExpenses = expenses.fold(0, (sum, expense) => sum + expense.values.first);
    double balance = income - totalExpenses;
    

    print("\nSummary");
    print("Income: ${income.toStringAsFixed(2)}");
    print("Total Expenses: ${totalExpenses.toStringAsFixed(2)}");
    print("Balance: ${balance.toStringAsFixed(2)}");
    
}