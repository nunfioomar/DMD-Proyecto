USE DW_AnalisisFinanciero;
GO

-- 0. Limpieza rápida para empezar en blanco
DELETE FROM Fact_Ventas;
DELETE FROM Dim_Cliente;
DELETE FROM Dim_Direccion;
DELETE FROM Dim_Producto;
DELETE FROM Dim_Fecha;

DBCC CHECKIDENT ('Fact_Ventas', RESEED, 0);
DBCC CHECKIDENT ('Dim_Cliente', RESEED, 0);
DBCC CHECKIDENT ('Dim_Direccion', RESEED, 0);
DBCC CHECKIDENT ('Dim_Producto', RESEED, 0);
DBCC CHECKIDENT ('Dim_Fecha', RESEED, 0);
GO

-- 1. Llenar Dim_Cliente
INSERT INTO Dim_Cliente (Segmento, Segmento_Predictivo)
SELECT DISTINCT Segment, Segmento_Predictivo FROM Staging_Ventas WHERE Segment IS NOT NULL;

-- 2. Llenar Dim_Direccion
INSERT INTO Dim_Direccion (Pais)
SELECT DISTINCT Country FROM Staging_Ventas WHERE Country IS NOT NULL;

-- 3. Llenar Dim_Producto
INSERT INTO Dim_Producto (NombreProducto)
SELECT DISTINCT Product FROM Staging_Ventas WHERE Product IS NOT NULL;

-- 4. Llenar Dim_Fecha
INSERT INTO Dim_Fecha (FechaPedido, Mes, NombreMes, Anio)
SELECT DISTINCT 
    CAST([Date] AS DATE), 
    MONTH(CAST([Date] AS DATE)), 
    DATENAME(month, CAST([Date] AS DATE)), 
    YEAR(CAST([Date] AS DATE))
FROM Staging_Ventas WHERE [Date] IS NOT NULL;

-- 5. Llenar Fact_Ventas 
INSERT INTO Fact_Ventas (ClienteID, DireccionID, ProductoID, FechaID, Ventas, Ganancia, Cantidad, Descuentos)
SELECT 
    c.ClienteID,
    d.DireccionID,
    p.ProductoID,
    f.FechaID,
    ISNULL(TRY_CAST(REPLACE(s.[Sales], '"', '') AS FLOAT), 0),
    ISNULL(TRY_CAST(REPLACE(s.[Profit], '"', '') AS FLOAT), 0),
    ISNULL(TRY_CAST(REPLACE(s.[Units_Sold], '"', '') AS FLOAT), 0),
    ISNULL(TRY_CAST(REPLACE(s.[Discounts], '"', '') AS FLOAT), 0)
FROM Staging_Ventas s
JOIN Dim_Cliente c ON s.Segment = c.Segmento AND s.Segmento_Predictivo = c.Segmento_Predictivo
JOIN Dim_Direccion d ON s.Country = d.Pais
JOIN Dim_Producto p ON s.Product = p.NombreProducto
JOIN Dim_Fecha f ON CAST(s.[Date] AS DATE) = f.FechaPedido;
GO

PRINT 'Datos cargados exitosamente en el esquema de estrella.';