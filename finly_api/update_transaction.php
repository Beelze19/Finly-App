<?php
require 'config.php';

$d = input();
$id       = (int)($d['id'] ?? 0);
$uid      = (int)($d['user_id'] ?? 0);
$category = trim($d['category'] ?? '');
$amount   = (float)($d['amount'] ?? 0);
$note     = trim($d['note'] ?? '');
$date     = $d['trx_date'] ?? date('Y-m-d');

if ($id <= 0 || $uid <= 0) respond(false, 'Data tidak valid.', [], 400);
if ($category === '' || strlen($category) > 50)
  respond(false, 'Kategori tidak valid.', [], 400);
if ($amount <= 0 || $amount > 9999999999999)
  respond(false, 'Nominal harus lebih dari 0.', [], 400);
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date))
  respond(false, 'Format tanggal tidak valid.', [], 400);
if (strlen($note) > 255) $note = substr($note, 0, 255);

$stmt = $pdo->prepare(
  'UPDATE transactions SET category=?, amount=?, note=?, trx_date=? WHERE id=? AND user_id=?'
);
$stmt->execute([$category, $amount, $note === '' ? null : $note, $date, $id, $uid]);

respond(true, 'Transaksi berhasil diperbarui.');
