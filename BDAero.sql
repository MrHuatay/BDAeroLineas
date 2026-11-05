USE master
GO

-- Validación para eliminar y recrear la base de datos sin conflictos
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BDAero')
    BEGIN
        ALTER DATABASE BDAero SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        DROP DATABASE BDAero
    END
GO

CREATE DATABASE BDAero
GO

USE BDAero
GO

CREATE TABLE [DimAeronave] (
    [DimAeronaveCodigo] nchar(6),
    [DimAeronaveMatricula] nvarchar(15),
    [DimAeronaveModelo] nvarchar(50),
    [DimAeronaveCapacidadPasajeros] int,
    [DimAeronaveConsumoPromedioGalHora] numeric(8,2)
)
GO

CREATE TABLE [DimAeropuerto] (
    [DimAeropuertoCodigo] nchar(6),
    [DimAeropuertoCodigoIATA] nchar(3),
    [DimAeropuertoNombreAeropuerto] nvarchar(100),
    [DimAeropuertoCiudad] nvarchar(50),
    [DimAeropuertoDepartamento] nvarchar(50),
    [DimAeropuertoCapacidadOperativaHora] int
)
GO

CREATE TABLE [DimCausaDemora] (
    [DimCausaDemoraCodigo] nchar(6),
    [DimCausaDemoraDescripcionCausa] nvarchar(100),
    [DimCausaDemoraCategoriaCausa] nvarchar(40),
    [DimCausaDemoraAplicaIndemnizacion] nchar(2)
)
GO

CREATE TABLE [DimClima] (
    [DimClimaCodigo] nchar(6),
    [DimClimaVelocidadVientoKmh] numeric(6,2),
    [DimClimaVisibilidadMetros] int,
    [DimClimaPrecipitacionMm] numeric(6,2),
    [DimClimaTemperaturaGradosC] numeric(5,2),
    [DimClimaPresionAtmosfericaHpa] numeric(6,2)
)
GO

CREATE TABLE [DimEstadoVuelo] (
    [DimEstadoVueloCodigo] nchar(6),
    [DimEstadoVueloNumeroVuelo] nvarchar(15),
    [DimEstadoVueloEstadoOperacion] nvarchar(30),
    [DimEstadoVueloNivelImpactoItinerario] nvarchar(30)
)
GO

CREATE TABLE [DimFenomenoClimatico] (
    [DimFenomenoClimaticoCodigo] nchar(6),
    [DimFenomenoClimaticoNombreFenomeno] nvarchar(60),
    [DimFenomenoClimaticoTipoAnomalia] nvarchar(50),
    [DimFenomenoClimaticoNivelSeveridad] nvarchar(25)
)
GO

CREATE TABLE [DimRuta] (
    [DimRutaCodigo] nchar(6),
    [DimRutaCodigoRuta] nvarchar(15),
    [DimRutaCiudadOrigen] nvarchar(50),
    [DimRutaCiudadDestino] nvarchar(50),
    [DimRutaDistanciaKm] numeric(8,2),
    [DimRutaDuracionMin] int
)
GO

CREATE TABLE [DimTiempo] (
    [DimTiempoCodigo] nchar(6),
    [DimTiempoFecha] nvarchar(10),
    [DimTiempoAnio] int,
    [DimTiempoTrimestre] nvarchar(15),
    [DimTiempoMes] nvarchar(20),
    [DimTiempoDiaSemana] nvarchar(15),
    [DimTiempoEstacionAnio] nvarchar(20),
    [DimTiempoFranjaHoraria] nvarchar(20)
)
GO

CREATE TABLE [DimTripulacion] (
    [DimTripulacionCodigo] nchar(6),
    [DimTripulacionCodigoEquipo] nvarchar(15),
    [DimTripulacionCapitanCargo] nvarchar(80),
    [DimTripulacionHorasVueloAcumuladas] int,
    [DimTripulacionNivelFatiga] nvarchar(20),
    [DimTripulacionTurnoOperativo] nvarchar(20)
)
GO

CREATE TABLE [FactDemoraVuelo] (
    [FactDemoraVueloCodigo] nchar(6),
    [FactDemoraVueloDimTiempoCodigo] nchar(6),
    [FactDemoraVueloDimAeropuertoCodigo] nchar(6),
    [FactDemoraVueloDimRutaCodigo] nchar(6),
    [FactDemoraVueloDimAeronaveCodigo] nchar(6),
    [FactDemoraVueloDimTripulacionCodigo] nchar(6),
    [FactDemoraVueloDimClimaCodigo] nchar(6),
    [FactDemoraVueloDimFenomenoClimaticoCodigo] nchar(6),
    [FactDemoraVueloDimCausaDemoraCodigo] nchar(6),
    [FactDemoraVueloDimEstadoVueloCodigo] nchar(6),
    [FactDemoraVueloMinutosRetrasoSalida] int,
    [FactDemoraVueloMinutosRetrasoLlegada] int,
    [FactDemoraVueloCombustibleAdicionalGal] numeric(10,2),
    [FactDemoraVueloCostoOperativoAdicionalUSD] numeric(10,2),
    [FactDemoraVueloMontoIndemnizacionUSD] numeric(10,2),
    [FactDemoraVueloPasajerosAfectados] int
)
GO

