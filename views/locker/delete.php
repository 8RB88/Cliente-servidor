<?php

// Este archivo solo procesa la eliminación y redirige nuevamente a index.php

$apiBase = "https://jailless-ayako-tenaciously.ngrok-free.dev";

$id = $_GET['id'] ?? null;

if (!$id) {
    echo "<script>alert('ID inválido'); window.location='index.php';</script>";
    exit;
}

$options = [
    'http' => [
        'method' => 'DELETE',
        'header' => "Content-Type: application/json"
    ]
];

$context = stream_context_create($options);

// Consumimos la API para eliminar el casillero
$response = @file_get_contents("$apiBase/$id", false, $context);

echo "<script>alert('Casillero eliminado correctamente'); window.location='index.php';</script>";
