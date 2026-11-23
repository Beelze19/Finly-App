<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

try {
  $pdo = new PDO(
    'mysql:host=localhost;dbname=finly_db;charset=utf8mb4',
    'root', '',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
     PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
  );
} catch (PDOException $e) {
  http_response_code(500);
  echo json_encode(['success' => false, 'message' => 'Koneksi database gagal.']);
  exit;
}

function input(): array {
  return json_decode(file_get_contents('php://input'), true) ?? [];
}

function respond(bool $ok, string $msg, array $extra = [], int $code = 200) {
  http_response_code($code);
  echo json_encode(array_merge(['success' => $ok, 'message' => $msg], $extra));
  exit;
}

function fetch_user(PDO $pdo, int $id): ?array {
  $s = $pdo->prepare(
    'SELECT id,name,email,phone,expense_limit,savings_target FROM users WHERE id = ?'
  );
  $s->execute([$id]);
  $u = $s->fetch();
  if (!$u) return null;
  $u['id'] = (int)$u['id'];
  $u['phone'] = $u['phone'] ?? '';
  $u['expense_limit'] = (int)$u['expense_limit'];
  $u['savings_target'] = (int)$u['savings_target'];
  return $u;
}
