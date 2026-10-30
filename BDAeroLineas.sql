USE master;
GO

-- Validación para eliminar y recrear la base de datos sin conflictos de conexiones activas
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BDAerolineas')
BEGIN
    ALTER DATABASE BDAerolineas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BDAerolineas;
END
GO

CREATE DATABASE BDAerolineas;
GO

USE BDAerolineas;
GO

-- =========================================================================
-- 1. CREACIÓN DE LAS 9 TABLAS DE DIMENSIONES
-- =========================================================================

-- 1. Dimensión Tiempo
CREATE TABLE DimTiempo (
    IdTiempoPK		NCHAR(6)		NOT NULL,
    Fecha			DATE			NOT NULL,
    Anio			INT				NOT NULL,
    Trimestre		NVARCHAR(15)		NOT NULL,
    Mes				NVARCHAR(20)		NOT NULL,
    DiaSemana		NVARCHAR(15)		NOT NULL,
    EstacionAnio	NVARCHAR(20)		NOT NULL,
    FranjaHoraria	NVARCHAR(20)		NOT NULL,
    CONSTRAINT PK_DimTiempo PRIMARY KEY (IdTiempoPK)
);
GO

-- 2. Dimensión Aeropuerto
CREATE TABLE DimAeropuerto (
    IdAeropuertoPK				NCHAR(6)		NOT NULL,
    CodigoIATA					NCHAR(3)			NOT NULL,
    NombreAeropuerto			NVARCHAR(100)	NOT NULL,
    Ciudad						NVARCHAR(50)		NOT NULL,
    Departamento				NVARCHAR(50)		NOT NULL,
    CapacidadOperativaHora		INT				NOT NULL,
    CONSTRAINT PK_DimAeropuerto PRIMARY KEY (IdAeropuertoPK)
);
GO

-- 3. Dimensión Ruta
CREATE TABLE DimRuta (
    IdRutaPK		NCHAR(6)		NOT NULL,
    CodigoRuta		NVARCHAR(15)		NOT NULL,
    CiudadOrigen	NVARCHAR(50)		NOT NULL,
    CiudadDestino	NVARCHAR(50)		NOT NULL,
    DistanciaKm		DECIMAL(8,2)	NOT NULL,
    DuracionMin		INT				NOT NULL,
    CONSTRAINT PK_DimRuta PRIMARY KEY (IdRutaPK)
);
GO

-- 4. Dimensión Aeronave
CREATE TABLE DimAeronave (
    IdAeronavePK			NCHAR(6)		NOT NULL,
    Matricula				NVARCHAR(15)		NOT NULL,
    Modelo					NVARCHAR(50)		NOT NULL,
    CapacidadPasajeros		INT				NOT NULL,
    ConsumoPromedioGalHora	DECIMAL(8,2)	NOT NULL,
    CONSTRAINT PK_DimAeronave PRIMARY KEY (IdAeronavePK)
);
GO

-- 5. Dimensión Tripulación
CREATE TABLE DimTripulacion (
    IdTripulacionPK			NCHAR(6)		NOT NULL,
    CodigoEquipo			NVARCHAR(15)		NOT NULL,
    CapitanCargo			NVARCHAR(80)		NOT NULL,
    HorasVueloAcumuladas	INT				NOT NULL,
    NivelFatiga				NVARCHAR(20)		NOT NULL,
    TurnoOperativo			NVARCHAR(20)		NOT NULL,
    CONSTRAINT PK_DimTripulacion PRIMARY KEY (IdTripulacionPK)
);
GO

-- 6. Dimensión Clima
CREATE TABLE DimClima (
    IdClimaPK				NCHAR(6)		NOT NULL,
    VelocidadVientoKmh		DECIMAL(6,2)	NOT NULL,
    VisibilidadMetros		INT				NOT NULL,
    PrecipitacionMm			DECIMAL(6,2)	NOT NULL,
    TemperaturaGradosC		DECIMAL(5,2)	NOT NULL,
    PresionAtmosfericaHpa	DECIMAL(6,2)	NOT NULL,
    CONSTRAINT PK_DimClima PRIMARY KEY (IdClimaPK)
);
GO

-- 7. Dimensión Fenómeno Climático
CREATE TABLE DimFenomenoClimatico (
    IdFenomenoPK		NCHAR(6)		NOT NULL,
    NombreFenomeno		NVARCHAR(60)		NOT NULL,
    TipoAnomalia		NVARCHAR(50)		NOT NULL,
    NivelSeveridad		NVARCHAR(25)		NOT NULL,
    CONSTRAINT PK_DimFenomenoClimatico PRIMARY KEY (IdFenomenoPK)
);
GO

-- 8. Dimensión Causa de Demora
CREATE TABLE DimCausaDemora (
    IdCausaPK				NCHAR(6)		NOT NULL,
    DescripcionCausa		NVARCHAR(100)	NOT NULL,
    CategoriaCausa			NVARCHAR(40)		NOT NULL,
    AplicaIndemnizacion		NCHAR(2)			NOT NULL,
    CONSTRAINT PK_DimCausaDemora PRIMARY KEY (IdCausaPK)
);
GO

