import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// =========================
// WARNA
// =========================

const Color primaryGreen = Color(0xFF138765);
const Color darkGreen = Color(0xFF075C46);
const Color lightGreen = Color(0xFFE4F5EC);
const Color backgroundColor = Color(0xFFF7FAF8);

const Color dangerColor = Color(0xFFD32F2F);
const Color warningColor = Color(0xFFF57C00);

// =========================
// HELPER UMUM
// =========================

const List<String> monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const List<String> monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

int toInt(dynamic v, int fallback) =>
    int.tryParse(v?.toString() ?? '') ?? fallback;

double toDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

String formatCurrency(double amount) {
  final negative = amount < 0;
  final digits = amount.abs().round().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return '${negative ? '-' : ''}Rp $formatted';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// DateTime -> "2026-11-18" (untuk dikirim ke API)
String apiDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

/// "2026-11-18" -> "18 Nov 2026"
String displayDate(String apiDateString) {
  final p = apiDateString.split('-');
  if (p.length != 3) return apiDateString;
  final m = int.tryParse(p[1]) ?? 1;
  return '${int.tryParse(p[2]) ?? p[2]} ${monthShort[(m - 1).clamp(0, 11)]} ${p[0]}';
}

InputDecoration inputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: primaryGreen),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDCE5E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDCE5E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: primaryGreen,
        width: 1.5,
      ),
    ),
  );
}

/// Ikon & warna untuk setiap kategori.
(IconData, Color) categoryStyle(String name) {
  switch (name) {
    case 'Makanan & Minuman':
      return (Icons.restaurant_outlined, Colors.orange);
    case 'Transportasi':
      return (Icons.directions_bus_outlined, Colors.blue);
    case 'Tagihan & Utilitas':
      return (Icons.receipt_outlined, Colors.deepPurple);
    case 'Belanja':
      return (Icons.shopping_bag_outlined, Colors.pink);
    case 'Gaji':
      return (Icons.work_outline_rounded, Colors.green);
    case 'Bonus':
      return (Icons.card_giftcard_rounded, Colors.teal);
    case 'Usaha':
      return (Icons.storefront_outlined, Colors.indigo);
    case 'Hadiah':
      return (Icons.redeem_rounded, Colors.amber.shade800);
    default:
      return (Icons.category_outlined, Colors.teal);
  }
}

// =========================
// KESEHATAN KEUANGAN
// =========================

enum FinanceHealth { healthy, warning, danger }

/// [limit] = batas pengeluaran sehat dalam persen dari pemasukan.
FinanceHealth evaluateHealth(double income, double expense, int limit) {
  if (expense <= 0) return FinanceHealth.healthy;
  if (income <= 0) return FinanceHealth.danger;

  final pct = expense / income * 100;
  if (pct > limit) return FinanceHealth.danger;
  if (pct >= limit * 0.85) return FinanceHealth.warning;
  return FinanceHealth.healthy;
}

String healthLabel(FinanceHealth h) {
  switch (h) {
    case FinanceHealth.healthy:
      return 'Sehat';
    case FinanceHealth.warning:
      return 'Waspada';
    case FinanceHealth.danger:
      return 'Tidak sehat';
  }
}

Color healthColor(FinanceHealth h) {
  switch (h) {
    case FinanceHealth.healthy:
      return primaryGreen;
    case FinanceHealth.warning:
      return warningColor;
    case FinanceHealth.danger:
      return dangerColor;
  }
}

// =========================
// API SERVICE
// =========================

class ApiService {
  // Emulator Android : http://10.0.2.2/finly_api
  // HP asli          : http://IP_KOMPUTER_ANDA/finly_api  (mis. 192.168.1.5)
  // Chrome / Windows : http://localhost/finly_api
  static const String baseUrl = 'http://localhost/finly_api';

  static Map<String, dynamic> _offline() => {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.',
      };

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return _offline();
    }
  }

  static Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: query);
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return _offline();
    }
  }

  // ---------- Akun ----------

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) =>
      _post('register.php', {
        'name': name,
        'email': email,
        'password': password,
      });

  static Future<Map<String, dynamic>> login(String email, String password) =>
      _post('login.php', {'email': email, 'password': password});

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String phone,
  }) =>
      _post('update_profile.php', {
        'user_id': userId,
        'name': name,
        'phone': phone,
      });

  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) =>
      _post('change_password.php', {
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
      });

  static Future<Map<String, dynamic>> updateSettings({
    required int userId,
    required int expenseLimit,
    required int savingsTarget,
  }) =>
      _post('update_settings.php', {
        'user_id': userId,
        'expense_limit': expenseLimit,
        'savings_target': savingsTarget,
      });

  // ---------- Transaksi ----------

  static Future<Map<String, dynamic>> addTransaction({
    required int userId,
    required String type, // 'income' | 'expense'
    required String category,
    required double amount,
    String note = '',
    required String date,
  }) =>
      _post('add_transaction.php', {
        'user_id': userId,
        'type': type,
        'category': category,
        'amount': amount,
        'note': note,
        'trx_date': date,
      });

  static Future<Map<String, dynamic>> updateTransaction({
    required int id,
    required int userId,
    required String category,
    required double amount,
    String note = '',
    required String date,
  }) =>
      _post('update_transaction.php', {
        'id': id,
        'user_id': userId,
        'category': category,
        'amount': amount,
        'note': note,
        'trx_date': date,
      });

  static Future<Map<String, dynamic>> deleteTransaction({
    required int id,
    required int userId,
  }) =>
      _post('delete_transaction.php', {'id': id, 'user_id': userId});

  static Future<Map<String, dynamic>> transactions(
    int userId,
    int month,
    int year,
  ) =>
      _get('transactions.php', {
        'user_id': '$userId',
        'month': '$month',
        'year': '$year',
      });

  // ---------- Ringkasan & Laporan ----------

  static Future<Map<String, dynamic>> summary(
    int userId, {
    int? month,
    int? year,
  }) =>
      _get('summary.php', {
        'user_id': '$userId',
        if (month != null) 'month': '$month',
        if (year != null) 'year': '$year',
      });

  static Future<Map<String, dynamic>> report(int userId, int year) =>
      _get('report.php', {'user_id': '$userId', 'year': '$year'});
}
