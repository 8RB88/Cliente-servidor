<?php

class LockerController
{
    private $model;

    public function __construct()
    {
        // MUY IMPORTANTE: traer la conexión global
        global $pdo;

        if (!$pdo) {
            die("ERROR: Conexión PDO no inicializada");
        }

        // Crear el modelo usando la misma conexión que los demás módulos
        $this->model = new Locker($pdo);
    }

    public function index()
    {
        $lockers = $this->model->all();
        include "../views/locker/index.php";
    }

    public function create()
    {
        global $pdo;

        // Obtener lista de miembros
        $stmt = $pdo->query("SELECT id, name, email FROM members ORDER BY name ASC");
        $miembros = $stmt->fetchAll(PDO::FETCH_ASSOC);

        include "../views/locker/create.php";
    }


    public function store()
    {
        $data = [
            "numero" => $_POST["numero"],
            "estado" => $_POST["estado"],
            "usuario_asignado" => $_POST["usuario_asignado"] ?: null
        ];

        $this->model->create($data);
        header("Location: index.php?controller=locker&action=index");
    }

    public function edit()
    {
        global $pdo;

        $id = $_GET["id"];
        $locker = $this->model->find($id);

        // Lista de miembros para el select
        $stmt = $pdo->query("SELECT id, name, email FROM members ORDER BY name ASC");
        $miembros = $stmt->fetchAll(PDO::FETCH_ASSOC);

        include "../views/locker/edit.php";
    }


    public function update()
    {
        $id = $_POST["id"];

        $data = [
            "numero" => $_POST["numero"],
            "estado" => $_POST["estado"],
            "usuario_asignado" => $_POST["usuario_asignado"] ?: null
        ];

        $this->model->update($id, $data);
        header("Location: index.php?controller=locker&action=index");
    }

    public function delete()
    {
        $id = $_GET["id"];
        $this->model->delete($id);
        header("Location: index.php?controller=locker&action=index");
    }
}
