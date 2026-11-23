import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'core.dart';

class ReportsPage extends StatefulWidget {
  final int userId;
  final int version;

  /// Batas pengeluaran sehat (% dari pemasukan).
  final int expenseLimit;

  const ReportsPage({
    super.key,
    required this.userId,
    required this.version,
    required this.expenseLimit,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late int _year;
  List<Map<String, dynamic>> _months = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
    _load();
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.version != widget.version) _load();
  }

  Future<void> _load() async {
    final res = await ApiService.report(widget.userId, _year);
    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _months = List<Map<String, dynamic>>.from(res['months']);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gagal memuat laporan.')),
      );
    }
  }

  void _shiftYear(int delta) {
    setState(() {
      _year += delta;
      _loading = true;
    });
    _load();
  }

  double _sum(String key) =>
      _months.fold<double>(0, (s, m) => s + toDouble(m[key]));

  void _openDetail(int month) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MonthDetailSheet(
        userId: widget.userId,
        month: month,
        year: _year,
        limit: widget.expenseLimit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _sum('income');
    final totalExpense = _sum('expense');

    final active = _months
        .where((m) => toDouble(m['income']) > 0 || toDouble(m['expense']) > 0)
        .toList()
        .reversed
        .toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Laporan',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 16),

            // PILIH TAHUN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5ECE7)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _shiftYear(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Tahun $_year',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _year >= DateTime.now().year
                        ? null
                        : () => _shiftYear(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _yearCard(totalIncome, totalExpense),
              const SizedBox(height: 16),
              _chartCard(),
              const SizedBox(height: 24),
              const Text(
                'Rekap Bulanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ketuk bulan untuk melihat rincian kategori.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: primaryGreen.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data untuk tahun $_year.',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                )
              else
                ...active.map(_monthTile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _yearCard(double income, double expense) {
    final net = income - expense;
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Selisih Tahun $_year',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrency(net),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _yearStat(
                  'Total Pemasukan',
                  income,
                  Icons.arrow_downward_rounded,
                  Colors.greenAccent,
                ),
              ),
              Container(width: 1, height: 48, color: Colors.white30),
              Expanded(
                child: _yearStat(
                  'Total Pengeluaran',
                  expense,
                  Icons.arrow_upward_rounded,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _yearStat(String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(amount),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    double maxV = 0;
    for (final m in _months) {
      maxV = max(maxV, max(toDouble(m['income']), toDouble(m['expense'])));
    }
    const chartH = 120.0;

    double h(double v) {
      if (v <= 0 || maxV <= 0) return 0;
      return max(3.0, v / maxV * chartH);
    }

    Widget bar(double height, Color color) => Container(
          width: 7,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(3),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Grafik Bulanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              _legend('Masuk', primaryGreen),
              const SizedBox(width: 12),
              _legend('Keluar', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final m in _months)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: chartH,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            bar(h(toDouble(m['income'])), primaryGreen),
                            const SizedBox(width: 2),
                            bar(h(toDouble(m['expense'])), Colors.redAccent),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        monthShort[toInt(m['month'], 1) - 1],
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _monthTile(Map<String, dynamic> m) {
    final month = toInt(m['month'], 1);
    final income = toDouble(m['income']);
    final expense = toDouble(m['expense']);
    final health = evaluateHealth(income, expense, widget.expenseLimit);
    final color = healthColor(health);
    final pct = income > 0 ? (expense / income * 100).round() : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF1EE)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(month),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${monthNames[month - 1]} $_year',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      healthLabel(health),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _miniStat('Pemasukan', income, primaryGreen)),
                  Expanded(
                    child: _miniStat('Pengeluaran', expense, Colors.redAccent),
                  ),
                  Expanded(
                    child: _miniStat(
                      'Saldo',
                      income - expense,
                      income - expense >= 0 ? darkGreen : dangerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: income > 0
                    ? (expense / income).clamp(0.0, 1.0)
                    : (expense > 0 ? 1.0 : 0.0),
                minHeight: 5,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: const Color(0xFFEDF1EE),
                color: color,
              ),
              const SizedBox(height: 6),
              Text(
                pct == null
                    ? 'Belum ada pemasukan bulan ini'
                    : 'Pengeluaran $pct% dari pemasukan (batas sehat '
                        '${widget.expenseLimit}%)',
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================
// RINCIAN PER BULAN
// =========================

class _MonthDetailSheet extends StatefulWidget {
  final int userId;
  final int month;
  final int year;
  final int limit;

  const _MonthDetailSheet({
    required this.userId,
    required this.month,
    required this.year,
    required this.limit,
  });

  @override
  State<_MonthDetailSheet> createState() => _MonthDetailSheetState();
}

class _MonthDetailSheetState extends State<_MonthDetailSheet> {
  bool _loading = true;
  String? _error;
  double _income = 0;
  double _expense = 0;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.summary(
      widget.userId,
      month: widget.month,
      year: widget.year,
    );
    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _income = toDouble(res['income']);
        _expense = toDouble(res['expense']);
        _categories = List<Map<String, dynamic>>.from(res['categories']);
        _loading = false;
      });
    } else {
      setState(() {
        _error = res['message']?.toString() ?? 'Gagal memuat rincian.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = evaluateHealth(_income, _expense, widget.limit);
    final color = healthColor(health);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
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
          Text(
            '${monthNames[widget.month - 1]} ${widget.year}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(_error!)),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _row('Pemasukan', formatCurrency(_income), primaryGreen),
                  const SizedBox(height: 8),
                  _row('Pengeluaran', formatCurrency(_expense), Colors.redAccent),
                  const Divider(height: 20),
                  _row(
                    'Saldo',
                    formatCurrency(_income - _expense),
                    _income - _expense >= 0 ? darkGreen : dangerColor,
                    bold: true,
                  ),
                  const SizedBox(height: 8),
                  _row('Kondisi', healthLabel(health), color, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengeluaran per Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_categories.isEmpty)
              const Text(
                'Tidak ada pengeluaran pada bulan ini.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ..._categories.map((c) {
                final amount = toDouble(c['amount']);
                final style = categoryStyle(c['name'].toString());
                final pct = _expense > 0 ? amount / _expense : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: style.$2.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(style.$1, color: style.$2, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c['name'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(pct * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              formatCurrency(amount),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: const Color(0xFFEDF1EE),
                              color: style.$2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color, {bool bold = false}) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
