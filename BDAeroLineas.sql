USE master
GO

-- Validación para eliminar y recrear la base de datos sin conflictos
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BDAerolineas')
    BEGIN
        ALTER DATABASE BDAerolineas SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        DROP DATABASE BDAerolineas
    END
GO

CREATE DATABASE BDAerolineas
GO

USE BDAerolineas
GO

-- =========================================================================
-- 1. CREACIÓN DE LAS 9 TABLAS DE DIMENSIONES
-- =========================================================================

CREATE TABLE dbo.DimTiempo
    (
    DimTiempoCodigo         NCHAR(6)		NOT NULL,
    DimTiempoFecha          DATE			NOT NULL,
    DimTiempoAnio           INT				NOT NULL,
    DimTiempoTrimestre      NVARCHAR(15)	NOT NULL,
    DimTiempoMes            NVARCHAR(20)	NOT NULL,
    DimTiempoDiaSemana      NVARCHAR(15)	NOT NULL,
    DimTiempoEstacionAnio   NVARCHAR(20)	NOT NULL,
    DimTiempoFranjaHoraria  NVARCHAR(20)	NOT NULL,
    CONSTRAINT DimTiempoPK PRIMARY KEY (DimTiempoCodigo)
    )
GO

CREATE TABLE dbo.DimAeropuerto
    (
    DimAeropuertoCodigo                 NCHAR(6)		NOT NULL,
    DimAeropuertoCodigoIATA             NCHAR(3)		NOT NULL,
    DimAeropuertoNombreAeropuerto       NVARCHAR(100)	NOT NULL,
    DimAeropuertoCiudad                 NVARCHAR(50)	NOT NULL,
    DimAeropuertoDepartamento           NVARCHAR(50)	NOT NULL,
    DimAeropuertoCapacidadOperativaHora INT				NOT NULL,
    CONSTRAINT DimAeropuertoPK PRIMARY KEY (DimAeropuertoCodigo)
    )
GO

CREATE TABLE dbo.DimRuta
    (
    DimRutaCodigo           NCHAR(6)		NOT NULL,
    DimRutaCodigoRuta		NVARCHAR(15)	NOT NULL,
    DimRutaCiudadOrigen     NVARCHAR(50)	NOT NULL,
    DimRutaCiudadDestino    NVARCHAR(50)	NOT NULL,
    DimRutaDistanciaKm		DECIMAL(8,2)	NOT NULL,
    DimRutaDuracionMin		INT				NOT NULL,
    CONSTRAINT DimRutaPK PRIMARY KEY (DimRutaCodigo)
    )
GO

CREATE TABLE dbo.DimAeronave
    (
    DimAeronaveCodigo			        NCHAR(6)		NOT NULL,
    DimAeronaveMatricula				NVARCHAR(15)	NOT NULL,
    DimAeronaveModelo					NVARCHAR(50)	NOT NULL,
    DimAeronaveCapacidadPasajeros		INT				NOT NULL,
    DimAeronaveConsumoPromedioGalHora   DECIMAL(8,2)	NOT NULL,
    CONSTRAINT DimAeronavePK PRIMARY KEY (DimAeronaveCodigo)
    )
GO

CREATE TABLE dbo.DimTripulacion
    (
    DimTripulacionCodigo			    NCHAR(6)		NOT NULL,
    DimTripulacionCodigoEquipo			NVARCHAR(15)	NOT NULL,
    DimTripulacionCapitanCargo			NVARCHAR(80)	NOT NULL,
    DimTripulacionHorasVueloAcumuladas  INT				NOT NULL,
    DimTripulacionNivelFatiga			NVARCHAR(20)	NOT NULL,
    DimTripulacionTurnoOperativo		NVARCHAR(20)	NOT NULL,
    CONSTRAINT DimTripulacionPK PRIMARY KEY (DimTripulacionCodigo)
    )
GO

CREATE TABLE dbo.DimClima
    (
    DimClimaCodigo				    NCHAR(6)		NOT NULL,
    DimClimaVelocidadVientoKmh		DECIMAL(6,2)	NOT NULL,
    DimClimaVisibilidadMetros		INT				NOT NULL,
    DimClimaPrecipitacionMm			DECIMAL(6,2)	NOT NULL,
    DimClimaTemperaturaGradosC		DECIMAL(5,2)	NOT NULL,
    DimClimaPresionAtmosfericaHpa   DECIMAL(6,2)	NOT NULL,
    CONSTRAINT DimClimaPK PRIMARY KEY (DimClimaCodigo)
    )
GO

