<?php
require 'config.php';

$d = input();
$uid   = (int)($d['user_id'] ?? 0);
$name  = trim($d['name'] ?? '');
$phone = trim($d['phone'] ?? '');

if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if ($name === '' || strlen($name) > 100) respond(false, 'Nama tidak valid.', [], 400);
if (!preg_match('/^[0-9+\-\s]{0,20}$/', $phone))
  respond(false, 'Nomor telepon tidak valid.', [], 400);

$stmt = $pdo->prepare('UPDATE users SET name = ?, phone = ? WHERE id = ?');
$stmt->execute([$name, $phone === '' ? null : $phone, $uid]);

respond(true, 'Profil berhasil diperbarui.', ['user' => fetch_user($pdo, $uid)]);