-- 9. Dimensión Estado de Vuelo
CREATE TABLE DimEstadoVuelo (
    IdEstadoPK					NCHAR(6)		NOT NULL,
    NumeroVuelo					NVARCHAR(15)		NOT NULL,
    EstadoOperacion				NVARCHAR(30)		NOT NULL,
    NivelImpactoItinerario		NVARCHAR(30)		NOT NULL,
    CONSTRAINT PK_DimEstadoVuelo PRIMARY KEY (IdEstadoPK)
);
GO

-- =========================================================================
-- 2. CREACIÓN DE LA TABLA DE HECHOS
-- =========================================================================

CREATE TABLE FactDemoraVuelo (
    IdHechoDemoraPK		NCHAR(6) NOT NULL,
    -- Llaves Foráneas de las 9 dimensiones
    IdTiempoFK			NCHAR(6)	NOT NULL,
    IdAeropuertoFK		NCHAR(6)	NOT NULL,
    IdRutaFK			NCHAR(6)	NOT NULL,
    IdAeronaveFK		NCHAR(6)	NOT NULL,
    IdTripulacionFK		NCHAR(6)	NOT NULL,
    IdClimaFK			NCHAR(6)	NOT NULL,
    IdFenomenoFK		NCHAR(6)	NOT NULL,
    IdCausaFK			NCHAR(6)	NOT NULL,
    IdEstadoFK			NCHAR(6)	NOT NULL,
    -- Métricas cuantitativas para el cubo OLAP
    MinutosRetrasoSalida		INT				NOT NULL	DEFAULT 0,
    MinutosRetrasoLlegada		INT				NOT NULL	DEFAULT 0,
    MinutosRetrasoAcumulados	INT				NOT NULL	DEFAULT 0,
    CombustibleConsumidoGal		DECIMAL(10,2)	NOT NULL,	
    CostoOperativoAdicionalUSD	DECIMAL(10,2)	NOT NULL	DEFAULT 0.00,
    MontoIndemnizacionUSD		DECIMAL(10,2)	NOT NULL	DEFAULT 0.00,
    PasajerosAfectados			INT				NOT NULL	DEFAULT 0,
    -- Restricciones de Llave Primaria y Llaves Foráneas
    CONSTRAINT PK_FactDemoraVuelo PRIMARY KEY (IdHechoDemoraPK),
    CONSTRAINT FK_Fact_DimTiempo FOREIGN KEY (IdTiempoFK) REFERENCES DimTiempo(IdTiempoPK),
    CONSTRAINT FK_Fact_DimAeropuerto FOREIGN KEY (IdAeropuertoFK) REFERENCES DimAeropuerto(IdAeropuertoPK),
    CONSTRAINT FK_Fact_DimRuta FOREIGN KEY (IdRutaFK) REFERENCES DimRuta(IdRutaPK),
    CONSTRAINT FK_Fact_DimAeronave FOREIGN KEY (IdAeronaveFK) REFERENCES DimAeronave(IdAeronavePK),
    CONSTRAINT FK_Fact_DimTripulacion FOREIGN KEY (IdTripulacionFK) REFERENCES DimTripulacion(IdTripulacionPK),
    CONSTRAINT FK_Fact_DimClima FOREIGN KEY (IdClimaFK) REFERENCES DimClima(IdClimaPK),
    CONSTRAINT FK_Fact_DimFenomeno FOREIGN KEY (IdFenomenoFK) REFERENCES DimFenomenoClimatico(IdFenomenoPK),
    CONSTRAINT FK_Fact_DimCausa FOREIGN KEY (IdCausaFK) REFERENCES DimCausaDemora(IdCausaPK),
    CONSTRAINT FK_Fact_DimEstado FOREIGN KEY (IdEstadoFK) REFERENCES DimEstadoVuelo(IdEstadoPK)
);
GO

USE BDAerolineas;
GO

-- Configuración para aceptar el formato de fecha dd/mm/yy (Día/Mes/Año)
SET DATEFORMAT dmy;
GO

-- =========================================================================
-- 1. POBLAMIENTO DE LAS 9 TABLAS DE DIMENSIONES (BAJA VARIABILIDAD)
-- =========================================================================

-- 1. Dimensión Tiempo (Fechas en formato dd/mm/yy)
INSERT INTO DimTiempo (IdTiempoPK, Fecha, Anio, Trimestre, Mes, DiaSemana, EstacionAnio, FranjaHoraria) VALUES
('TIE001', '15/01/26', 2026, 'Trimestre 1', 'Enero', 'Jueves', 'Verano', 'Mañana'),
('TIE002', '12/02/26', 2026, 'Trimestre 1', 'Febrero', 'Jueves', 'Verano', 'Tarde'),
('TIE003', '20/03/26', 2026, 'Trimestre 1', 'Marzo', 'Viernes', 'Verano', 'Noche'),
('TIE004', '10/04/26', 2026, 'Trimestre 2', 'Abril', 'Viernes', 'Otoño', 'Mañana'),
('TIE005', '18/05/26', 2026, 'Trimestre 2', 'Mayo', 'Lunes', 'Otoño', 'Noche'),
('TIE006', '22/06/26', 2026, 'Trimestre 2', 'Junio', 'Lunes', 'Invierno', 'Mañana'),
('TIE007', '14/07/26', 2026, 'Trimestre 3', 'Julio', 'Martes', 'Invierno', 'Tarde'),
('TIE008', '19/08/26', 2026, 'Trimestre 3', 'Agosto', 'Miércoles', 'Invierno', 'Noche'),
('TIE009', '23/09/26', 2026, 'Trimestre 3', 'Septiembre', 'Miércoles', 'Primavera', 'Mañana'),
('TIE010', '28/10/26', 2026, 'Trimestre 4', 'Octubre', 'Miércoles', 'Primavera', 'Tarde');
GO

