<?php
require 'config.php';

$uid   = (int)($_GET['user_id'] ?? 0);
$month = (int)($_GET['month'] ?? date('n'));
$year  = (int)($_GET['year'] ?? date('Y'));
if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if ($month < 1 || $month > 12 || $year < 2000 || $year > 2100)
  respond(false, 'Periode tidak valid.', [], 400);

$t = $pdo->prepare("
  SELECT type, COALESCE(SUM(amount),0) AS total
  FROM transactions
  WHERE user_id = ? AND MONTH(trx_date)=? AND YEAR(trx_date)=?
  GROUP BY type");
$t->execute([$uid, $month, $year]);
$income = 0; $expense = 0;
foreach ($t->fetchAll() as $r) {
  if ($r['type'] === 'income') $income = (float)$r['total'];
  else $expense = (float)$r['total'];
}

$c = $pdo->prepare("
  SELECT category AS name, SUM(amount) AS amount
  FROM transactions
  WHERE user_id = ? AND type='expense'
    AND MONTH(trx_date)=? AND YEAR(trx_date)=?
  GROUP BY category ORDER BY amount DESC");
$c->execute([$uid, $month, $year]);

respond(true, 'OK', [
  'income' => $income,
  'expense' => $expense,
  'categories' => array_map(
    fn($r) => ['name' => $r['name'], 'amount' => (float)$r['amount']],
    $c->fetchAll()
  ),
]);
