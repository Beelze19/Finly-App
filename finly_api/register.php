<?php
require 'config.php';

$d = input();
$name  = trim($d['name'] ?? '');
$email = strtolower(trim($d['email'] ?? ''));
$pass  = $d['password'] ?? '';

if ($name === '' || $email === '' || $pass === '')
  respond(false, 'Semua kolom wajib diisi.', [], 400);
if (!filter_var($email, FILTER_VALIDATE_EMAIL))
  respond(false, 'Format email tidak valid.', [], 400);
if (strlen($pass) < 6)
  respond(false, 'Password minimal 6 karakter.', [], 400);

$cek = $pdo->prepare('SELECT id FROM users WHERE email = ?');
$cek->execute([$email]);
if ($cek->fetch()) respond(false, 'Email sudah terdaftar.', [], 409);

$stmt = $pdo->prepare('INSERT INTO users (name,email,password) VALUES (?,?,?)');
$stmt->execute([$name, $email, password_hash($pass, PASSWORD_DEFAULT)]);

respond(true, 'Registrasi berhasil. Silakan masuk.');