-- 2. Dimensión Aeropuerto (10 capitales de 10 países distintos afectadas por el clima)
INSERT INTO DimAeropuerto (IdAeropuertoPK, CodigoIATA, NombreAeropuerto, Ciudad, Departamento, CapacidadOperativaHora) VALUES
('AER001', 'LIM', 'Aeropuerto Internacional Jorge Chávez', 'Lima', 'Perú', 35),
('AER002', 'BOG', 'Aeropuerto Internacional El Dorado', 'Bogotá', 'Colombia', 45),
('AER003', 'UIO', 'Aeropuerto Internacional Mariscal Sucre', 'Quito', 'Ecuador', 25),
('AER004', 'SCL', 'Aeropuerto Internacional Arturo Merino Benítez', 'Santiago', 'Chile', 40),
('AER005', 'EZE', 'Aeropuerto Internacional Ministro Pistarini', 'Buenos Aires', 'Argentina', 35),
('AER006', 'MEX', 'Aeropuerto Internacional Benito Juárez', 'Ciudad de México', 'México', 50),
('AER007', 'PTY', 'Aeropuerto Internacional de Tocumen', 'Ciudad de Panamá', 'Panamá', 40),
('AER008', 'LPB', 'Aeropuerto Internacional El Alto', 'La Paz', 'Bolivia', 20),
('AER009', 'LHR', 'Aeropuerto Internacional de Heathrow', 'Londres', 'Reino Unido', 60),
('AER010', 'HND', 'Aeropuerto Internacional de Haneda', 'Tokio', 'Japón', 55);
GO

-- 3. Dimensión Ruta (10 ciudades de origen distintas conectadas únicamente entre sí mismas)
INSERT INTO DimRuta (IdRutaPK, CodigoRuta, CiudadOrigen, CiudadDestino, DistanciaKm, DuracionMin) VALUES
('RUT001', 'LIM-BOG', 'Lima', 'Bogotá', 1880.00, 180),
('RUT002', 'BOG-UIO', 'Bogotá', 'Quito', 730.00, 95),
('RUT003', 'UIO-PTY', 'Quito', 'Ciudad de Panamá', 1030.00, 120),
('RUT004', 'PTY-MEX', 'Ciudad de Panamá', 'Ciudad de México', 2410.00, 230),
('RUT005', 'MEX-LHR', 'Ciudad de México', 'Londres', 8900.00, 620),
('RUT006', 'LHR-HND', 'Londres', 'Tokio', 9560.00, 700),
('RUT007', 'HND-SCL', 'Tokio', 'Santiago', 17200.00, 1140),
('RUT008', 'SCL-EZE', 'Santiago', 'Buenos Aires', 1140.00, 130),
('RUT009', 'EZE-LPB', 'Buenos Aires', 'La Paz', 2240.00, 210),
('RUT010', 'LPB-LIM', 'La Paz', 'Lima', 1080.00, 125);
GO

-- 4. Dimensión Aeronave (Valores estandarizados en 3 modelos comerciales)
INSERT INTO DimAeronave (IdAeronavePK, Matricula, Modelo, CapacidadPasajeros, ConsumoPromedioGalHora) VALUES
('NAV001', 'OB-2021', 'Airbus A320', 180, 820.00),
('NAV002', 'HK-5010', 'Airbus A320', 180, 820.00),
('NAV003', 'CC-3040', 'Boeing 737-800', 186, 850.00),
('NAV004', 'XA-7080', 'Boeing 737-800', 186, 850.00),
('NAV005', 'N-9015', 'Boeing 787-8', 250, 1450.00);
GO

-- 5. Dimensión Tripulación (Niveles de fatiga y turnos controlados)
INSERT INTO DimTripulacion (IdTripulacionPK, CodigoEquipo, CapitanCargo, HorasVueloAcumuladas, NivelFatiga, TurnoOperativo) VALUES
('TRI001', 'EQ-ALFA', 'Carlos Mendoza', 4500, 'Bajo', 'Mañana'),
('TRI002', 'EQ-BETA', 'Jorge Salazar', 5200, 'Medio', 'Tarde'),
('TRI003', 'EQ-GAMMA', 'Miguel Paredes', 6100, 'Alto', 'Noche'),
('TRI004', 'EQ-DELTA', 'Roberto Vargas', 4800, 'Medio', 'Mañana'),
('TRI005', 'EQ-OMEGA', 'Fernando Rojas', 5900, 'Alto', 'Noche');
GO

