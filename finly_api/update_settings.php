<?php
require 'config.php';

$d = input();
$uid     = (int)($d['user_id'] ?? 0);
$limit   = (int)($d['expense_limit'] ?? 0);
$savings = (int)($d['savings_target'] ?? 0);

if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if ($limit < 40 || $limit > 100) respond(false, 'Batas pengeluaran harus 40-100%.', [], 400);
if ($savings < 5 || $savings > 50) respond(false, 'Target tabungan harus 5-50%.', [], 400);
if ($limit + $savings > 100)
  respond(false, 'Batas pengeluaran + target tabungan tidak boleh lebih dari 100%.', [], 400);

$stmt = $pdo->prepare('UPDATE users SET expense_limit = ?, savings_target = ? WHERE id = ?');
$stmt->execute([$limit, $savings, $uid]);

respond(true, 'Pengaturan disimpan.', ['user' => fetch_user($pdo, $uid)]);
