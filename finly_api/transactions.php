<?php
require 'config.php';

$uid   = (int)($_GET['user_id'] ?? 0);
$month = (int)($_GET['month'] ?? date('n'));
$year  = (int)($_GET['year'] ?? date('Y'));
if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if ($month < 1 || $month > 12 || $year < 2000 || $year > 2100)
  respond(false, 'Periode tidak valid.', [], 400);

$stmt = $pdo->prepare("
  SELECT id, type, category, amount, note, trx_date
  FROM transactions
  WHERE user_id = ? AND MONTH(trx_date)=? AND YEAR(trx_date)=?
  ORDER BY trx_date DESC, id DESC");
$stmt->execute([$uid, $month, $year]);

$rows = array_map(fn($r) => [
  'id' => (int)$r['id'],
  'type' => $r['type'],
  'category' => $r['category'],
  'amount' => (float)$r['amount'],
  'note' => $r['note'] ?? '',
  'trx_date' => $r['trx_date'],
], $stmt->fetchAll());

respond(true, 'OK', ['transactions' => $rows]);
