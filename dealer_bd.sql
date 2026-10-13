-- ============================================================
-- Base de Datos: DealerDB
-- Proyecto: RA1 - Análisis del Sistema - Empresa: Dealer
-- Estudiante: Carlos Daniel Florimon Henriquez
-- Instituto Politécnico Cardenal Sancha
-- ============================================================

DROP DATABASE IF EXISTS DealerDB;
CREATE DATABASE DealerDB;
USE DealerDB;

-- ============================================================
-- Tabla: Marca
-- ============================================================
CREATE TABLE Marca (
    idMarca INT AUTO_INCREMENT PRIMARY KEY,
    nombreMarca VARCHAR(50) NOT NULL,
    paisOrigen VARCHAR(50)
);

-- ============================================================
-- Tabla: Vehiculo
-- ============================================================
CREATE TABLE Vehiculo (
    idVehiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(15) UNIQUE,
    chasis VARCHAR(30) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    anio INT NOT NULL,
    color VARCHAR(30),
    precio DECIMAL(12,2) NOT NULL,
    estado ENUM('Disponible','Vendido','Reservado','En_Taller') DEFAULT 'Disponible',
    idMarca INT NOT NULL,
    FOREIGN KEY (idMarca) REFERENCES Marca(idMarca)
);

-- ============================================================
-- Tabla: Cliente
-- ============================================================
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(150)
);

-- ============================================================
-- Tabla: Vendedor
-- ============================================================
CREATE TABLE Vendedor (
    idVendedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    comisionPorcentaje DECIMAL(5,2) DEFAULT 5.00
);

-- ============================================================
-- Tabla: Venta
-- ============================================================
CREATE TABLE Venta (
    idVenta INT AUTO_INCREMENT PRIMARY KEY,
    fechaVenta DATE NOT NULL,
    idCliente INT NOT NULL,
    idVehiculo INT NOT NULL,
    idVendedor INT NOT NULL,
    montoTotal DECIMAL(12,2) NOT NULL,
    metodoPago ENUM('Contado','Financiado') DEFAULT 'Contado',
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (idVehiculo) REFERENCES Vehiculo(idVehiculo),
    FOREIGN KEY (idVendedor) REFERENCES Vendedor(idVendedor)
);

-- ============================================================
-- Tabla: ServicioTaller
-- ============================================================
CREATE TABLE ServicioTaller (
    idServicio INT AUTO_INCREMENT PRIMARY KEY,
    idVehiculo INT NOT NULL,
    fechaEntrada DATE NOT NULL,
    fechaSalida DATE,
    descripcion VARCHAR(255) NOT NULL,
    costo DECIMAL(10,2),
    estado ENUM('En_Proceso','Completado','Cancelado') DEFAULT 'En_Proceso',
    FOREIGN KEY (idVehiculo) REFERENCES Vehiculo(idVehiculo)
);

-- ============================================================
-- Datos de ejemplo
-- ============================================================
INSERT INTO Marca (nombreMarca, paisOrigen) VALUES
('Toyota', 'Japón'),
('Honda', 'Japón'),
('Ford', 'Estados Unidos'),
('Hyundai', 'Corea del Sur');

INSERT INTO Vehiculo (placa, chasis, modelo, anio, color, precio, estado, idMarca) VALUES
('A123456', 'JTDBR32E720012345', 'Corolla', 2025, 'Blanco', 850000.00, 'Vendido', 1),
('A654321', 'MHFXX44G4H0098765', 'CR-V', 2025, 'Gris', 1450000.00, 'Vendido', 2),
(NULL, '1FTFW1ET5DFA12345', 'F-150', 2026, 'Negro', 2100000.00, 'Reservado', 3),
('A777888', 'KM8J3CA46FU123456', 'Tucson', 2025, 'Azul', 1250000.00, 'Disponible', 4);

INSERT INTO Cliente (nombre, apellido, cedula, telefono, correo, direccion) VALUES
('Juan', 'Pérez', '001-1234567-8', '809-555-0101', 'juan.perez@correo.com', 'Santo Domingo'),
('María', 'Gómez', '001-7654321-2', '809-555-0202', 'maria.gomez@correo.com', 'Santiago');

INSERT INTO Vendedor (nombre, apellido, cedula, telefono, comisionPorcentaje) VALUES
('Luis', 'Ramírez', '001-1112223-4', '809-555-0303', 5.00),
('Ana', 'Torres', '001-4445556-7', '809-555-0404', 6.50),
('Pedro', 'Santos', '001-7778889-0', '809-555-0505', 5.50);

INSERT INTO Venta (fechaVenta, idCliente, idVehiculo, idVendedor, montoTotal, metodoPago) VALUES
('2026-08-15', 1, 1, 1, 850000.00, 'Financiado'),
('2026-08-20', 2, 2, 2, 1450000.00, 'Contado');

INSERT INTO ServicioTaller (idVehiculo, fechaEntrada, fechaSalida, descripcion, costo, estado) VALUES
(2, '2026-08-25', '2026-08-26', 'Cambio de aceite y filtro', 3500.00, 'Completado');

-- ============================================================
-- Consultas de ejemplo
-- ============================================================
-- Listar vehículos disponibles con su marca
SELECT v.modelo, v.anio, v.precio, m.nombreMarca
FROM Vehiculo v
JOIN Marca m ON v.idMarca = m.idMarca
WHERE v.estado = 'Disponible';

-- Historial de ventas con cliente y vendedor
SELECT ve.fechaVenta, c.nombre AS cliente, ven.nombre AS vendedor, ve.montoTotal
FROM Venta ve
JOIN Cliente c ON ve.idCliente = c.idCliente
JOIN Vendedor ven ON ve.idVendedor = ven.idVendedor;
