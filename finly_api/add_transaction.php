<?php
require 'config.php';

$d = input();
$uid      = (int)($d['user_id'] ?? 0);
$type     = $d['type'] ?? '';
$category = trim($d['category'] ?? '');
$amount   = (float)($d['amount'] ?? 0);
$note     = trim($d['note'] ?? '');
$date     = $d['trx_date'] ?? date('Y-m-d');

if ($uid <= 0)
  respond(false, 'User tidak valid.', [], 400);
if (!in_array($type, ['income', 'expense'], true))
  respond(false, 'Jenis transaksi tidak valid.', [], 400);
if ($category === '' || strlen($category) > 50)
  respond(false, 'Kategori tidak valid.', [], 400);
if ($amount <= 0 || $amount > 9999999999999)
  respond(false, 'Nominal harus lebih dari 0.', [], 400);
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date))
  respond(false, 'Format tanggal tidak valid.', [], 400);
if (strlen($note) > 255) $note = substr($note, 0, 255);

$cek = $pdo->prepare('SELECT id FROM users WHERE id = ?');
$cek->execute([$uid]);
if (!$cek->fetch()) respond(false, 'User tidak ditemukan.', [], 404);

$stmt = $pdo->prepare(
  'INSERT INTO transactions (user_id,type,category,amount,note,trx_date) VALUES (?,?,?,?,?,?)'
);
$stmt->execute([$uid, $type, $category, $amount, $note === '' ? null : $note, $date]);

respond(true, $type === 'income'
  ? 'Pemasukan berhasil disimpan.'
  : 'Pengeluaran berhasil disimpan.');
