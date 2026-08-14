import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  

const uuid = Uuid();

enum Category { food, travel, leisure, work, receive }
enum TransactionType { income, expense } 

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.person, 
  Category.work: Icons.work,
  Category.receive: Icons.volunteer_activism, 
};

const categoryNames = {
  Category.food: 'Ăn uống',
  Category.work: 'Công việc',
  Category.travel: 'Du lịch',
  Category.leisure: 'Cá nhân', 
  Category.receive: 'Nhận', 
};

// ĐÃ ĐỔI TỪ "đ" SANG "VND" ĐƯỢC CÁCH RA 1 KHOẢNG TRẮNG
final currencyFormatter = NumberFormat.currency(
  locale: 'vi_VN', 
  customPattern: '#,##0 VND', 
  decimalDigits: 0
);

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.type = TransactionType.expense, 
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final TransactionType type; 

  String get formattedAmount {
    return currencyFormatter.format(amount);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'type': type.name, 
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: Category.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => Category.work,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense, 
      ),
    );
  }
}