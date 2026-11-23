import 'package:flutter/material.dart';

import 'core.dart';

PreferredSizeWidget _appBar(String title) => AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: darkGreen,
      elevation: 0,
      scrolledUnderElevation: 0,
    );

Widget _label(String text) =>
    Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

Widget _saveButton({
  required String text,
  required bool loading,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    height: 54,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}

// =========================
// EDIT PROFIL
// =========================

class EditProfilePage extends StatefulWidget {
  final int userId;
  final String name;
  final String email;
  final String phone;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final res = await ApiService.updateProfile(
      userId: widget.userId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Terjadi kesalahan.')),
    );
    if (res['success'] == true) {
      Navigator.pop(context, res['user']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar('Edit Profil'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  initialValue: widget.email,
                  enabled: false,
                  decoration: inputDecoration(
                    hint: '',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Email tidak dapat diubah.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 20),
                _label('Nomor Telepon'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: inputDecoration(
                    hint: 'Mis. 081234567890',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    if (!RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(s)) {
                      return 'Nomor telepon tidak valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _saveButton(
                  text: 'Simpan Perubahan',
                  loading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// KEAMANAN (GANTI PASSWORD)
// =========================

class SecurityPage extends StatefulWidget {
  final int userId;

  const SecurityPage({super.key, required this.userId});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final res = await ApiService.changePassword(
      userId: widget.userId,
      oldPassword: _oldController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Terjadi kesalahan.')),
    );
    if (res['success'] == true) Navigator.pop(context);
  }

  InputDecoration _decoration(String hint) =>
      inputDecoration(hint: hint, icon: Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar('Keamanan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: primaryGreen),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gunakan password minimal 6 karakter dan jangan '
                          'dibagikan ke siapa pun.',
                          style: TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _label('Password Lama'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldController,
                  obscureText: _obscure,
                  decoration: _decoration('Masukkan password lama'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password lama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: 20),
                _label('Password Baru'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newController,
                  obscureText: _obscure,
                  decoration: _decoration('Minimal 6 karakter'),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Password baru wajib diisi.';
                    }
                    if (v.length < 6) return 'Password minimal 6 karakter.';
                    if (v == _oldController.text) {
                      return 'Password baru harus berbeda dari yang lama.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _label('Konfirmasi Password Baru'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  decoration: _decoration('Ulangi password baru'),
                  validator: (v) => v != _newController.text
                      ? 'Konfirmasi password tidak cocok.'
                      : null,
                ),
                const SizedBox(height: 32),
                _saveButton(
                  text: 'Ganti Password',
                  loading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// PENGATURAN APLIKASI
// =========================

class SettingsPage extends StatefulWidget {
  final int userId;
  final int expenseLimit;
  final int savingsTarget;

  const SettingsPage({
    super.key,
    required this.userId,
    required this.expenseLimit,
    required this.savingsTarget,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _limit;
  late double _savings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _limit = widget.expenseLimit.clamp(40, 100).toDouble();
    _savings = widget.savingsTarget.clamp(5, 50).toDouble();
  }

  bool get _valid => _limit + _savings <= 100;

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final res = await ApiService.updateSettings(
      userId: widget.userId,
      expenseLimit: _limit.round(),
      savingsTarget: _savings.round(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Terjadi kesalahan.')),
    );
    if (res['success'] == true) {
      Navigator.pop(context, res['user']);
    }
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${value.round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.round()}%',
            activeColor: primaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const example = 10000000.0;

    return Scaffold(
      appBar: _appBar('Pengaturan Aplikasi'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Atur batas keuangan sehat sesuai kebutuhanmu. Finly memakai '
                'angka ini untuk memberi peringatan dan rekomendasi tabungan.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 20),
              _card(
                icon: Icons.warning_amber_rounded,
                title: 'Batas pengeluaran sehat',
                description:
                    'Peringatan muncul jika pengeluaran melebihi persentase '
                    'ini dari pemasukan bulanan.',
                value: _limit,
                min: 40,
                max: 100,
                divisions: 12,
                onChanged: (v) => setState(() => _limit = v),
              ),
              const SizedBox(height: 14),
              _card(
                icon: Icons.savings_outlined,
                title: 'Target tabungan',
                description:
                    'Persentase pemasukan bulanan yang sebaiknya disisihkan '
                    'sebagai tabungan.',
                value: _savings,
                min: 5,
                max: 50,
                divisions: 9,
                onChanged: (v) => setState(() => _savings = v),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _valid ? lightGreen : const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _valid
                      ? 'Contoh: dengan pemasukan ${formatCurrency(example)}, '
                          'pengeluaran sehat maksimal '
                          '${formatCurrency(example * _limit / 100)} dan '
                          'tabungan ${formatCurrency(example * _savings / 100)}.'
                      : 'Batas pengeluaran + target tabungan tidak boleh lebih '
                          'dari 100%. Turunkan salah satunya.',
                  style: TextStyle(
                    height: 1.5,
                    color: _valid ? darkGreen : dangerColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _saveButton(
                text: 'Simpan Pengaturan',
                loading: _isLoading,
                onPressed: _valid ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// BANTUAN
// =========================

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const List<(String, String)> _faq = [
    (
      'Bagaimana cara mencatat transaksi?',
      'Di beranda, ketuk "Pemasukan" atau "Pengeluaran" pada Aksi Cepat. '
          'Isi nominal, pilih kategori, tanggal, lalu simpan. Kamu juga bisa '
          'menambah lewat tombol + di tab Transaksi.'
    ),
    (
      'Bagaimana mengubah atau menghapus transaksi?',
      'Buka tab Transaksi, lalu ketuk transaksi untuk mengedit, atau ketuk '
          'ikon titik tiga lalu pilih Hapus.'
    ),
    (
      'Bagaimana saldo dihitung?',
      'Saldo tersisa = total pemasukan - total pengeluaran pada bulan '
          'berjalan.'
    ),
    (
      'Apa arti status keuangan sehat, waspada, dan tidak sehat?',
      'Finly membandingkan pengeluaran dengan pemasukan bulanan. Sehat: '
          'masih di bawah batas. Waspada: sudah mencapai 85% dari batas. '
          'Tidak sehat: melewati batas. Batasnya bisa diubah di Pengaturan '
          'Aplikasi (bawaan 70%).'
    ),
    (
      'Dari mana angka rekomendasi tabungan berasal?',
      'Finly menghitung target tabungan (bawaan 20% dari pemasukan), lalu '
          'menyarankan jumlah yang bisa disimpan dari saldo yang ada, tidak '
          'lebih dari saldo tersebut.'
    ),
    (
      'Bagaimana melihat rekap bulanan?',
      'Buka tab Laporan. Di sana ada grafik 12 bulan dan rekap tiap bulan. '
          'Ketuk satu bulan untuk melihat rincian pengeluaran per kategori.'
    ),
    (
      'Bagaimana mengganti password?',
      'Buka Profil > Keamanan, lalu isi password lama dan password baru.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar('Bantuan'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pertanyaan yang sering diajukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 14),
            ..._faq.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5ECE7)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: primaryGreen,
                    size: 36,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Finly - Financial Friendly',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Versi 1.1.0',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
