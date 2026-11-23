import 'package:material_ui/material_ui.dart';

import 'add_transaction_sheet.dart';
import 'core.dart';
import 'profile_pages.dart';
import 'reports_page.dart';
import 'transactions_page.dart';

void main() {
  runApp(const FinlyApp());
}

class FinlyApp extends StatelessWidget {
  const FinlyApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finly - Financial Friendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}

// =========================
// HALAMAN LOGIN
// =========================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final user = result['user'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            userId: int.parse(user['id'].toString()),
            userName: user['name'].toString(),
            userEmail: user['email'].toString(),
            userPhone: (user['phone'] ?? '').toString(),
            expenseLimit: toInt(user['expense_limit'], 70),
            savingsTarget: toInt(user['savings_target'], 20),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login gagal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // LOGO
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: primaryGreen,
                      size: 72,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Finly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),

                    const Text(
                      'FINANCIAL FRIENDLY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: 12,
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Kelola keuanganmu dengan mudah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Mulai langkah kecil menuju masa depan '
                      'finansial yang lebih baik.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputDecoration(
                        hint: 'Masukkan email kamu',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi.';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return 'Masukkan format email yang valid.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: inputDecoration(
                        hint: 'Masukkan password',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur lupa password akan dibuat nanti.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Lupa password?'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun?'),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'FINANCIAL FRIENDLY',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Atur uangmu hari ini, untuk masa depanmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// HALAMAN REGISTER
// =========================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await ApiService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan.')),
    );
    if (result['success'] == true) Navigator.pop(context);
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: darkGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Buat Akun Finly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Daftar dan mulai kelola keuanganmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    _label('Nama Lengkap'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: inputDecoration(
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _label('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputDecoration(
                        hint: 'Masukkan email kamu',
                        icon: Icons.email_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email wajib diisi.';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim())) {
                          return 'Masukkan format email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: inputDecoration(
                        hint: 'Minimal 6 karakter',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi.';
                        }
                        if (v.length < 6) return 'Password minimal 6 karakter.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('Konfirmasi Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscurePassword,
                      decoration: inputDecoration(
                        hint: 'Ulangi password',
                        icon: Icons.lock_outline,
                      ),
                      validator: (v) => v != _passwordController.text
                          ? 'Konfirmasi password tidak cocok.'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun?'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Masuk'),
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
    );
  }
}

