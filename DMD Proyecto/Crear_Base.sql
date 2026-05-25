-- 1. Creando la base de datos
CREATE DATABASE DW_AnalisisFinanciero;
GO

USE DW_AnalisisFinanciero;
GO

-- 2. Tablas de Dimensión
CREATE TABLE Dim_Cliente (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Segmento VARCHAR(100),
    Segmento_Predictivo VARCHAR(50) -- Aquí vivirá el resultado de K-Means
);

CREATE TABLE Dim_Direccion (
    DireccionID INT IDENTITY(1,1) PRIMARY KEY,
    Pais VARCHAR(100)
);

CREATE TABLE Dim_Producto (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    NombreProducto VARCHAR(150)
);

CREATE TABLE Dim_Fecha (
    FechaID INT IDENTITY(1,1) PRIMARY KEY,
    FechaPedido DATE,
    Mes INT,
    NombreMes VARCHAR(50),
    Anio INT
);

-- 3. Tabla de Hechos central
CREATE TABLE Fact_Ventas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT FOREIGN KEY REFERENCES Dim_Cliente(ClienteID),
    DireccionID INT FOREIGN KEY REFERENCES Dim_Direccion(DireccionID),
    ProductoID INT FOREIGN KEY REFERENCES Dim_Producto(ProductoID),
    FechaID INT FOREIGN KEY REFERENCES Dim_Fecha(FechaID),
    Ventas DECIMAL(18,2),
    Ganancia DECIMAL(18,2),
    Cantidad DECIMAL(18,2),
    Descuentos DECIMAL(18,2)
);
GO

PRINT '¡Esquema de estrella creado con éxito!';