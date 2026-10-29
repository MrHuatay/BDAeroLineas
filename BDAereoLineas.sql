
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BDAereoLineas')
BEGIN
    CREATE DATABASE BDAereoLineas
END
GO

USE BDAereoLineas
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'Operaciones')
BEGIN
    EXEC('CREATE SCHEMA Operaciones')
END
GO

CREATE TABLE Operaciones.Tiempos
(
    TiemposCodigo CHAR(6) NOT NULL,
    TiemposFechaCompleta DATE NOT NULL
        CONSTRAINT TiemposFechaCompletaDF DEFAULT (GETDATE()),
    TiemposAnio INT NOT NULL
        CONSTRAINT TiemposAnioDF DEFAULT (2026),
    TiemposTrimestre INT NOT NULL
        CONSTRAINT TiemposTrimestreDF DEFAULT (1),
    TiemposMesNumero INT NOT NULL
        CONSTRAINT TiemposMesNumeroDF DEFAULT (1),
    TiemposMesNombre VARCHAR(20) NOT NULL
        CONSTRAINT TiemposMesNombreDF DEFAULT ('Enero'),
    TiemposDiaMes INT NOT NULL
        CONSTRAINT TiemposDiaMesDF DEFAULT (1),
    TiemposDiaSemanaNombre VARCHAR(20) NOT NULL
        CONSTRAINT TiemposDiaSemanaNombreDF DEFAULT ('Lunes'),
    TiemposEstacionClimatica VARCHAR(30) NOT NULL
        CONSTRAINT TiemposEstacionClimaticaDF DEFAULT ('Verano'),

    CONSTRAINT TiemposPK PRIMARY KEY  (TiemposCodigo),
    CONSTRAINT TiemposFechaCompletaUQ UNIQUE (TiemposFechaCompleta),
    CONSTRAINT TiemposTrimestreCK CHECK (TiemposTrimestre BETWEEN 1 AND 4),
    CONSTRAINT TiemposMesNumeroCK CHECK (TiemposMesNumero BETWEEN 1 AND 12)
)
GO