-- 6. Dimensión Clima (5 escenarios meteorológicos recurrentes)
INSERT INTO DimClima (IdClimaPK, VelocidadVientoKmh, VisibilidadMetros, PrecipitacionMm, TemperaturaGradosC, PresionAtmosfericaHpa) VALUES
('CLI001', 25.00, 400, 2.50, 15.00, 1012.00),   -- Neblina costera / invernal cerrada
('CLI002', 65.00, 1200, 45.00, 24.00, 1004.00), -- Lluvia torrencial y tormenta
('CLI003', 85.00, 2500, 10.00, 12.00, 998.00),  -- Vientos cruzados severos
('CLI004', 40.00, 800, 15.00, -4.00, 985.00),   -- Helada y baja presión de altitud
('CLI005', 95.00, 500, 70.00, 22.00, 990.00);   -- Tifón / Fenómeno extremo
GO

-- 7. Dimensión Fenómeno Climático
INSERT INTO DimFenomenoClimatico (IdFenomenoPK, NombreFenomeno, TipoAnomalia, NivelSeveridad) VALUES
('FEN001', 'Neblina Densa Persistente', 'Atmosférica', 'Moderado'),
('FEN002', 'Fenómeno El Niño', 'Oceanográfica', 'Severo'),
('FEN003', 'Vientos Cruzados de Altura', 'Atmosférica', 'Severo'),
('FEN004', 'Helada Invernal Extrema', 'Térmica', 'Moderado'),
('FEN005', 'Tormenta Tropical / Tifón', 'Oceanográfica', 'Extremo');
GO

-- 8. Dimensión Causa de Demora
INSERT INTO DimCausaDemora (IdCausaPK, DescripcionCausa, CategoriaCausa, AplicaIndemnizacion) VALUES
('CAU001', 'Baja visibilidad en pista por neblina', 'Fuerza Mayor Clima', 'NO'),
('CAU002', 'Vientos cruzados superiores al límite operativo', 'Fuerza Mayor Clima', 'NO'),
('CAU003', 'Pista anegada por precipitaciones extremas', 'Fuerza Mayor Clima', 'NO'),
('CAU004', 'Congestión de tráfico por cierre temporal climático', 'Logística Aeroportuaria', 'SI'),
('CAU005', 'Reprogramación de tripulación por demora acumulada', 'Logística Aeroportuaria', 'SI');
GO

-- 9. Dimensión Estado de Vuelo
INSERT INTO DimEstadoVuelo (IdEstadoPK, NumeroVuelo, EstadoOperacion, NivelImpactoItinerario) VALUES
('EST001', 'AV-101', 'Demorado', 'Moderado'),
('EST002', 'AV-205', 'Demorado', 'Bajo'),
('EST003', 'AV-310', 'Reprogramado', 'Crítico'),
('EST004', 'AV-415', 'Reprogramado', 'Moderado'),
('EST005', 'AV-520', 'Cancelado', 'Crítico');
GO

-- =========================================================================
-- 2. POBLAMIENTO DE LA TABLA DE HECHOS (100 REGISTROS CON BAJA VARIABILIDAD)
-- =========================================================================

