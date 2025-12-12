<?php

define('BASE_PATH', dirname(__DIR__));
define('PUBLIC_PATH', __DIR__);
// Inicializar conexión PDO para los controladores MVC



spl_autoload_register(function ($class) {
    $paths = [
        BASE_PATH . '/models/' . $class . '.php',
        BASE_PATH . '/controllers/' . $class . '.php',
        BASE_PATH . '/config/' . $class . '.php'
    ];
    
    foreach ($paths as $path) {
        if (file_exists($path)) {
            require_once $path;
            break;
        }
    }
});
$pdo = Database::getInstance()->getConnection();

$controllerName = $_GET['controller'] ?? 'member';
$action = $_GET['action'] ?? 'index';

$controllers = [
    'member' => 'MemberController',
    'class' => 'ClassController',
    'payment' => 'PaymentController',
    'instructor' => 'InstructorController',
    'locker' => 'LockerController'      // ✔ AGREGADO AQUÍ
];

if (!isset($controllers[$controllerName])) {
    die('Controlador no encontrado');
}

$controllerClass = $controllers[$controllerName];

if (!class_exists($controllerClass)) {
    die('Clase del controlador no encontrada: ' . $controllerClass);
}

try {
    $controller = new $controllerClass();

    if (!method_exists($controller, $action)) {
        die('Acción no encontrada: ' . $action);
    }

    $controller->$action();

} catch (Exception $e) {
    die('Error del servidor: ' . $e->getMessage());
}
