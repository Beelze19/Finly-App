<?php
require 'config.php';

$d = input();
$id  = (int)($d['id'] ?? 0);
$uid = (int)($d['user_id'] ?? 0);
if ($id <= 0 || $uid <= 0) respond(false, 'Data tidak valid.', [], 400);

$stmt = $pdo->prepare('DELETE FROM transactions WHERE id = ? AND user_id = ?');
$stmt->execute([$id, $uid]);

if ($stmt->rowCount() === 0) respond(false, 'Transaksi tidak ditemukan.', [], 404);
respond(true, 'Transaksi dihapus.');