CREATE TABLE dbo.DimFenomenoClimatico
    (
    DimFenomenoClimaticoCodigo		    NCHAR(6)		NOT NULL,
    DimFenomenoClimaticoNombreFenomeno  NVARCHAR(60)	NOT NULL,
    DimFenomenoClimaticoTipoAnomalia    NVARCHAR(50)	NOT NULL,
    DimFenomenoClimaticoNivelSeveridad  NVARCHAR(25)	NOT NULL,
    CONSTRAINT DimFenomenoClimaticoPK PRIMARY KEY (DimFenomenoClimaticoCodigo)
    )
GO

CREATE TABLE dbo.DimCausaDemora
    (
    DimCausaDemoraCodigo		        NCHAR(6)		NOT NULL,
    DimCausaDemoraDescripcionCausa      NVARCHAR(100)	NOT NULL,
    DimCausaDemoraCategoriaCausa	    NVARCHAR(40)	NOT NULL,
    DimCausaDemoraAplicaIndemnizacion   NCHAR(2)		NOT NULL,
    CONSTRAINT DimCausaDemoraPK PRIMARY KEY (DimCausaDemoraCodigo)
    )
GO

CREATE TABLE dbo.DimEstadoVuelo
    (
    DimEstadoVueloCodigo					NCHAR(6)		NOT NULL,
    DimEstadoVueloNumeroVuelo				NVARCHAR(15)	NOT NULL,
    DimEstadoVueloEstadoOperacion			NVARCHAR(30)	NOT NULL,
    DimEstadoVueloNivelImpactoItinerario    NVARCHAR(30)	NOT NULL,
    CONSTRAINT DimEstadoVueloPK PRIMARY KEY (DimEstadoVueloCodigo)
    )
GO

-- =========================================================================
-- 2. CREACIÓN DE LA TABLA DE HECHOS (Optimizada para OLAP)
-- =========================================================================

CREATE TABLE dbo.FactDemoraVuelo
    (
    FactDemoraVueloCodigo	                    NCHAR(6) NOT NULL,
    FactDemoraVueloDimTiempoCodigo			    NCHAR(6) NOT NULL,
    FactDemoraVueloDimAeropuertoCodigo		    NCHAR(6) NOT NULL,
    FactDemoraVueloDimRutaCodigo			    NCHAR(6) NOT NULL,
    FactDemoraVueloDimAeronaveCodigo		    NCHAR(6) NOT NULL,
    FactDemoraVueloDimTripulacionCodigo		    NCHAR(6) NOT NULL,
    FactDemoraVueloDimClimaCodigo               NCHAR(6) NOT NULL,
    FactDemoraVueloDimFenomenoClimaticoCodigo   CHAR(6) NOT NULL,
    FactDemoraVueloDimCausaDemoraCodigo			NCHAR(6) NOT NULL,
    FactDemoraVueloDimEstadoVueloCodigo			NCHAR(6) NOT NULL,
    
    -- Métricas cuantitativas corregidas
    FactDemoraVueloMinutosRetrasoSalida		    INT				NOT NULL DEFAULT 0,
    FactDemoraVueloMinutosRetrasoLlegada		INT				NOT NULL DEFAULT 0,
    FactDemoraVueloCombustibleAdicionalGal		DECIMAL(10,2)	NOT NULL DEFAULT 0.00, -- Refleja el combustible extra gastado por la demora
    FactDemoraVueloCostoOperativoAdicionalUSD   DECIMAL(10,2)	NOT NULL DEFAULT 0.00,
    FactDemoraVueloMontoIndemnizacionUSD		DECIMAL(10,2)	NOT NULL DEFAULT 0.00,
    FactDemoraVueloPasajerosAfectados			INT				NOT NULL DEFAULT 0,
    
    CONSTRAINT FactDemoraVueloPK PRIMARY KEY (FactDemoraVueloCodigo),
    CONSTRAINT FactDemoraVueloDimTiempoFK FOREIGN KEY (FactDemoraVueloDimTiempoCodigo) REFERENCES dbo.DimTiempo(DimTiempoCodigo),
    CONSTRAINT FactDemoraVueloDimAeropuertoFK FOREIGN KEY (FactDemoraVueloDimAeropuertoCodigo) REFERENCES dbo.DimAeropuerto(DimAeropuertoCodigo),
    CONSTRAINT FactDemoraVueloDimRuta FOREIGN KEY (FactDemoraVueloDimRutaCodigo) REFERENCES dbo.DimRuta(DimRutaCodigo),
    CONSTRAINT FactDemoraVueloDimAeronave FOREIGN KEY (FactDemoraVueloDimAeronaveCodigo) REFERENCES dbo.DimAeronave(DimAeronaveCodigo),
    CONSTRAINT FactDemoraVueloDimTripulacion FOREIGN KEY (FactDemoraVueloDimTripulacionCodigo) REFERENCES dbo.DimTripulacion(DimTripulacionCodigo),
    CONSTRAINT FactDemoraVueloDimClima FOREIGN KEY (FactDemoraVueloDimClimaCodigo) REFERENCES dbo.DimClima(DimClimaCodigo),
    CONSTRAINT FactDemoraVueloDimFenomenoClimatico FOREIGN KEY (FactDemoraVueloDimFenomenoClimaticoCodigo) REFERENCES dbo.DimFenomenoClimatico(DimFenomenoClimaticoCodigo),
    CONSTRAINT FactDemoraVueloDimCausaDemora FOREIGN KEY (FactDemoraVueloDimCausaDemoraCodigo) REFERENCES dbo.DimCausaDemora(DimCausaDemoraCodigo),
    CONSTRAINT FactDemoraVueloDimEstadoVuelo FOREIGN KEY (FactDemoraVueloDimEstadoVueloCodigo) REFERENCES dbo.DimEstadoVuelo(DimEstadoVueloCodigo)
    )
