<?php
require 'config.php';

$d = input();
$email = strtolower(trim($d['email'] ?? ''));
$pass  = $d['password'] ?? '';

$stmt = $pdo->prepare('SELECT id,password FROM users WHERE email = ?');
$stmt->execute([$email]);
$row = $stmt->fetch();

if (!$row || !password_verify($pass, $row['password']))
  respond(false, 'Email atau password salah.', [], 401);

respond(true, 'Login berhasil.', ['user' => fetch_user($pdo, (int)$row['id'])]);
