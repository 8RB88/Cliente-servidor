<?php include "../views/layouts/header.php"; ?>

<h2>Crear Casillero</h2>

<form class="form" method="POST" action="index.php?controller=locker&action=store">
    
    <div class="form-group">
        <label>Número del Casillero</label>
        <input type="number" name="numero" required>
    </div>

    <div class="form-group">
        <label>Estado</label>
        <select name="estado">
            <option value="disponible">Disponible</option>
            <option value="ocupado">Ocupado</option>
            <option value="mantenimiento">Mantenimiento</option>
        </select>
    </div>

    <div class="form-group">
        <label>ID de Miembro asignado (opcional)</label>
        <select name="usuario_asignado" class="form-control">
            <option value="">— Sin asignar —</option>

            <?php foreach ($miembros as $m): ?>
                <option value="<?= $m['id'] ?>">
                    <?= $m['name'] ?> (ID <?= $m['id'] ?>)
                </option>
            <?php endforeach; ?>
        </select>

    </div>

    <div class="form-actions">
        <button class="btn btn-primary">Guardar</button>
        <a href="index.php?controller=locker&action=index" class="btn btn-secondary">Cancelar</a>
    </div>
</form>

<?php include "../views/layouts/footer.php"; ?>