// =========================
// HALAMAN HOME
// =========================

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final int expenseLimit;
  final int savingsTarget;

  const HomePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone = '',
    this.expenseLimit = 70,
    this.savingsTarget = 20,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showBalance = true;

  /// Dinaikkan setiap data perlu dimuat ulang oleh tab Transaksi & Laporan.
  int _version = 0;

  late String _name;
  late String _phone;
  late int _expenseLimit;
  late int _savingsTarget;

  double income = 0;
  double expense = 0;
  List<Map<String, dynamic>> _categories = [];

  String get formattedBalance => formatCurrency(income - expense);

  double get _balance => income - expense;

  String get _initials {
    final parts = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();
    return parts.isEmpty ? '?' : parts;
  }

  // ---------- Kesehatan keuangan ----------

  FinanceHealth get _status =>
      evaluateHealth(income, expense, _expenseLimit);

  int get _expensePct =>
      income > 0 ? ((expense / income) * 100).round() : 0;

  String get _topCategoryHint => _categories.isNotEmpty
      ? ' Pengeluaran terbesar: ${_categories.first['name']}.'
      : '';

  String get _saranTitle {
    switch (_status) {
      case FinanceHealth.healthy:
        return 'Yuk, pertahankan kebiasaan baikmu!';
      case FinanceHealth.warning:
        return 'Hati-hati, pengeluaranmu mulai tinggi.';
      case FinanceHealth.danger:
        return 'Saatnya mengerem pengeluaran!';
    }
  }

  String get _healthMessage {
    switch (_status) {
      case FinanceHealth.healthy:
        return 'Pengeluaranmu masih dalam batas sehat. Pertahankan!';
      case FinanceHealth.warning:
        return 'Pengeluaranmu sudah $_expensePct% dari pemasukan, mendekati '
            'batas sehat $_expenseLimit%. Mulai kurangi pengeluaran yang '
            'tidak perlu.$_topCategoryHint';
      case FinanceHealth.danger:
        if (income <= 0) {
          return 'Kamu sudah mengeluarkan ${formatCurrency(expense)} bulan '
              'ini, tetapi belum ada pemasukan tercatat.$_topCategoryHint';
        }
        return 'Pengeluaranmu sudah $_expensePct% dari pemasukan, melewati '
            'batas sehat $_expenseLimit%. Tahan pengeluaran yang tidak '
            'mendesak.$_topCategoryHint';
    }
  }

  // ---------- Rekomendasi tabungan ----------

  double get _savingsGoal => income * _savingsTarget / 100;

  double get _recommendedSave =>
      _balance <= 0 ? 0 : (_balance < _savingsGoal ? _balance : _savingsGoal);

  @override
  void initState() {
    super.initState();
    _name = widget.userName;
    _phone = widget.userPhone;
    _expenseLimit = widget.expenseLimit;
    _savingsTarget = widget.savingsTarget;
    _loadSummary(alert: true);
  }

  Future<void> _loadSummary({bool alert = false}) async {
    final res = await ApiService.summary(widget.userId);
    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        income = toDouble(res['income']);
        expense = toDouble(res['expense']);
        _categories = List<Map<String, dynamic>>.from(res['categories']);
      });
      if (alert) _maybeShowAlert();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal memuat data.')),
      );
    }
  }

  /// Dialog peringatan hanya muncul saat kondisi tidak sehat.
  void _maybeShowAlert() {
    if (!mounted || _status != FinanceHealth.danger) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: dangerColor,
          size: 40,
        ),
        title: const Text('Pengeluaran Tidak Sehat'),
        content: Text(_healthMessage),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showNotification() {
    final hasAlert = _status != FinanceHealth.healthy;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasAlert ? _healthMessage : 'Belum ada notifikasi baru.',
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _openAddTransaction(String type) async {
    final added = await showTransactionSheet(
      context,
      userId: widget.userId,
      type: type,
    );

    if (added == true) {
      setState(() => _version++);
      await _loadSummary(alert: type == 'expense');
    }
  }

  // ---------- Navigasi profil ----------

  Future<void> _openEditProfile() async {
    final user = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          userId: widget.userId,
          name: _name,
          email: widget.userEmail,
          phone: _phone,
        ),
      ),
    );
    if (user != null && mounted) {
      setState(() {
        _name = user['name'].toString();
        _phone = (user['phone'] ?? '').toString();
      });
    }
  }

  Future<void> _openSettings() async {
    final user = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          userId: widget.userId,
          expenseLimit: _expenseLimit,
          savingsTarget: _savingsTarget,
        ),
      ),
    );
    if (user != null && mounted) {
      setState(() {
        _expenseLimit = toInt(user['expense_limit'], _expenseLimit);
        _savingsTarget = toInt(user['savings_target'], _savingsTarget);
      });
    }
  }

  void _openSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SecurityPage(userId: widget.userId)),
    );
  }

  void _openHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpPage()),
    );
  }

  // ---------- Kartu peringatan & tabungan ----------

  Widget _buildHealthAlert() {
    final isDanger = _status == FinanceHealth.danger;
    final color = healthColor(_status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xFFFDECEA) : const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isDanger
                      ? 'Peringatan: Pengeluaran Tidak Sehat'
                      : 'Waspada: Pengeluaran Mulai Tinggi',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _healthMessage,
            style: const TextStyle(height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: income > 0
                ? (expense / income).clamp(0.0, 1.0)
                : (expense > 0 ? 1.0 : 0.0),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.white,
            color: color,
          ),
          const SizedBox(height: 6),
          Text(
            income > 0
                ? '$_expensePct% terpakai - batas sehat $_expenseLimit%'
                : 'Belum ada pemasukan bulan ini',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard() {
    String money(double v) => _showBalance ? formatCurrency(v) : 'Rp •••••••';

    final hasBalance = _balance > 0;
    final reachedGoal = hasBalance && _balance >= _savingsGoal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.savings_outlined, color: primaryGreen, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rekomendasi Tabungan',
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasBalance)
            Text(
              income <= 0
                  ? 'Catat pemasukanmu dulu supaya Finly bisa menghitung '
                      'berapa yang sebaiknya kamu tabung.'
                  : 'Saldo bulan ini belum cukup untuk menabung. Fokus '
                      'menyeimbangkan pengeluaran dulu ya.',
              style: const TextStyle(height: 1.5, color: Colors.black87),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sebaiknya disimpan',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          money(_recommendedSave),
                          style: const TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sisa untuk kebutuhan',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          money(_balance - _recommendedSave),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: _savingsGoal > 0
                  ? (_recommendedSave / _savingsGoal).clamp(0.0, 1.0)
                  : 0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: lightGreen,
              color: primaryGreen,
            ),
            const SizedBox(height: 10),
            Text(
              reachedGoal
                  ? 'Target tabungan $_savingsTarget% dari pemasukan '
                      '(${money(_savingsGoal)}) bisa terpenuhi dari saldomu '
                      'saat ini.'
                  : 'Target tabungan $_savingsTarget% dari pemasukan '
                      '(${money(_savingsGoal)}) belum sepenuhnya tercapai, '
                      'jadi sebaiknya simpan seluruh saldo yang ada.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (_status == FinanceHealth.danger) ...[
              const SizedBox(height: 8),
              const Text(
                'Karena pengeluaran sedang tidak sehat, sisihkan tabungan '
                'lebih dulu sebelum berbelanja lagi.',
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          TransactionsPage(
            userId: widget.userId,
            version: _version,
            onChanged: () => _loadSummary(),
          ),
          ReportsPage(
            userId: widget.userId,
            version: _version,
            expenseLimit: _expenseLimit,
          ),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            // muat ulang data tab Transaksi & Laporan saat dibuka
            if (index == 1 || index == 2) _version++;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategories() {
    if (_categories.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Belum ada pengeluaran bulan ini.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ];
    }

    return _categories.map((c) {
      final amount = toDouble(c['amount']);
      final style = categoryStyle(c['name'].toString());
      return _expenseCategory(
        icon: style.$1,
        name: c['name'].toString(),
        amount: amount,
        percentage: expense > 0 ? (amount / expense).clamp(0.0, 1.0) : 0,
        color: style.$2,
      );
    }).toList();
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: primaryGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finly',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      Text(
                        'Financial Friendly',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showNotification,
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Halo, teman Finly! 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Yuk, kelola keuanganmu lebih baik hari ini.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // KARTU SALDO
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryGreen, darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Saldo Tersisa',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() {
                            _showBalance = !_showBalance;
                          });
                        },
                        icon: Icon(
                          _showBalance
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    _showBalance ? formattedBalance : 'Rp •••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(color: Colors.white30),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _moneySummary(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Pemasukan',
                          amount: income,
                          positive: true,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 55,
                        color: Colors.white30,
                      ),
                      Expanded(
                        child: _moneySummary(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Pengeluaran',
                          amount: expense,
                          positive: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PERINGATAN KESEHATAN KEUANGAN
            if (_status != FinanceHealth.healthy) ...[
              _buildHealthAlert(),
              const SizedBox(height: 24),
            ],

            // SARAN FINANSIAL
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: primaryGreen,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Saran Finly',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _saranTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Pengeluaranmu '
                    '${income > 0 ? ((expense / income) * 100).round() : 0}% '
                    'dari pemasukan bulan ini. '
                    'Sebagai panduan awal, kamu bisa menargetkan '
                    'pengeluaran maksimal $_expenseLimit% dari pemasukan, '
                    'menyesuaikannya dengan kebutuhan pokokmu.',
                    style: const TextStyle(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // REKOMENDASI TABUNGAN
            _buildSavingsCard(),

            const SizedBox(height: 28),

            // AKSI CEPAT
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Pemasukan',
                    color: Colors.green,
                    onTap: () => _openAddTransaction('income'),
                  ),
                ),
                Expanded(
                  child: _quickAction(
                    icon: Icons.remove_circle_outline_rounded,
                    label: 'Pengeluaran',
                    color: Colors.redAccent,
                    onTap: () => _openAddTransaction('expense'),
                  ),
                ),
                Expanded(
                  child: _quickAction(
                    icon: Icons.insert_chart_outlined_rounded,
                    label: 'Laporan',
                    color: Colors.blue,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
                Expanded(
                  child: _quickAction(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    color: Colors.deepPurple,
                    onTap: () => _showFeatureMessage('Kategori'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // RINGKASAN PENGELUARAN
            const Text(
              'Ringkasan Pengeluaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ..._buildCategories(),
          ],
        ),
      ),
    );
  }

  Widget _moneySummary({
    required IconData icon,
    required String label,
    required double amount,
    required bool positive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: positive ? Colors.greenAccent : Colors.orangeAccent,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _showBalance ? formatCurrency(amount) : 'Rp •••••••',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseCategory({
    required IconData icon,
    required String name,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF1EE)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatCurrency(amount),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: const Color(0xFFEDF1EE),
                  color: color,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${(percentage * 100).round()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Text(
              'Profil Saya',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightGreen,
                border: Border.all(color: primaryGreen, width: 3),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _name,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              widget.userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: _openEditProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profil'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          _profileCard(
            icon: Icons.person_outline_rounded,
            title: 'Nama Lengkap',
            subtitle: _name,
          ),
          _profileCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: widget.userEmail,
          ),
          _profileCard(
            icon: Icons.phone_outlined,
            title: 'Nomor Telepon',
            subtitle: _phone.isEmpty ? 'Belum diisi' : _phone,
          ),
          const SizedBox(height: 22),
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          _profileMenu(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Aplikasi',
            subtitle: 'Atur preferensi aplikasi',
            onTap: _openSettings,
          ),
          _profileMenu(
            icon: Icons.lock_outline_rounded,
            title: 'Keamanan',
            subtitle: 'Kelola keamanan akun',
            onTap: _openSecurity,
          ),
          _profileMenu(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan',
            subtitle: 'Informasi dan bantuan Finly',
            onTap: _openHelp,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar dari Akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5ECE7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Icon(icon, color: primaryGreen, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black45,
        ),
        onTap: onTap,
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari Finly?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showFeatureMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur $feature akan kita buat pada tahap berikutnya.',
        ),
      ),
    );
  }
}

