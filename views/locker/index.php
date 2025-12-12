<?php include "../views/layouts/header.php"; ?>

<h2>Gestión de Casilleros</h2>

<div class="actions">
    <a href="index.php?controller=locker&action=create" class="btn btn-primary">➕ Nuevo Casillero</a>
</div>

<table class="table">
    <thead>
        <tr>
            <th>ID</th>
            <th>Número</th>
            <th>Estado</th>
            <th>Asignado a (ID)</th>
            <th>Acciones</th>
        </tr>
    </thead>

    <tbody>
        <?php foreach ($lockers as $locker): ?>
            <tr>
                <td><?= $locker["id"] ?></td>
                <td><?= $locker["numero"] ?></td>
                <td><span class="badge <?= $locker["estado"] == 'disponible' ? 'badge-success' : 'badge-warning' ?>">
                    <?= $locker["estado"] ?>
                </span></td>
                <td>
                    <?php if ($locker['miembro_nombre']): ?>
                        <strong><?= $locker['miembro_nombre'] ?></strong><br>
                        <small><?= $locker['miembro_email'] ?></small><br>
                        <small>(ID <?= $locker['usuario_asignado'] ?>)</small>
                    <?php else: ?>
                        <span style="color:#888">— Sin asignar —</span>
                    <?php endif; ?>
                </td>

                <td>
                    <a href="index.php?controller=locker&action=edit&id=<?= $locker["id"] ?>" class="btn btn-secondary btn-sm">Editar</a>
                    <a href="index.php?controller=locker&action=delete&id=<?= $locker["id"] ?>"
                       class="btn btn-danger btn-sm"
                       onclick="return confirm('¿Eliminar casillero?');">Eliminar</a>
                </td>
            </tr>
        <?php endforeach; ?>
    </tbody>

</table>

<?php include "../views/layouts/footer.php"; ?>
