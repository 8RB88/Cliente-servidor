<?php include "../views/layouts/header.php"; ?>

<h2>Editar Casillero</h2>

<form class="form" method="POST" action="index.php?controller=locker&action=update">

    <input type="hidden" name="id" value="<?= $locker['id'] ?>">

    <div class="form-group">
        <label>Número del Casillero</label>
        <input type="number" name="numero" value="<?= $locker['numero'] ?>" required>
    </div>

    <div class="form-group">
        <label>Estado</label>
        <select name="estado">
            <option value="disponible" <?= $locker["estado"]=="disponible"?"selected":"" ?>>Disponible</option>
            <option value="ocupado" <?= $locker["estado"]=="ocupado"?"selected":"" ?>>Ocupado</option>
            <option value="mantenimiento" <?= $locker["estado"]=="mantenimiento"?"selected":"" ?>>Mantenimiento</option>
        </select>
    </div>

    <div class="form-group">
        <label>ID de Miembro asignado</label>
        <select name="usuario_asignado" class="form-control">
            <option value="">— Sin asignar —</option>

            <?php foreach ($miembros as $m): ?>
                <option value="<?= $m['id'] ?>"
                    <?= $locker['usuario_asignado'] == $m['id'] ? 'selected' : '' ?>>
                    <?= $m['name'] ?> (ID <?= $m['id'] ?>)
                </option>
            <?php endforeach; ?>
        </select>

    </div>

    <div class="form-actions">
        <button class="btn btn-primary">Actualizar</button>
        <a href="index.php?controller=locker&action=index" class="btn btn-secondary">Cancelar</a>
    </div>
</form>

<?php include "../views/layouts/footer.php"; ?>