CREATE TABLE Operaciones.Aerolineas
(
    AerolineasCodigo CHAR(6) NOT NULL,
    AerolineasCodigoInternacional VARCHAR(10) NOT NULL
        CONSTRAINT AerolineasCodigoInternacionalDF DEFAULT ('SINREG'),
    AerolineasNombreComercial VARCHAR(100) NOT NULL
        CONSTRAINT AerolineasNombreComercialDF DEFAULT ('Por Definir'),
    AerolineasRazonSocial VARCHAR(150) NOT NULL
        CONSTRAINT AerolineasRazonSocialDF DEFAULT ('Por Definir'),
    AerolineasPaisOrigen VARCHAR(60) NOT NULL
        CONSTRAINT AerolineasPaisOrigenDF DEFAULT ('Peru'),
    AerolineasEstado CHAR(1) NOT NULL
        CONSTRAINT AerolineasEstadoDF DEFAULT ('A'),
    CONSTRAINT AerolineasPK PRIMARY KEY  (AerolineasCodigo),
    CONSTRAINT AerolineasCodigoInternacionalUQ UNIQUE (AerolineasCodigoInternacional),
    CONSTRAINT AerolineasEstadoCK CHECK (AerolineasEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.Aeropuertos
(
    AeropuertosCodigo CHAR(6) NOT NULL,
    AeropuertosCodigoInternacional VARCHAR(10) NOT NULL
        CONSTRAINT AeropuertosCodigoInternacionalDF DEFAULT ('SPIM'),
    AeropuertosNombreTerminal VARCHAR(150) NOT NULL
        CONSTRAINT AeropuertosNombreTerminalDF DEFAULT ('Por Definir'),
    AeropuertosCiudad VARCHAR(80) NOT NULL
        CONSTRAINT AeropuertosCiudadDF DEFAULT ('Lima'),
    AeropuertosDepartamento VARCHAR(80) NOT NULL
        CONSTRAINT AeropuertosDepartamentoDF DEFAULT ('Lima'),
    AeropuertosAltitudMetros INT NOT NULL
        CONSTRAINT AeropuertosAltitudMetrosDF DEFAULT (0),
    AeropuertosEstado CHAR(1) NOT NULL
        CONSTRAINT AeropuertosEstadoDF DEFAULT ('A'),
    CONSTRAINT AeropuertosPK PRIMARY KEY (AeropuertosCodigo),
    CONSTRAINT AeropuertosCodigoInternacionalUQ UNIQUE (AeropuertosCodigoInternacional),
    CONSTRAINT AeropuertosEstadoCK CHECK (AeropuertosEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.Aeronaves
(
    AeronavesCodigo CHAR(6) NOT NULL,
    AeronavesMatricula VARCHAR(20) NOT NULL
        CONSTRAINT AeronavesMatriculaDF DEFAULT ('OB0000'),
    AeronavesFabricante VARCHAR(80) NOT NULL
        CONSTRAINT AeronavesFabricanteDF DEFAULT ('Airbus'),
    AeronavesModelo VARCHAR(80) NOT NULL
        CONSTRAINT AeronavesModeloDF DEFAULT ('A320'),
    AeronavesCapacidadPasajeros INT NOT NULL
        CONSTRAINT AeronavesCapacidadPasajerosDF DEFAULT (180),
    AeronavesCapacidadCombustible DECIMAL(10,2) NOT NULL
        CONSTRAINT AeronavesCapacidadCombustibleDF DEFAULT (0.00),
    AeronavesEstado CHAR(1) NOT NULL
        CONSTRAINT AeronavesEstadoDF DEFAULT ('A'),
    CONSTRAINT AeronavesPK PRIMARY KEY  (AeronavesCodigo),
    CONSTRAINT AeronavesMatriculaUQ UNIQUE (AeronavesMatricula),
    CONSTRAINT AeronavesCapacidadPasajerosCK CHECK (AeronavesCapacidadPasajeros >= 0),
    CONSTRAINT AeronavesEstadoCK CHECK (AeronavesEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.Rutas
(
    RutasCodigo CHAR(6) NOT NULL,
    RutasCodigoRuta VARCHAR(20) NOT NULL
        CONSTRAINT RutasCodigoRutaDF DEFAULT ('LIMTRU'),
    RutasCiudadOrigen VARCHAR(80) NOT NULL
        CONSTRAINT RutasCiudadOrigenDF DEFAULT ('Lima'),
    RutasCiudadDestino VARCHAR(80) NOT NULL
        CONSTRAINT RutasCiudadDestinoDF DEFAULT ('Trujillo'),
    RutasDistanciaKilometros DECIMAL(10,2) NOT NULL
        CONSTRAINT RutasDistanciaKilometrosDF DEFAULT (0.00),
    RutasDuracionEstimadaMinutos INT NOT NULL
        CONSTRAINT RutasDuracionEstimadaMinutosDF DEFAULT (60),
    RutasEstado CHAR(1) NOT NULL
        CONSTRAINT RutasEstadoDF DEFAULT ('A'),
    CONSTRAINT RutasPK PRIMARY KEY  (RutasCodigo),
    CONSTRAINT RutasCodigoRutaUQ UNIQUE (RutasCodigoRuta),
    CONSTRAINT RutasDistanciaKilometrosCK CHECK (RutasDistanciaKilometros >= 0),
    CONSTRAINT RutasEstadoCK CHECK (RutasEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.Itinerarios
(
    ItinerariosCodigo CHAR(6) NOT NULL,
    ItinerariosNumeroVuelo VARCHAR(20) NOT NULL
        CONSTRAINT ItinerariosNumeroVueloDF DEFAULT ('LA2000'),
    ItinerariosHoraSalidaProgramada TIME NOT NULL
        CONSTRAINT ItinerariosHoraSalidaProgramadaDF DEFAULT ('08:00:00'),
    ItinerariosHoraLlegadaProgramada TIME NOT NULL
        CONSTRAINT ItinerariosHoraLlegadaProgramadaDF DEFAULT ('09:15:00'),
    ItinerariosTurnoOperacion VARCHAR(30) NOT NULL
        CONSTRAINT ItinerariosTurnoOperacionDF DEFAULT ('Manana'),
    ItinerariosEstado CHAR(1) NOT NULL
        CONSTRAINT ItinerariosEstadoDF DEFAULT ('A'),
    CONSTRAINT ItinerariosPK PRIMARY KEY  (ItinerariosCodigo),
    CONSTRAINT ItinerariosNumeroVueloUQ UNIQUE (ItinerariosNumeroVuelo),
    CONSTRAINT ItinerariosEstadoCK CHECK (ItinerariosEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.CondicionesClimaticas
(
    CondicionesClimaticasCodigo CHAR(6) NOT NULL,
    CondicionesClimaticasFenomenoTipo VARCHAR(80) NOT NULL
        CONSTRAINT CondicionesClimaticasFenomenoTipoDF DEFAULT ('Cielo Despejado'),
    CondicionesClimaticasNivelSeveridad VARCHAR(30) NOT NULL
        CONSTRAINT CondicionesClimaticasNivelSeveridadDF DEFAULT ('Bajo'),
    CondicionesClimaticasVisibilidadMetros DECIMAL(10,2) NOT NULL
        CONSTRAINT CondicionesClimaticasVisibilidadMetrosDF DEFAULT (10000.00),
    CondicionesClimaticasVelocidadViento DECIMAL(8,2) NOT NULL
        CONSTRAINT CondicionesClimaticasVelocidadVientoDF DEFAULT (5.00),
    CondicionesClimaticasPrecipitacionMilimetros DECIMAL(8,2) NOT NULL
        CONSTRAINT CondicionesClimaticasPrecipitacionMilimetrosDF DEFAULT (0.00),
    CondicionesClimaticasTemperaturaGrados DECIMAL(6,2) NOT NULL
        CONSTRAINT CondicionesClimaticasTemperaturaGradosDF DEFAULT (20.00),
    CondicionesClimaticasPresionAtmosferica DECIMAL(8,2) NOT NULL
        CONSTRAINT CondicionesClimaticasPresionAtmosfericaDF DEFAULT (1013.25),
    CONSTRAINT CondicionesClimaticasPK PRIMARY KEY  (CondicionesClimaticasCodigo),
    CONSTRAINT CondicionesClimaticasNivelSeveridadCK CHECK (CondicionesClimaticasNivelSeveridad IN ('Bajo', 'Moderado', 'Alto', 'Extremo')),
    CONSTRAINT CondicionesClimaticasVisibilidadMetrosCK CHECK (CondicionesClimaticasVisibilidadMetros >= 0)
)
GO

CREATE TABLE Operaciones.CausasDemoras
(
    CausasDemorasCodigo CHAR(6) NOT NULL,
    CausasDemorasCategoria VARCHAR(60) NOT NULL
        CONSTRAINT CausasDemorasCategoriaDF DEFAULT ('Meteorologica'),
    CausasDemorasDescripcion VARCHAR(150) NOT NULL
        CONSTRAINT CausasDemorasDescripcionDF DEFAULT ('Baja visibilidad por neblina'),
    CausasDemorasFuerzaMayor CHAR(2) NOT NULL
        CONSTRAINT CausasDemorasFuerzaMayorDF DEFAULT ('SI'),
    CausasDemorasAplicaIndemnizacion CHAR(2) NOT NULL
        CONSTRAINT CausasDemorasAplicaIndemnizacionDF DEFAULT ('NO'),
    CausasDemorasEstado CHAR(1) NOT NULL
        CONSTRAINT CausasDemorasEstadoDF DEFAULT ('A'),
    CONSTRAINT CausasDemorasPK PRIMARY KEY  (CausasDemorasCodigo),
    CONSTRAINT CausasDemorasFuerzaMayorCK CHECK (CausasDemorasFuerzaMayor IN ('SI', 'NO')),
    CONSTRAINT CausasDemorasAplicaIndemnizacionCK CHECK (CausasDemorasAplicaIndemnizacion IN ('SI', 'NO')),
    CONSTRAINT CausasDemorasEstadoCK CHECK (CausasDemorasEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.Tripulaciones
(
    TripulacionesCodigo CHAR(6) NOT NULL,
    TripulacionesCodigoEquipo VARCHAR(20) NOT NULL
        CONSTRAINT TripulacionesCodigoEquipoDF DEFAULT ('TRIP001'),
    TripulacionesComandanteNombre VARCHAR(120) NOT NULL
        CONSTRAINT TripulacionesComandanteNombreDF DEFAULT ('Por Asignar'),
    TripulacionesCopilotoNombre VARCHAR(120) NOT NULL
        CONSTRAINT TripulacionesCopilotoNombreDF DEFAULT ('Por Asignar'),
    TripulacionesCantidadIntegrantes INT NOT NULL
        CONSTRAINT TripulacionesCantidadIntegrantesDF DEFAULT (6),
    TripulacionesHorasVueloAcumuladas DECIMAL(8,2) NOT NULL
        CONSTRAINT TripulacionesHorasVueloAcumuladasDF DEFAULT (0.00),
    TripulacionesNivelFatiga VARCHAR(30) NOT NULL
        CONSTRAINT TripulacionesNivelFatigaDF DEFAULT ('Normal'),
    TripulacionesEstado CHAR(1) NOT NULL
        CONSTRAINT TripulacionesEstadoDF DEFAULT ('A'),
    CONSTRAINT TripulacionesPK PRIMARY KEY  (TripulacionesCodigo),
    CONSTRAINT TripulacionesCodigoEquipoUQ UNIQUE (TripulacionesCodigoEquipo),
    CONSTRAINT TripulacionesNivelFatigaCK CHECK (TripulacionesNivelFatiga IN ('Normal', 'Moderado', 'Critico')),
    CONSTRAINT TripulacionesEstadoCK CHECK (TripulacionesEstado IN ('A', 'I'))
)
GO

CREATE TABLE Operaciones.HechosDemorasVuelos
(
    HechosDemorasVuelosCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosTiemposCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosAerolineasCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosAeropuertosCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosAeronavesCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosRutasCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosItinerariosCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosCondicionesClimaticasCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosCausasDemorasCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosTripulacionesCodigo CHAR(6) NOT NULL,
    HechosDemorasVuelosMinutosRetrasoSalida INT NOT NULL
        CONSTRAINT HechosDemorasVuelosMinutosRetrasoSalidaDF DEFAULT (0),
    HechosDemorasVuelosMinutosRetrasoLlegada INT NOT NULL
        CONSTRAINT HechosDemorasVuelosMinutosRetrasoLlegadaDF DEFAULT (0),
    HechosDemorasVuelosMinutosRetrasoAcumulados INT NOT NULL
        CONSTRAINT HechosDemorasVuelosMinutosRetrasoAcumuladosDF DEFAULT (0),
    HechosDemorasVuelosConsumoCombustible DECIMAL(12,2) NOT NULL
        CONSTRAINT HechosDemorasVuelosConsumoCombustibleDF DEFAULT (0.00),
    HechosDemorasVuelosCostoOperativoAdicional DECIMAL(12,2) NOT NULL
        CONSTRAINT HechosDemorasVuelosCostoOperativoAdicionalDF DEFAULT (0.00),
    HechosDemorasVuelosMontoIndemnizacion DECIMAL(12,2) NOT NULL
        CONSTRAINT HechosDemorasVuelosMontoIndemnizacionDF DEFAULT (0.00),
    HechosDemorasVuelosPasajerosAfectados INT NOT NULL
        CONSTRAINT HechosDemorasVuelosPasajerosAfectadosDF DEFAULT (0),
    HechosDemorasVuelosVueloCancelado CHAR(2) NOT NULL
        CONSTRAINT HechosDemorasVuelosVueloCanceladoDF DEFAULT ('NO'),
    HechosDemorasVuelosFechaRegistro DATETIME NOT NULL
        CONSTRAINT HechosDemorasVuelosFechaRegistroDF DEFAULT (GETDATE()),
    CONSTRAINT HechosDemorasVuelosPK PRIMARY KEY  (HechosDemorasVuelosCodigo),
    CONSTRAINT HechosDemorasVuelosTiemposFK FOREIGN KEY (HechosDemorasVuelosTiemposCodigo)
        REFERENCES Operaciones.Tiempos (TiemposCodigo),
    CONSTRAINT HechosDemorasVuelosAerolineasFK FOREIGN KEY (HechosDemorasVuelosAerolineasCodigo)
        REFERENCES Operaciones.Aerolineas (AerolineasCodigo),
    CONSTRAINT HechosDemorasVuelosAeropuertosFK FOREIGN KEY (HechosDemorasVuelosAeropuertosCodigo)
        REFERENCES Operaciones.Aeropuertos (AeropuertosCodigo),
    CONSTRAINT HechosDemorasVuelosAeronavesFK FOREIGN KEY (HechosDemorasVuelosAeronavesCodigo)
        REFERENCES Operaciones.Aeronaves (AeronavesCodigo),
    CONSTRAINT HechosDemorasVuelosRutasFK FOREIGN KEY (HechosDemorasVuelosRutasCodigo)
        REFERENCES Operaciones.Rutas (RutasCodigo),
    CONSTRAINT HechosDemorasVuelosItinerariosFK FOREIGN KEY (HechosDemorasVuelosItinerariosCodigo)
        REFERENCES Operaciones.Itinerarios (ItinerariosCodigo),
    CONSTRAINT HechosDemorasVuelosCondicionesClimaticasFK FOREIGN KEY (HechosDemorasVuelosCondicionesClimaticasCodigo)
        REFERENCES Operaciones.CondicionesClimaticas (CondicionesClimaticasCodigo),
    CONSTRAINT HechosDemorasVuelosCausasDemorasFK FOREIGN KEY (HechosDemorasVuelosCausasDemorasCodigo)
        REFERENCES Operaciones.CausasDemoras (CausasDemorasCodigo),
    CONSTRAINT HechosDemorasVuelosTripulacionesFK FOREIGN KEY (HechosDemorasVuelosTripulacionesCodigo)
        REFERENCES Operaciones.Tripulaciones (TripulacionesCodigo),
    CONSTRAINT HechosDemorasVuelosMinutosRetrasoAcumuladosCK CHECK (HechosDemorasVuelosMinutosRetrasoAcumulados >= 0),
    CONSTRAINT HechosDemorasVuelosConsumoCombustibleCK CHECK (HechosDemorasVuelosConsumoCombustible >= 0),
    CONSTRAINT HechosDemorasVuelosVueloCanceladoCK CHECK (HechosDemorasVuelosVueloCancelado IN ('SI', 'NO'))
)
GO

CREATE NON INDEX HechosDemorasVuelosTiemposCodigoIDXa
    ON Operaciones.HechosDemorasVuelos (HechosDemorasVuelosTiemposCodigo ASC);

CREATE NON INDEX HechosDemorasVuelosCondicionesClimaticasCodigoIDXa
    ON Operaciones.HechosDemorasVuelos (HechosDemorasVuelosCondicionesClimaticasCodigo ASC);

CREATE NON INDEX HechosDemorasVuelosAeropuertosCodigoIDXa
    ON Operaciones.HechosDemorasVuelos (HechosDemorasVuelosAeropuertosCodigo ASC);

CREATE NON INDEX HechosDemorasVuelosMinutosRetrasoAcumuladosIDXd
    ON Operaciones.HechosDemorasVuelos (HechosDemorasVuelosMinutosRetrasoAcumulados DESC);
GO