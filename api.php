<?php
// API de NITRO MOTORS: conecta el sitio con MySQL (base DealerDB)
header('Content-Type: application/json; charset=utf-8');
$db = null;
try {
    $db = new PDO('mysql:host=localhost;dbname=DealerDB;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
    $T = [
        'marca'    => ['t'=>'Marca',    'pk'=>'idMarca',    'cols'=>['nombreMarca','paisOrigen']],
        'vehiculo' => ['t'=>'Vehiculo', 'pk'=>'idVehiculo', 'cols'=>['idMarca','modelo','placa','anio','chasis','color','precio','estado'],
                       'x'=>', (SELECT nombreMarca FROM Marca m WHERE m.idMarca=Vehiculo.idMarca) AS marca'],
        'cliente'  => ['t'=>'Cliente',  'pk'=>'idCliente',  'cols'=>['nombre','apellido','cedula','telefono','correo','direccion']],
        'vendedor' => ['t'=>'Vendedor', 'pk'=>'idVendedor', 'cols'=>['nombre','apellido','cedula','telefono','comisionPorcentaje']],
        'venta'    => ['t'=>'Venta',    'pk'=>'idVenta',    'cols'=>['fechaVenta','idCliente','idVehiculo','idVendedor','montoTotal','metodoPago'],
                       'x'=>", (SELECT CONCAT(nombre,' ',apellido) FROM Cliente WHERE idCliente=Venta.idCliente) AS cliente,
                               (SELECT CONCAT(m.nombreMarca,' ',v.modelo,' ',v.anio) FROM Vehiculo v JOIN Marca m ON m.idMarca=v.idMarca WHERE v.idVehiculo=Venta.idVehiculo) AS vehiculo,
                               (SELECT CONCAT(nombre,' ',apellido) FROM Vendedor WHERE idVendedor=Venta.idVendedor) AS vendedor,
                               (SELECT comisionPorcentaje FROM Vendedor WHERE idVendedor=Venta.idVendedor) AS pct"],
        'serviciotaller' => ['t'=>'ServicioTaller', 'pk'=>'idServicio', 'cols'=>['idVehiculo','fechaEntrada','fechaSalida','descripcion','costo','estado'],
                       'x'=>", (SELECT CONCAT(m.nombreMarca,' ',v.modelo,' ',v.anio) FROM Vehiculo v JOIN Marca m ON m.idMarca=v.idMarca WHERE v.idVehiculo=ServicioTaller.idVehiculo) AS vehiculo"]
    ];
    $e = $_GET['e'] ?? ''; $a = $_GET['a'] ?? 'leer';
    if (!isset($T[$e])) throw new Exception('Entidad inválida');
    $t = $T[$e];
    $in = json_decode(file_get_contents('php://input'), true) ?? [];

    if ($a == 'leer') {                                   // SELECT
        $sql = "SELECT {$t['pk']} AS id, " . implode(',', $t['cols']) . ($t['x'] ?? '') . " FROM {$t['t']} ORDER BY {$t['pk']}";
        echo json_encode($db->query($sql)->fetchAll());
    } elseif ($a == 'insertar') {                         // INSERT
        $db->beginTransaction();
        if ($e == 'venta') {                              // el monto sale del precio del vehículo
            $s = $db->prepare("SELECT precio FROM Vehiculo WHERE idVehiculo=? AND estado='Disponible'");
            $s->execute([$in['idVehiculo'] ?? 0]);
            $p = $s->fetchColumn();
            if ($p === false) throw new Exception('El vehículo no está disponible');
            $in['montoTotal'] = $p;
        }
        $q = implode(',', array_fill(0, count($t['cols']), '?'));
        $db->prepare("INSERT INTO {$t['t']}(" . implode(',', $t['cols']) . ") VALUES($q)")
           ->execute(array_map(fn($c) => ($in[$c] ?? '') === '' ? null : $in[$c], $t['cols']));
        $id = $db->lastInsertId();
        if ($e == 'venta') $db->prepare("UPDATE Vehiculo SET estado='Vendido' WHERE idVehiculo=?")->execute([$in['idVehiculo']]);
        $db->commit();
        echo json_encode(['id' => $id]);
    } elseif ($a == 'eliminar') {                         // DELETE
        $db->prepare("DELETE FROM {$t['t']} WHERE {$t['pk']}=?")->execute([$in['id'] ?? 0]);
        echo json_encode(['ok' => 1]);
    }
} catch (Exception $x) {
    if ($db && $db->inTransaction()) $db->rollBack();
    http_response_code(400);
    echo json_encode(['error' => $x->getCode() == 23000 ? 'No se puede: dato duplicado o tiene registros relacionados (ej. un vendedor con ventas)' : $x->getMessage()]);
}
