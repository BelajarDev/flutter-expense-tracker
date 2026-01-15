// models/expense.dart
import 'package:flutter/material.dart';

// Model data untuk expense/pengeluaran dengan kategori dan warna
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String description;
  final int colorIndex; // 0-5 untuk warna kategori

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    this.colorIndex = 0,
  });

  Expense.create({
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    this.colorIndex = 0,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       date = DateTime.now();

  // Method untuk mendapatkan warna berdasarkan kategori
  static Color getCategoryColor(int index) {
    final colors = [
      const Color(0xFFFF6B6B), // Makanan & Minuman
      const Color(0xFF4FC3F7), // Transportasi
      const Color(0xFF66BB6A), // Belanja
      const Color(0xFFFFB74D), // Hiburan
      const Color(0xFFBA68C8), // Kesehatan
      const Color(0xFF42A5F5), // Lainnya
    ];
    return colors[index % colors.length];
  }

  // Icon berdasarkan kategori
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_cart;
      case 'Hiburan':
        return Icons.movie;
      case 'Kesehatan':
        return Icons.medical_services;
      default:
        return Icons.category;
    }
  }
}