GO

SET DATEFORMAT dmy;
GO

-- =========================================================================
-- 3. POBLAMIENTO DE DATOS 
-- =========================================================================

INSERT INTO DimTiempo VALUES
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

INSERT INTO DimAeropuerto VALUES
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

INSERT INTO DimRuta VALUES
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

INSERT INTO DimAeronave VALUES
('NAV001', 'OB-2021', 'Airbus A320', 180, 820.00),
('NAV002', 'HK-5010', 'Airbus A320', 180, 820.00),
('NAV003', 'CC-3040', 'Boeing 737-800', 186, 850.00),
('NAV004', 'XA-7080', 'Boeing 737-800', 186, 850.00),
('NAV005', 'N-9015', 'Boeing 787-8', 250, 1450.00);
GO

INSERT INTO DimTripulacion VALUES
('TRI001', 'EQ-ALFA', 'Carlos Mendoza', 4500, 'Bajo', 'Mañana'),
('TRI002', 'EQ-BETA', 'Jorge Salazar', 5200, 'Medio', 'Tarde'),
('TRI003', 'EQ-GAMMA', 'Miguel Paredes', 6100, 'Alto', 'Noche'),
('TRI004', 'EQ-DELTA', 'Roberto Vargas', 4800, 'Medio', 'Mañana'),
('TRI005', 'EQ-OMEGA', 'Fernando Rojas', 5900, 'Alto', 'Noche');
GO

INSERT INTO DimClima VALUES
('CLI001', 25.00, 400, 2.50, 15.00, 1012.00),
('CLI002', 65.00, 1200, 45.00, 24.00, 1004.00),
('CLI003', 85.00, 2500, 10.00, 12.00, 998.00),
('CLI004', 40.00, 800, 15.00, -4.00, 985.00),
('CLI005', 95.00, 500, 70.00, 22.00, 990.00);
GO

INSERT INTO DimFenomenoClimatico VALUES
('FEN001', 'Neblina Densa Persistente', 'Atmosférica', 'Moderado'),
('FEN002', 'Fenómeno El Niño', 'Oceanográfica', 'Severo'),
('FEN003', 'Vientos Cruzados de Altura', 'Atmosférica', 'Severo'),
('FEN004', 'Helada Invernal Extrema', 'Térmica', 'Moderado'),
('FEN005', 'Tormenta Tropical / Tifón', 'Oceanográfica', 'Extremo');
GO

INSERT INTO DimCausaDemora VALUES
('CAU001', 'Baja visibilidad en pista por neblina', 'Fuerza Mayor Clima', 'NO'),
('CAU002', 'Vientos cruzados superiores al límite operativo', 'Fuerza Mayor Clima', 'NO'),
('CAU003', 'Pista anegada por precipitaciones extremas', 'Fuerza Mayor Clima', 'NO'),
('CAU004', 'Congestión de tráfico por cierre temporal climático', 'Logística Aeroportuaria', 'SI'),
('CAU005', 'Reprogramación de tripulación por demora acumulada', 'Logística Aeroportuaria', 'SI');
GO

INSERT INTO DimEstadoVuelo VALUES
('EST001', 'AV-101', 'Demorado', 'Moderado'),
('EST002', 'AV-205', 'Demorado', 'Bajo'),
('EST003', 'AV-310', 'Reprogramado', 'Crítico'),
('EST004', 'AV-415', 'Reprogramado', 'Moderado'),
('EST005', 'AV-520', 'Cancelado', 'Crítico');
GO

