import 'package:flutter/material.dart';

import 'add_transaction_sheet.dart';
import 'core.dart';

class TransactionsPage extends StatefulWidget {
  final int userId;

  /// Dinaikkan oleh HomePage setiap kali data perlu dimuat ulang.
  final int version;

  /// Dipanggil setelah transaksi diubah/dihapus agar beranda ikut diperbarui.
  final VoidCallback onChanged;

  const TransactionsPage({
    super.key,
    required this.userId,
    required this.version,
    required this.onChanged,
  });

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late int _month;
  late int _year;
  String _filter = 'all'; // all | income | expense
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _load();
  }

  @override
  void didUpdateWidget(covariant TransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.version != widget.version) _load();
  }

  Future<void> _load() async {
    final res = await ApiService.transactions(widget.userId, _month, _year);
    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(res['transactions']);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal memuat transaksi.')),
      );
    }
  }

  bool get _isCurrentMonth {
    final n = DateTime.now();
    return _month == n.month && _year == n.year;
  }

  void _shiftMonth(int delta) {
    var m = _month + delta;
    var y = _year;
    if (m < 1) {
      m = 12;
      y--;
    } else if (m > 12) {
      m = 1;
      y++;
    }
    setState(() {
      _month = m;
      _year = y;
      _loading = true;
    });
    _load();
  }

  double _total(String type) => _items
      .where((e) => e['type'] == type)
      .fold<double>(0, (s, e) => s + toDouble(e['amount']));

  List<Map<String, dynamic>> get _visible => _filter == 'all'
      ? _items
      : _items.where((e) => e['type'] == _filter).toList();

  Future<void> _add(String type) async {
    final ok = await showTransactionSheet(
      context,
      userId: widget.userId,
      type: type,
    );
    if (ok == true) {
      await _load();
      widget.onChanged();
    }
  }

  Future<void> _edit(Map<String, dynamic> t) async {
    final ok = await showTransactionSheet(
      context,
      userId: widget.userId,
      type: t['type'].toString(),
      existing: t,
    );
    if (ok == true) {
      await _load();
      widget.onChanged();
    }
  }

  Future<void> _delete(Map<String, dynamic> t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text(
          '${t['category']} sebesar ${formatCurrency(toDouble(t['amount']))} '
          'akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await ApiService.deleteTransaction(
      id: toInt(t['id'], 0),
      userId: widget.userId,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Terjadi kesalahan.')),
    );
    if (res['success'] == true) {
      await _load();
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Transaksi',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Tambah transaksi',
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: primaryGreen,
                    size: 34,
                  ),
                  onSelected: _add,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'income', child: Text('Pemasukan')),
                    PopupMenuItem(
                      value: 'expense',
                      child: Text('Pengeluaran'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // PILIH BULAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5ECE7)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${monthNames[_month - 1]} $_year',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isCurrentMonth ? null : () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // TOTAL
            Row(
              children: [
                Expanded(
                  child: _totalCard(
                    'Pemasukan',
                    _total('income'),
                    primaryGreen,
                    Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _totalCard(
                    'Pengeluaran',
                    _total('expense'),
                    Colors.redAccent,
                    Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // FILTER
            Wrap(
              spacing: 8,
              children: [
                _filterChip('Semua', 'all'),
                _filterChip('Pemasukan', 'income'),
                _filterChip('Pengeluaran', 'expense'),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_visible.isEmpty)
              _emptyState()
            else
              ..._buildList(),
          ],
        ),
      ),
    );
  }

  Widget _totalCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: lightGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? darkGreen : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? primaryGreen : const Color(0xFFDCE5E0),
      ),
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: primaryGreen.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada transaksi pada ${monthNames[_month - 1]} $_year.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList() {
    final widgets = <Widget>[];
    String? lastDate;

    for (final t in _visible) {
      final date = t['trx_date'].toString();
      if (date != lastDate) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              displayDate(date),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        );
        lastDate = date;
      }
      widgets.add(_tile(t));
    }
    return widgets;
  }

  Widget _tile(Map<String, dynamic> t) {
    final isIncome = t['type'] == 'income';
    final style = categoryStyle(t['category'].toString());
    final note = (t['note'] ?? '').toString();
    final amountColor = isIncome ? primaryGreen : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF1EE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _edit(t),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.$2.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(style.$1, color: style.$2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['category'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isIncome ? '+' : '-'} ${formatCurrency(toDouble(t['amount']))}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: 14,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.black45),
                onSelected: (v) {
                  if (v == 'edit') {
                    _edit(t);
                  } else {
                    _delete(t);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
