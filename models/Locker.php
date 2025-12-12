<?php

class Locker
{
    private $db;

    public function __construct($pdo)
    {
        $this->db = $pdo;
    }

    public function all() {
        $sql = "
            SELECT 
                lockers.id,
                lockers.numero,
                lockers.estado,
                lockers.usuario_asignado,
                members.name AS miembro_nombre,
                members.email AS miembro_email
            FROM lockers
            LEFT JOIN members ON lockers.usuario_asignado = members.id
            ORDER BY lockers.id ASC
        ";

        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }



    public function find($id)
    {
        $stmt = $this->db->prepare("SELECT * FROM lockers WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create($data)
    {
        $stmt = $this->db->prepare("
            INSERT INTO lockers (numero, estado, usuario_asignado)
            VALUES (?, ?, ?)
        ");

        return $stmt->execute([
            $data['numero'],
            $data['estado'],
            $data['usuario_asignado'] ?? null
        ]);
    }

    public function update($id, $data)
    {
        $stmt = $this->db->prepare("
            UPDATE lockers
            SET numero = ?, estado = ?, usuario_asignado = ?
            WHERE id = ?
        ");

        return $stmt->execute([
            $data['numero'],
            $data['estado'],
            $data['usuario_asignado'],
            $id
        ]);
    }

    public function delete($id)
    {
        $stmt = $this->db->prepare("DELETE FROM lockers WHERE id = ?");
        return $stmt->execute([$id]);
    }
}