-- Se omite el Acumulado y el Combustible se ajusta a galones extra (aprox 10-15 galones por cada minuto de retraso total)
INSERT INTO FactDemoraVuelo VALUES
('FAC001', 'TIE001', 'AER001', 'RUT001', 'NAV001', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST001', 45, 50, 1140.00, 1200.00, 0.00, 160),
('FAC002', 'TIE001', 'AER002', 'RUT002', 'NAV002', 'TRI002', 'CLI002', 'FEN002', 'CAU003', 'EST001', 60, 65, 1500.00, 1500.00, 0.00, 170),
('FAC003', 'TIE001', 'AER003', 'RUT003', 'NAV003', 'TRI003', 'CLI003', 'FEN003', 'CAU002', 'EST003', 90, 95, 2220.00, 2400.00, 0.00, 180),
('FAC004', 'TIE001', 'AER007', 'RUT004', 'NAV004', 'TRI004', 'CLI002', 'FEN005', 'CAU004', 'EST004', 75, 80, 1860.00, 2100.00, 3500.00, 175),
('FAC005', 'TIE001', 'AER006', 'RUT005', 'NAV005', 'TRI005', 'CLI005', 'FEN005', 'CAU005', 'EST005', 120, 130, 3000.00, 5000.00, 8000.00, 240),
('FAC006', 'TIE001', 'AER009', 'RUT006', 'NAV005', 'TRI001', 'CLI001', 'FEN001', 'CAU001', 'EST002', 30, 35, 780.00, 900.00, 0.00, 230),
('FAC007', 'TIE001', 'AER010', 'RUT007', 'NAV005', 'TRI002', 'CLI005', 'FEN005', 'CAU003', 'EST003', 110, 115, 2700.00, 4800.00, 0.00, 245),
('FAC008', 'TIE001', 'AER004', 'RUT008', 'NAV001', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST001', 50, 55, 1260.00, 1300.00, 0.00, 165),
('FAC009', 'TIE001', 'AER005', 'RUT009', 'NAV002', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST002', 35, 40, 900.00, 1100.00, 0.00, 155),
('FAC010', 'TIE001', 'AER008', 'RUT010', 'NAV003', 'TRI005', 'CLI004', 'FEN004', 'CAU004', 'EST004', 80, 85, 1980.00, 2200.00, 3200.00, 180),
('FAC011', 'TIE002', 'AER001', 'RUT001', 'NAV001', 'TRI002', 'CLI002', 'FEN002', 'CAU003', 'EST001', 55, 60, 1380.00, 1400.00, 0.00, 160),
('FAC012', 'TIE002', 'AER002', 'RUT002', 'NAV002', 'TRI003', 'CLI001', 'FEN001', 'CAU001', 'EST002', 25, 30, 660.00, 800.00, 0.00, 150),
('FAC013', 'TIE002', 'AER003', 'RUT003', 'NAV003', 'TRI004', 'CLI003', 'FEN003', 'CAU002', 'EST001', 65, 70, 1620.00, 1600.00, 0.00, 175),
('FAC014', 'TIE002', 'AER007', 'RUT004', 'NAV004', 'TRI005', 'CLI002', 'FEN002', 'CAU004', 'EST003', 95, 100, 2340.00, 2600.00, 4000.00, 180),
('FAC015', 'TIE002', 'AER006', 'RUT005', 'NAV005', 'TRI001', 'CLI003', 'FEN003', 'CAU002', 'EST004', 85, 90, 2100.00, 3100.00, 0.00, 235),
('FAC016', 'TIE002', 'AER009', 'RUT006', 'NAV005', 'TRI002', 'CLI001', 'FEN001', 'CAU005', 'EST005', 130, 140, 3240.00, 5200.00, 8500.00, 240),
('FAC017', 'TIE002', 'AER010', 'RUT007', 'NAV005', 'TRI003', 'CLI005', 'FEN005', 'CAU003', 'EST003', 105, 110, 2580.00, 4600.00, 0.00, 240),
('FAC018', 'TIE002', 'AER004', 'RUT008', 'NAV001', 'TRI004', 'CLI004', 'FEN004', 'CAU001', 'EST002', 30, 35, 780.00, 950.00, 0.00, 160),
('FAC019', 'TIE002', 'AER005', 'RUT009', 'NAV002', 'TRI005', 'CLI002', 'FEN002', 'CAU004', 'EST004', 70, 75, 1740.00, 1900.00, 3100.00, 170),
('FAC020', 'TIE002', 'AER008', 'RUT010', 'NAV003', 'TRI001', 'CLI004', 'FEN004', 'CAU002', 'EST001', 50, 55, 1260.00, 1300.00, 0.00, 165);
GO