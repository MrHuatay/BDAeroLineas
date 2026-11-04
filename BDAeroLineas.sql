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
    FactDemoraVueloDimFenomenoClimaticoCodigo   NCHAR(6) NOT NULL,
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
    CONSTRAINT FactDemoraVueloDimRutaFK FOREIGN KEY (FactDemoraVueloDimRutaCodigo) REFERENCES dbo.DimRuta(DimRutaCodigo),
    CONSTRAINT FactDemoraVueloDimAeronaveFK FOREIGN KEY (FactDemoraVueloDimAeronaveCodigo) REFERENCES dbo.DimAeronave(DimAeronaveCodigo),
    CONSTRAINT FactDemoraVueloDimTripulacionFK FOREIGN KEY (FactDemoraVueloDimTripulacionCodigo) REFERENCES dbo.DimTripulacion(DimTripulacionCodigo),
    CONSTRAINT FactDemoraVueloDimClimaFK FOREIGN KEY (FactDemoraVueloDimClimaCodigo) REFERENCES dbo.DimClima(DimClimaCodigo),
    CONSTRAINT FactDemoraVueloDimFenomenoClimaticoFK FOREIGN KEY (FactDemoraVueloDimFenomenoClimaticoCodigo) REFERENCES dbo.DimFenomenoClimatico(DimFenomenoClimaticoCodigo),
    CONSTRAINT FactDemoraVueloDimCausaDemoraFK FOREIGN KEY (FactDemoraVueloDimCausaDemoraCodigo) REFERENCES dbo.DimCausaDemora(DimCausaDemoraCodigo),
    CONSTRAINT FactDemoraVueloDimEstadoVueloFK FOREIGN KEY (FactDemoraVueloDimEstadoVueloCodigo) REFERENCES dbo.DimEstadoVuelo(DimEstadoVueloCodigo)
    )
GO

SET DATEFORMAT dmy;
GO

-- =========================================================================
-- 3. POBLAMIENTO DE DATOS (100 REGISTROS POR TABLA CON BUCLE T-SQL)
-- =========================================================================
SET NOCOUNT ON;

DECLARE @i INT = 1;
DECLARE @Codigo VARCHAR(6);
DECLARE @Fecha DATE;

-- Configuración de idioma para que los meses y días se generen en español
SET LANGUAGE Spanish;

