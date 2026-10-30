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
    Trimestre		VARCHAR(15)		NOT NULL,
    Mes				VARCHAR(20)		NOT NULL,
    DiaSemana		VARCHAR(15)		NOT NULL,
    EstacionAnio	VARCHAR(20)		NOT NULL,
    FranjaHoraria	VARCHAR(20)		NOT NULL,
    CONSTRAINT PK_DimTiempo PRIMARY KEY (IdTiempoPK)
);
GO

-- 2. Dimensión Aeropuerto
CREATE TABLE DimAeropuerto (
    IdAeropuertoPK				NCHAR(6)		NOT NULL,
    CodigoIATA					CHAR(3)			NOT NULL,
    NombreAeropuerto			VARCHAR(100)	NOT NULL,
    Ciudad						VARCHAR(50)		NOT NULL,
    Departamento				VARCHAR(50)		NOT NULL,
    CapacidadOperativaHora		INT				NOT NULL,
    CONSTRAINT PK_DimAeropuerto PRIMARY KEY (IdAeropuertoPK)
);
GO

-- 3. Dimensión Ruta
CREATE TABLE DimRuta (
    IdRutaPK		NCHAR(6)		NOT NULL,
    CodigoRuta		VARCHAR(15)		NOT NULL,
    CiudadOrigen	VARCHAR(50)		NOT NULL,
    CiudadDestino	VARCHAR(50)		NOT NULL,
    DistanciaKm		DECIMAL(8,2)	NOT NULL,
    DuracionMin		INT				NOT NULL,
    CONSTRAINT PK_DimRuta PRIMARY KEY (IdRutaPK)
);
GO

-- 4. Dimensión Aeronave
CREATE TABLE DimAeronave (
    IdAeronavePK			NCHAR(6)		NOT NULL,
    Matricula				VARCHAR(15)		NOT NULL,
    Modelo					VARCHAR(50)		NOT NULL,
    CapacidadPasajeros		INT				NOT NULL,
    ConsumoPromedioGalHora	DECIMAL(8,2)	NOT NULL,
    CONSTRAINT PK_DimAeronave PRIMARY KEY (IdAeronavePK)
);
GO

-- 5. Dimensión Tripulación
CREATE TABLE DimTripulacion (
    IdTripulacionPK			NCHAR(6)		NOT NULL,
    CodigoEquipo			VARCHAR(15)		NOT NULL,
    CapitanCargo			VARCHAR(80)		NOT NULL,
    HorasVueloAcumuladas	INT				NOT NULL,
    NivelFatiga				VARCHAR(20)		NOT NULL,
    TurnoOperativo			VARCHAR(20)		NOT NULL,
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
    NombreFenomeno		VARCHAR(60)		NOT NULL,
    TipoAnomalia		VARCHAR(50)		NOT NULL,
    NivelSeveridad		VARCHAR(25)		NOT NULL,
    CONSTRAINT PK_DimFenomenoClimatico PRIMARY KEY (IdFenomenoPK)
);
GO

-- 8. Dimensión Causa de Demora
CREATE TABLE DimCausaDemora (
    IdCausaPK				NCHAR(6)		NOT NULL,
    DescripcionCausa		VARCHAR(100)	NOT NULL,
    CategoriaCausa			VARCHAR(40)		NOT NULL,
    AplicaIndemnizacion		CHAR(2)			NOT NULL,
    CONSTRAINT PK_DimCausaDemora PRIMARY KEY (IdCausaPK)
);
GO

-- 9. Dimensión Estado de Vuelo
CREATE TABLE DimEstadoVuelo (
    IdEstadoPK					NCHAR(6)		NOT NULL,
    NumeroVuelo					VARCHAR(15)		NOT NULL,
    EstadoOperacion				VARCHAR(30)		NOT NULL,
    NivelImpactoItinerario		VARCHAR(30)		NOT NULL,
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
