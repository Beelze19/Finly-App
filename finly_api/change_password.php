<?php
require 'config.php';

$d = input();
$uid = (int)($d['user_id'] ?? 0);
$old = $d['old_password'] ?? '';
$new = $d['new_password'] ?? '';

if ($uid <= 0) respond(false, 'User tidak valid.', [], 400);
if (strlen($new) < 6) respond(false, 'Password baru minimal 6 karakter.', [], 400);

$stmt = $pdo->prepare('SELECT password FROM users WHERE id = ?');
$stmt->execute([$uid]);
$row = $stmt->fetch();

if (!$row || !password_verify($old, $row['password']))
  respond(false, 'Password lama salah.', [], 401);

$up = $pdo->prepare('UPDATE users SET password = ? WHERE id = ?');
$up->execute([password_hash($new, PASSWORD_DEFAULT), $uid]);

respond(true, 'Password berhasil diganti.');