INSERT INTO FactDemoraVuelo (
    IdHechoDemoraPK, IdTiempoFK, IdAeropuertoFK, IdRutaFK, IdAeronaveFK,
    IdTripulacionFK, IdClimaFK, IdFenomenoFK, IdCausaFK, IdEstadoFK,
    MinutosRetrasoSalida, MinutosRetrasoLlegada, MinutosRetrasoAcumulados,
    CombustibleConsumidoGal, CostoOperativoAdicionalUSD, MontoIndemnizacionUSD, PasajerosAfectados
) VALUES
('FAC001', 'TIE001', 'AER001', 'RUT001', 'NAV001', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 95, 2500.00, 1200.00, 0.00, 160),
('FAC002', 'TIE001', 'AER002', 'RUT002', 'NAV002', 'TRI002', 'CLI002', 'FEN002', 'CAU003', 'EST001', 60, 65, 125, 1400.00, 1500.00, 0.00, 170),
('FAC003', 'TIE001', 'AER003', 'RUT003', 'NAV003', 'TRI003', 'CLI003', 'FEN003', 'CAU002', 'EST003', 90, 95, 185, 1800.00, 2400.00, 0.00, 180),
('FAC004', 'TIE001', 'AER007', 'RUT004', 'NAV004', 'TRI004', 'CLI002', 'FEN005', 'CAU004', 'EST004', 75, 80, 155, 3200.00, 2100.00, 3500.00, 175),
('FAC005', 'TIE001', 'AER006', 'RUT005', 'NAV005', 'TRI005', 'CLI005', 'FEN005', 'CAU005', 'EST005', 120, 130, 250, 14500.00, 5000.00, 8000.00, 240),
('FAC006', 'TIE001', 'AER009', 'RUT006', 'NAV005', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST002', 30, 35, 65, 16200.00, 900.00, 0.00, 230),
('FAC007', 'TIE001', 'AER010', 'RUT007', 'NAV005', 'TRI002', 'CLI005', 'FEN005', 'CAU003', 'EST003', 110, 115, 225, 26000.00, 4800.00, 0.00, 245),
('FAC008', 'TIE001', 'AER004', 'RUT008', 'NAV001', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST001', 50, 55, 105, 1900.00, 1300.00, 0.00, 165),
('FAC009', 'TIE001', 'AER005', 'RUT009', 'NAV002', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST002', 35, 40, 75, 2900.00, 1100.00, 0.00, 155),
('FAC010', 'TIE001', 'AER008', 'RUT010', 'NAV003', 'TRI005', 'CLI004', 'FEN004', 'CAU004', 'EST004', 80, 85, 165, 1850.00, 2200.00, 3200.00, 180),

('FAC011', 'TIE002', 'AER001', 'RUT001', 'NAV001', 'TRI002', 'CLI002', 'FEN002', 'CAU003', 'EST001', 55, 60, 115, 2550.00, 1400.00, 0.00, 160),
('FAC012', 'TIE002', 'AER002', 'RUT002', 'NAV002', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST002', 25, 30, 55, 1350.00, 800.00, 0.00, 150),
('FAC013', 'TIE002', 'AER003', 'RUT003', 'NAV003', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST001', 65, 70, 135, 1750.00, 1600.00, 0.00, 175),
('FAC014', 'TIE002', 'AER007', 'RUT004', 'NAV004', 'TRI005', 'CLI002', 'FEN002', 'CAU004', 'EST003', 95, 100, 195, 3300.00, 2600.00, 4000.00, 180),
('FAC015', 'TIE002', 'AER006', 'RUT005', 'NAV005', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST004', 85, 90, 175, 14200.00, 3100.00, 0.00, 235),
('FAC016', 'TIE002', 'AER009', 'RUT006', 'NAV005', 'TRI002', 'CLI001', 'FEN001', 'CAU005', 'EST005', 130, 140, 270, 16500.00, 5200.00, 8500.00, 240),
('FAC017', 'TIE002', 'AER010', 'RUT007', 'NAV005', 'TRI003', 'CLI005', 'FEN005', 'CAU003', 'EST003', 105, 110, 215, 25800.00, 4600.00, 0.00, 240),
('FAC018', 'TIE002', 'AER004', 'RUT008', 'NAV001', 'TRI004', 'CLI004', 'FEN004', 'CAU001', 'EST002', 30, 35, 65, 1850.00, 950.00, 0.00, 160),
('FAC019', 'TIE002', 'AER005', 'RUT009', 'NAV002', 'TRI005', 'CLI002', 'FEN002', 'CAU004', 'EST004', 70, 75, 145, 2950.00, 1900.00, 3100.00, 170),
('FAC020', 'TIE002', 'AER008', 'RUT010', 'NAV003', 'TRI001', 'CLI004', 'FEN004', 'CAU002', 'EST001', 50, 55, 105, 1800.00, 1300.00, 0.00, 165),

('FAC021', 'TIE003', 'AER001', 'RUT001', 'NAV001', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 95, 2500.00, 1200.00, 0.00, 160),
('FAC022', 'TIE003', 'AER002', 'RUT002', 'NAV002', 'TRI004', 'CLI002', 'FEN002', 'CAU003', 'EST001', 60, 65, 125, 1400.00, 1500.00, 0.00, 170),
('FAC023', 'TIE003', 'AER003', 'RUT003', 'NAV003', 'TRI005', 'CLI003', 'FEN003', 'CAU005', 'EST005', 120, 130, 250, 1900.00, 3800.00, 6000.00, 185),
('FAC024', 'TIE003', 'AER007', 'RUT004', 'NAV004', 'TRI001', 'CLI005', 'FEN005', 'CAU003', 'EST003', 90, 95, 185, 3250.00, 2500.00, 0.00, 180),
('FAC025', 'TIE003', 'AER006', 'RUT005', 'NAV005', 'TRI002', 'CLI002', 'FEN002', 'CAU004', 'EST004', 75, 80, 155, 14100.00, 2900.00, 4500.00, 225),
('FAC026', 'TIE003', 'AER009', 'RUT006', 'NAV005', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST002', 35, 40, 75, 16100.00, 1000.00, 0.00, 230),
('FAC027', 'TIE003', 'AER010', 'RUT007', 'NAV005', 'TRI004', 'CLI005', 'FEN005', 'CAU002', 'EST003', 100, 105, 205, 25900.00, 4500.00, 0.00, 240),
('FAC028', 'TIE003', 'AER004', 'RUT008', 'NAV001', 'TRI005', 'CLI001', 'FEN001', 'CAU004', 'EST004', 80, 85, 165, 1950.00, 2100.00, 3000.00, 170),
('FAC029', 'TIE003', 'AER005', 'RUT009', 'NAV002', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST001', 55, 60, 115, 2850.00, 1400.00, 0.00, 160),
('FAC030', 'TIE003', 'AER008', 'RUT010', 'NAV003', 'TRI002', 'CLI004', 'FEN004', 'CAU001', 'EST002', 25, 30, 55, 1750.00, 850.00, 0.00, 155),

('FAC031', 'TIE004', 'AER001', 'RUT001', 'NAV001', 'TRI004', 'CLI001', 'FEN001', 'CAU004', 'EST004', 70, 75, 145, 2600.00, 1800.00, 2800.00, 165),
('FAC032', 'TIE004', 'AER002', 'RUT002', 'NAV002', 'TRI005', 'CLI002', 'FEN002', 'CAU005', 'EST005', 115, 125, 240, 1500.00, 3600.00, 5500.00, 175),
('FAC033', 'TIE004', 'AER003', 'RUT003', 'NAV003', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST001', 50, 55, 105, 1750.00, 1300.00, 0.00, 165),
('FAC034', 'TIE004', 'AER007', 'RUT004', 'NAV004', 'TRI002', 'CLI002', 'FEN005', 'CAU003', 'EST001', 65, 70, 135, 3150.00, 1700.00, 0.00, 170),
('FAC035', 'TIE004', 'AER006', 'RUT005', 'NAV005', 'TRI003', 'CLI003', 'FEN003', 'CAU002', 'EST003', 95, 100, 195, 14300.00, 3400.00, 0.00, 235),
('FAC036', 'TIE004', 'AER009', 'RUT006', 'NAV005', 'TRI004', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 95, 16250.00, 1250.00, 0.00, 220),
('FAC037', 'TIE004', 'AER010', 'RUT007', 'NAV005', 'TRI005', 'CLI005', 'FEN005', 'CAU004', 'EST004', 85, 90, 175, 25700.00, 4100.00, 6200.00, 240),
('FAC038', 'TIE004', 'AER004', 'RUT008', 'NAV001', 'TRI001', 'CLI004', 'FEN004', 'CAU001', 'EST002', 30, 35, 65, 1850.00, 900.00, 0.00, 155),
('FAC039', 'TIE004', 'AER005', 'RUT009', 'NAV002', 'TRI002', 'CLI003', 'FEN003', 'CAU002', 'EST001', 60, 65, 125, 2900.00, 1500.00, 0.00, 165),
('FAC040', 'TIE004', 'AER008', 'RUT010', 'NAV003', 'TRI003', 'CLI004', 'FEN004', 'CAU003', 'EST003', 90, 95, 185, 1850.00, 2300.00, 0.00, 180),

('FAC041', 'TIE005', 'AER001', 'RUT001', 'NAV001', 'TRI005', 'CLI001', 'FEN001', 'CAU001', 'EST001', 50, 55, 105, 2520.00, 1300.00, 0.00, 165),
('FAC042', 'TIE005', 'AER002', 'RUT002', 'NAV002', 'TRI001', 'CLI002', 'FEN002', 'CAU003', 'EST002', 35, 40, 75, 1380.00, 1000.00, 0.00, 155),
('FAC043', 'TIE005', 'AER003', 'RUT003', 'NAV003', 'TRI002', 'CLI003', 'FEN003', 'CAU004', 'EST004', 75, 80, 155, 1820.00, 2000.00, 3100.00, 175),
('FAC044', 'TIE005', 'AER007', 'RUT004', 'NAV004', 'TRI003', 'CLI005', 'FEN005', 'CAU005', 'EST005', 125, 135, 260, 3400.00, 4200.00, 6500.00, 185),
('FAC045', 'TIE005', 'AER006', 'RUT005', 'NAV005', 'TRI004', 'CLI002', 'FEN002', 'CAU003', 'EST001', 60, 65, 125, 14050.00, 2400.00, 0.00, 220),
('FAC046', 'TIE005', 'AER009', 'RUT006', 'NAV005', 'TRI005', 'CLI001', 'FEN001', 'CAU001', 'EST003', 95, 100, 195, 16400.00, 3700.00, 0.00, 235),
('FAC047', 'TIE005', 'AER010', 'RUT007', 'NAV005', 'TRI001', 'CLI005', 'FEN005', 'CAU002', 'EST001', 55, 60, 115, 25500.00, 2800.00, 0.00, 230),
('FAC048', 'TIE005', 'AER004', 'RUT008', 'NAV001', 'TRI002', 'CLI004', 'FEN004', 'CAU001', 'EST001', 45, 50, 95, 1880.00, 1200.00, 0.00, 160),
('FAC049', 'TIE005', 'AER005', 'RUT009', 'NAV002', 'TRI003', 'CLI003', 'FEN003', 'CAU004', 'EST004', 80, 85, 165, 2950.00, 2100.00, 3300.00, 175),
('FAC050', 'TIE005', 'AER008', 'RUT010', 'NAV003', 'TRI004', 'CLI004', 'FEN004', 'CAU002', 'EST002', 30, 35, 65, 1760.00, 900.00, 0.00, 150),

('FAC051', 'TIE006', 'AER001', 'RUT001', 'NAV001', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST002', 30, 35, 65, 2450.00, 950.00, 0.00, 155),
('FAC052', 'TIE006', 'AER002', 'RUT002', 'NAV002', 'TRI002', 'CLI002', 'FEN002', 'CAU004', 'EST004', 70, 75, 145, 1420.00, 1850.00, 2900.00, 170),
('FAC053', 'TIE006', 'AER003', 'RUT003', 'NAV003', 'TRI003', 'CLI003', 'FEN003', 'CAU002', 'EST003', 90, 95, 185, 1840.00, 2350.00, 0.00, 180),
('FAC054', 'TIE006', 'AER007', 'RUT004', 'NAV004', 'TRI004', 'CLI002', 'FEN005', 'CAU003', 'EST001', 55, 60, 115, 3180.00, 1550.00, 0.00, 165),
('FAC055', 'TIE006', 'AER006', 'RUT005', 'NAV005', 'TRI005', 'CLI005', 'FEN005', 'CAU005', 'EST005', 130, 140, 270, 14600.00, 5100.00, 8200.00, 245),
('FAC056', 'TIE006', 'AER009', 'RUT006', 'NAV005', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 95, 16200.00, 1200.00, 0.00, 225),
('FAC057', 'TIE006', 'AER010', 'RUT007', 'NAV005', 'TRI002', 'CLI005', 'FEN005', 'CAU003', 'EST003', 100, 105, 205, 25850.00, 4400.00, 0.00, 240),
('FAC058', 'TIE006', 'AER004', 'RUT008', 'NAV001', 'TRI003', 'CLI004', 'FEN004', 'CAU001', 'EST003', 85, 90, 175, 1920.00, 2200.00, 0.00, 175),
('FAC059', 'TIE006', 'AER005', 'RUT009', 'NAV002', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST002', 35, 40, 75, 2860.00, 1050.00, 0.00, 160),
('FAC060', 'TIE006', 'AER008', 'RUT010', 'NAV003', 'TRI005', 'CLI004', 'FEN004', 'CAU004', 'EST004', 75, 80, 155, 1830.00, 2050.00, 3150.00, 175),

('FAC061', 'TIE007', 'AER001', 'RUT001', 'NAV001', 'TRI002', 'CLI001', 'FEN001', 'CAU005', 'EST005', 110, 120, 230, 2650.00, 3500.00, 5400.00, 175),
('FAC062', 'TIE007', 'AER002', 'RUT002', 'NAV002', 'TRI003', 'CLI002', 'FEN002', 'CAU003', 'EST001', 60, 65, 125, 1410.00, 1500.00, 0.00, 165),
('FAC063', 'TIE007', 'AER003', 'RUT003', 'NAV003', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST001', 50, 55, 105, 1780.00, 1350.00, 0.00, 170),
('FAC064', 'TIE007', 'AER007', 'RUT004', 'NAV004', 'TRI005', 'CLI005', 'FEN005', 'CAU004', 'EST004', 80, 85, 165, 3280.00, 2150.00, 3400.00, 180),
('FAC065', 'TIE007', 'AER006', 'RUT005', 'NAV005', 'TRI001', 'CLI002', 'FEN002', 'CAU003', 'EST002', 35, 40, 75, 13950.00, 1400.00, 0.00, 215),
('FAC066', 'TIE007', 'AER009', 'RUT006', 'NAV005', 'TRI002', 'CLI001', 'FEN001', 'CAU001', 'EST001', 55, 60, 115, 16300.00, 1500.00, 0.00, 230),
('FAC067', 'TIE007', 'AER010', 'RUT007', 'NAV005', 'TRI003', 'CLI005', 'FEN005', 'CAU002', 'EST003', 105, 110, 215, 25950.00, 4650.00, 0.00, 245),
('FAC068', 'TIE007', 'AER004', 'RUT008', 'NAV001', 'TRI004', 'CLI004', 'FEN004', 'CAU004', 'EST004', 70, 75, 145, 1910.00, 1900.00, 2950.00, 165),
('FAC069', 'TIE007', 'AER005', 'RUT009', 'NAV002', 'TRI005', 'CLI003', 'FEN003', 'CAU002', 'EST003', 95, 100, 195, 3000.00, 2450.00, 0.00, 175),
('FAC070', 'TIE007', 'AER008', 'RUT010', 'NAV003', 'TRI001', 'CLI004', 'FEN004', 'CAU001', 'EST001', 45, 50, 95, 1790.00, 1200.00, 0.00, 160),

('FAC071', 'TIE008', 'AER001', 'RUT001', 'NAV001', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST001', 50, 55, 105, 2510.00, 1300.00, 0.00, 160),
('FAC072', 'TIE008', 'AER002', 'RUT002', 'NAV002', 'TRI004', 'CLI002', 'FEN002', 'CAU003', 'EST003', 90, 95, 185, 1460.00, 2300.00, 0.00, 175),
('FAC073', 'TIE008', 'AER003', 'RUT003', 'NAV003', 'TRI005', 'CLI003', 'FEN003', 'CAU004', 'EST004', 75, 80, 155, 1810.00, 2000.00, 3100.00, 170),
('FAC074', 'TIE008', 'AER007', 'RUT004', 'NAV004', 'TRI001', 'CLI002', 'FEN005', 'CAU003', 'EST002', 30, 35, 65, 3100.00, 950.00, 0.00, 160),
('FAC075', 'TIE008', 'AER006', 'RUT005', 'NAV005', 'TRI002', 'CLI003', 'FEN003', 'CAU002', 'EST001', 60, 65, 125, 14150.00, 2500.00, 0.00, 225),
('FAC076', 'TIE008', 'AER009', 'RUT006', 'NAV005', 'TRI003', 'CLI001', 'FEN001', 'CAU004', 'EST004', 85, 90, 175, 16350.00, 3300.00, 5100.00, 235),
('FAC077', 'TIE008', 'AER010', 'RUT007', 'NAV005', 'TRI004', 'CLI005', 'FEN005', 'CAU005', 'EST005', 135, 145, 280, 26100.00, 5500.00, 8800.00, 245),
('FAC078', 'TIE008', 'AER004', 'RUT008', 'NAV001', 'TRI005', 'CLI004', 'FEN004', 'CAU001', 'EST001', 55, 60, 115, 1890.00, 1400.00, 0.00, 165),
('FAC079', 'TIE008', 'AER005', 'RUT009', 'NAV002', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST002', 30, 35, 65, 2840.00, 950.00, 0.00, 155),
('FAC080', 'TIE008', 'AER008', 'RUT010', 'NAV003', 'TRI002', 'CLI004', 'FEN004', 'CAU003', 'EST001', 65, 70, 135, 1810.00, 1650.00, 0.00, 170),

('FAC081', 'TIE009', 'AER001', 'RUT001', 'NAV001', 'TRI004', 'CLI001', 'FEN001', 'CAU004', 'EST004', 75, 80, 155, 2580.00, 1950.00, 3050.00, 170),
('FAC082', 'TIE009', 'AER002', 'RUT002', 'NAV002', 'TRI005', 'CLI002', 'FEN002', 'CAU003', 'EST001', 50, 55, 105, 1390.00, 1300.00, 0.00, 160),
('FAC083', 'TIE009', 'AER003', 'RUT003', 'NAV003', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST002', 35, 40, 75, 1740.00, 1000.00, 0.00, 155),
('FAC084', 'TIE009', 'AER007', 'RUT004', 'NAV004', 'TRI002', 'CLI005', 'FEN005', 'CAU003', 'EST003', 95, 100, 195, 3260.00, 2550.00, 0.00, 180),
('FAC085', 'TIE009', 'AER006', 'RUT005', 'NAV005', 'TRI003', 'CLI002', 'FEN002', 'CAU004', 'EST004', 80, 85, 165, 14250.00, 3050.00, 4700.00, 230),
('FAC086', 'TIE009', 'AER009', 'RUT006', 'NAV005', 'TRI004', 'CLI001', 'FEN001', 'CAU001', 'EST002', 30, 35, 65, 16150.00, 950.00, 0.00, 220),
('FAC087', 'TIE009', 'AER010', 'RUT007', 'NAV005', 'TRI005', 'CLI005', 'FEN005', 'CAU002', 'EST001', 60, 65, 125, 25600.00, 3000.00, 0.00, 235),
('FAC088', 'TIE009', 'AER004', 'RUT008', 'NAV001', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 95, 1870.00, 1200.00, 0.00, 160),
('FAC089', 'TIE009', 'AER005', 'RUT009', 'NAV002', 'TRI002', 'CLI003', 'FEN003', 'CAU005', 'EST005', 120, 130, 250, 3050.00, 3900.00, 6100.00, 180),
('FAC090', 'TIE009', 'AER008', 'RUT010', 'NAV003', 'TRI003', 'CLI004', 'FEN004', 'CAU002', 'EST003', 90, 95, 185, 1840.00, 2350.00, 0.00, 175),

('FAC091', 'TIE010', 'AER001', 'RUT001', 'NAV001', 'TRI005', 'CLI002', 'FEN002', 'CAU003', 'EST003', 95, 100, 195, 2620.00, 2450.00, 0.00, 175),
('FAC092', 'TIE010', 'AER002', 'RUT002', 'NAV002', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST002', 30, 35, 65, 1360.00, 900.00, 0.00, 155),
('FAC093', 'TIE010', 'AER003', 'RUT003', 'NAV003', 'TRI002', 'CLI003', 'FEN003', 'CAU002', 'EST001', 55, 60, 115, 1790.00, 1450.00, 0.00, 165),
('FAC094', 'TIE010', 'AER007', 'RUT004', 'NAV004', 'TRI003', 'CLI002', 'FEN005', 'CAU004', 'EST004', 70, 75, 145, 3220.00, 1950.00, 3000.00, 170),
('FAC095', 'TIE010', 'AER006', 'RUT005', 'NAV005', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST001', 50, 55, 105, 14100.00, 2200.00, 0.00, 225),
('FAC096', 'TIE010', 'AER009', 'RUT006', 'NAV005', 'TRI005', 'CLI001', 'FEN001', 'CAU001', 'EST003', 100, 105, 205, 16450.00, 3800.00, 0.00, 240),
('FAC097', 'TIE010', 'AER010', 'RUT007', 'NAV005', 'TRI001', 'CLI005', 'FEN005', 'CAU004', 'EST004', 85, 90, 175, 25750.00, 4150.00, 6300.00, 235),
('FAC098', 'TIE010', 'AER004', 'RUT008', 'NAV001', 'TRI002', 'CLI001', 'FEN001', 'CAU005', 'EST005', 115, 125, 240, 1980.00, 3700.00, 5800.00, 175),
('FAC099', 'TIE010', 'AER005', 'RUT009', 'NAV002', 'TRI003', 'CLI003', 'FEN003', 'CAU002', 'EST001', 60, 65, 125, 2910.00, 1550.00, 0.00, 165),
('FAC100', 'TIE010', 'AER008', 'RUT010', 'NAV003', 'TRI004', 'CLI004', 'FEN004', 'CAU001', 'EST002', 35, 40, 75, 1770.00, 1000.00, 0.00, 155);
GO

SELECT * FROM FactDemoraVuelo