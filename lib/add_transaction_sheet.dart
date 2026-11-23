import 'package:flutter/material.dart.';
import 'package:flutter/services.dart';

import 'core.dart';

const List<String> incomeCategories = [
  'Gaji',
  'Bonus',
  'Usaha',
  'Hadiah',
  'Lainnya',
];

const List<String> expenseCategories = [
  'Makanan & Minuman',
  'Transportasi',
  'Tagihan & Utilitas',
  'Belanja',
  'Lainnya',
];

/// Menampilkan form tambah / edit transaksi.
/// Mengembalikan `true` jika data berhasil disimpan.
Future<bool?> showTransactionSheet(
  BuildContext context, {
  required int userId,
  required String type,
  Map<String, dynamic>? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AddTransactionSheet(
      userId: userId,
      type: type,
      existing: existing,
    ),
  );
}

class AddTransactionSheet extends StatefulWidget {
  final int userId;
  final String type; // 'income' | 'expense'
  final Map<String, dynamic>? existing;

  const AddTransactionSheet({
    super.key,
    required this.userId,
    required this.type,
    this.existing,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();

  late String _category;
  late DateTime _date;
  bool _isLoading = false;

  bool get _isIncome => widget.type == 'income';
  bool get _isEdit => widget.existing != null;

  late final List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List<String>.from(
      _isIncome ? incomeCategories : expenseCategories,
    );

    final e = widget.existing;
    if (e != null) {
      _amountController.text = toDouble(e['amount']).round().toString();
      _noteController.text = (e['note'] ?? '').toString();
      _date = DateTime.tryParse(e['trx_date'].toString()) ?? DateTime.now();
      _category = e['category'].toString();
      if (!_categories.contains(_category)) _categories.add(_category);
    } else {
      _date = DateTime.now();
      _category = _categories.first;
    }
    _dateController.text = displayDate(apiDate(_date));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = displayDate(apiDate(picked));
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();

    final Map<String, dynamic> result;
    if (_isEdit) {
      result = await ApiService.updateTransaction(
        id: toInt(widget.existing!['id'], 0),
        userId: widget.userId,
        category: _category,
        amount: amount,
        note: note,
        date: apiDate(_date),
      );
    } else {
      result = await ApiService.addTransaction(
        userId: widget.userId,
        type: widget.type,
        category: _category,
        amount: amount,
        note: note,
        date: apiDate(_date),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan.')),
    );

    if (result['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isIncome ? primaryGreen : Colors.redAccent;
    final title = _isEdit
        ? (_isIncome ? 'Edit Pemasukan' : 'Edit Pengeluaran')
        : (_isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isIncome
                          ? Icons.add_circle_outline_rounded
                          : Icons.remove_circle_outline_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Nominal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration(
                  hint: '0',
                  icon: Icons.payments_outlined,
                ).copyWith(prefixText: 'Rp '),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nominal wajib diisi.';
                  final n = double.tryParse(v) ?? 0;
                  if (n <= 0) return 'Nominal harus lebih dari 0.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _categories.map((c) {
                  final selected = c == _category;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    selectedColor: lightGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? darkGreen : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color:
                          selected ? primaryGreen : const Color(0xFFDCE5E0),
                    ),
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tanggal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: inputDecoration(
                  hint: 'Pilih tanggal',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Catatan (opsional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLength: 255,
                decoration: inputDecoration(
                  hint: 'Mis. makan siang',
                  icon: Icons.edit_note_rounded,
                ).copyWith(counterText: ''),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _isLoading ? null : _save,
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
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Simpan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
