<?php
require 'config.php';

$uid  = (int)($_GET['user_id'] ?? 0);
$year = (int)($_GET['year'] ?? date('Y'));
if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if ($year < 2000 || $year > 2100) respond(false, 'Tahun tidak valid.', [], 400);

$stmt = $pdo->prepare("
  SELECT MONTH(trx_date) AS m, type, SUM(amount) AS total
  FROM transactions
  WHERE user_id = ? AND YEAR(trx_date) = ?
  GROUP BY m, type");
$stmt->execute([$uid, $year]);

$months = [];
for ($i = 1; $i <= 12; $i++) $months[$i] = ['month' => $i, 'income' => 0.0, 'expense' => 0.0];
foreach ($stmt->fetchAll() as $r) {
  $months[(int)$r['m']][$r['type']] = (float)$r['total'];
}

respond(true, 'OK', ['year' => $year, 'months' => array_values($months)]);