WHILE @i <= 100
BEGIN
    -- Generador de códigos en formato '001', '010', '100'
    SET @Codigo = RIGHT('000' + CAST(@i AS VARCHAR(3)), 3);
    
    -- 1. DimTiempo (100 días consecutivos desde el 01/01/2026)
    SET @Fecha = DATEADD(DAY, @i - 1, '2026-01-01');
    INSERT INTO dbo.DimTiempo (
        DimTiempoCodigo, DimTiempoFecha, DimTiempoAnio, DimTiempoTrimestre, 
        DimTiempoMes, DimTiempoDiaSemana, DimTiempoEstacionAnio, DimTiempoFranjaHoraria
    )
    VALUES (
        'TIE' + @Codigo, 
        @Fecha, 
        YEAR(@Fecha), 
        'Trimestre ' + CAST(DATENAME(QUARTER, @Fecha) AS VARCHAR(1)), 
        DATENAME(MONTH, @Fecha), 
        DATENAME(WEEKDAY, @Fecha), 
        CASE WHEN MONTH(@Fecha) IN (1,2,3) THEN 'Verano' ELSE 'Otoño' END, 
        CASE WHEN @i % 3 = 0 THEN 'Noche' WHEN @i % 2 = 0 THEN 'Tarde' ELSE 'Mañana' END
    );

    -- 2. DimAeropuerto
    INSERT INTO dbo.DimAeropuerto (
        DimAeropuertoCodigo, DimAeropuertoCodigoIATA, DimAeropuertoNombreAeropuerto, 
        DimAeropuertoCiudad, DimAeropuertoDepartamento, DimAeropuertoCapacidadOperativaHora
    )
    VALUES (
        'AER' + @Codigo, 
        'A' + RIGHT('00' + CAST(@i AS VARCHAR(2)), 2), 
        'Aeropuerto Internacional ' + CAST(@i AS VARCHAR), 
        'Ciudad ' + CAST(@i AS VARCHAR), 
        'Departamento ' + CAST(@i AS VARCHAR), 
        30 + (@i % 20)
    );

    -- 3. DimRuta
    INSERT INTO dbo.DimRuta (
        DimRutaCodigo, DimRutaCodigoRuta, DimRutaCiudadOrigen, 
        DimRutaCiudadDestino, DimRutaDistanciaKm, DimRutaDuracionMin
    )
    VALUES (
        'RUT' + @Codigo, 
        'R-' + @Codigo, 
        'Ciudad ' + CAST(@i AS VARCHAR), 
        'Ciudad ' + CAST(@i + 1 AS VARCHAR), 
        500.00 + (@i * 15.5), 
        60 + (@i % 120)
    );

    -- 4. DimAeronave
    INSERT INTO dbo.DimAeronave (
        DimAeronaveCodigo, DimAeronaveMatricula, DimAeronaveModelo, 
        DimAeronaveCapacidadPasajeros, DimAeronaveConsumoPromedioGalHora
    )
    VALUES (
        'NAV' + @Codigo, 
        'MAT-' + @Codigo, 
        CASE WHEN @i % 2 = 0 THEN 'Airbus A320' ELSE 'Boeing 737-800' END, 
        CASE WHEN @i % 2 = 0 THEN 180 ELSE 186 END, 
        800.00 + (@i * 2)
    );

    -- 5. DimTripulacion
    INSERT INTO dbo.DimTripulacion (
        DimTripulacionCodigo, DimTripulacionCodigoEquipo, DimTripulacionCapitanCargo, 
        DimTripulacionHorasVueloAcumuladas, DimTripulacionNivelFatiga, DimTripulacionTurnoOperativo
    )
    VALUES (
        'TRI' + @Codigo, 
        'EQ-' + @Codigo, 
        'Capitán Piloto ' + CAST(@i AS VARCHAR), 
        4000 + (@i * 50), 
        CASE WHEN @i % 3 = 0 THEN 'Alto' WHEN @i % 2 = 0 THEN 'Medio' ELSE 'Bajo' END, 
        CASE WHEN @i % 3 = 0 THEN 'Noche' WHEN @i % 2 = 0 THEN 'Tarde' ELSE 'Mañana' END
    );

    -- 6. DimClima
    INSERT INTO dbo.DimClima (
        DimClimaCodigo, DimClimaVelocidadVientoKmh, DimClimaVisibilidadMetros, 
        DimClimaPrecipitacionMm, DimClimaTemperaturaGradosC, DimClimaPresionAtmosfericaHpa
    )
    VALUES (
        'CLI' + @Codigo, 
        15.00 + (@i % 80), -- Viento variable
        3000 - (@i * 25),  -- Visibilidad decreciente
        0.00 + (@i % 50),  -- Lluvia variable
        -5.00 + (@i % 35), -- Temperaturas frías a cálidas
        980.00 + (@i % 40)
    );

    -- 7. DimFenomenoClimatico
    INSERT INTO dbo.DimFenomenoClimatico (
        DimFenomenoClimaticoCodigo, DimFenomenoClimaticoNombreFenomeno, 
        DimFenomenoClimaticoTipoAnomalia, DimFenomenoClimaticoNivelSeveridad
    )
    VALUES (
        'FEN' + @Codigo, 
        CASE WHEN @i % 3 = 0 THEN 'Neblina Densa Nivel ' + CAST(@i AS VARCHAR) 
             WHEN @i % 2 = 0 THEN 'Tormenta Tropical ' + CAST(@i AS VARCHAR) 
             ELSE 'Viento Cruzado ' + CAST(@i AS VARCHAR) END, 
        CASE WHEN @i % 2 = 0 THEN 'Oceanográfica' ELSE 'Atmosférica' END, 
        CASE WHEN @i % 3 = 0 THEN 'Crítico' WHEN @i % 2 = 0 THEN 'Severo' ELSE 'Moderado' END
    );

    -- 8. DimCausaDemora
    INSERT INTO dbo.DimCausaDemora (
        DimCausaDemoraCodigo, DimCausaDemoraDescripcionCausa, 
        DimCausaDemoraCategoriaCausa, DimCausaDemoraAplicaIndemnizacion
    )
    VALUES (
        'CAU' + @Codigo, 
        'Evento Operativo ' + CAST(@i AS VARCHAR), 
        CASE WHEN @i % 2 = 0 THEN 'Fuerza Mayor Clima' ELSE 'Logística Aeroportuaria' END, 
        CASE WHEN @i % 2 = 0 THEN 'NO' ELSE 'SI' END -- Clima no paga indemnización
    );

    -- 9. DimEstadoVuelo
    INSERT INTO dbo.DimEstadoVuelo (
        DimEstadoVueloCodigo, DimEstadoVueloNumeroVuelo, 
        DimEstadoVueloEstadoOperacion, DimEstadoVueloNivelImpactoItinerario
    )
    VALUES (
        'EST' + @Codigo, 
        'AV-' + @Codigo, 
        CASE WHEN @i % 4 = 0 THEN 'Cancelado' WHEN @i % 3 = 0 THEN 'Reprogramado' ELSE 'Demorado' END, 
        CASE WHEN @i % 4 = 0 THEN 'Crítico' WHEN @i % 3 = 0 THEN 'Alto' ELSE 'Moderado' END
    );

    -- 10. FactDemoraVuelo (Relacionando las 9 dimensiones generadas)
    INSERT INTO dbo.FactDemoraVuelo (
        FactDemoraVueloCodigo, FactDemoraVueloDimTiempoCodigo, FactDemoraVueloDimAeropuertoCodigo, 
        FactDemoraVueloDimRutaCodigo, FactDemoraVueloDimAeronaveCodigo, FactDemoraVueloDimTripulacionCodigo, 
        FactDemoraVueloDimClimaCodigo, FactDemoraVueloDimFenomenoClimaticoCodigo, FactDemoraVueloDimCausaDemoraCodigo, 
        FactDemoraVueloDimEstadoVueloCodigo, FactDemoraVueloMinutosRetrasoSalida, FactDemoraVueloMinutosRetrasoLlegada, 
        FactDemoraVueloCombustibleAdicionalGal, FactDemoraVueloCostoOperativoAdicionalUSD, FactDemoraVueloMontoIndemnizacionUSD, 
        FactDemoraVueloPasajerosAfectados
    )
    VALUES (
        'FAC' + @Codigo, 'TIE' + @Codigo, 'AER' + @Codigo, 'RUT' + @Codigo, 'NAV' + @Codigo, 
        'TRI' + @Codigo, 'CLI' + @Codigo, 'FEN' + @Codigo, 'CAU' + @Codigo, 'EST' + @Codigo, 
        30 + (@i % 60), -- Retraso Salida simulado
        40 + (@i % 60), -- Retraso Llegada simulado
        500.00 + (@i * 10), -- Combustible Adicional escalado
        1200.00 + (@i * 15), -- Costo Operativo escalado
        CASE WHEN @i % 2 = 0 THEN 0.00 ELSE 2500.00 + (@i * 20) END, -- Indemnización ligada a Causa Logística
        100 + (@i % 80) -- Pasajeros afectados
    );

    SET @i = @i + 1;
END;
GO