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
    TiemposCodigo NCHAR(6) NOT NULL,
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
    AerolineasCodigo NCHAR(6) NOT NULL,
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
    AeropuertosCodigo NCHAR(6) NOT NULL,
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
    AeronavesCodigo NCHAR(6) NOT NULL,
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
    RutasCodigo NCHAR(6) NOT NULL,
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
    ItinerariosCodigo NCHAR(6) NOT NULL,
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
    CondicionesClimaticasCodigo NCHAR(6) NOT NULL,
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
    CausasDemorasCodigo NCHAR(6) NOT NULL,
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
    TripulacionesCodigo NCHAR(6) NOT NULL,
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

/*==============================================================================
  PROYECTO: Construcción de un cubo OLAP para mitigar demoras de vuelos 
            por cambios climáticos, Perú, 2026
  SCRIPT  : Poblamiento de Dimensiones y 150 Registros en Tabla de Hechos
  ESTÁNDAR: Estándares SQL Server - UCV (Columnas explícitas y SET NOCOUNT)
==============================================================================*/

USE BDMitigacionDemoraVuelo;
GO

SET NOCOUNT ON;
GO

-- =============================================================================
-- 1. POBLAMIENTO DE DIMENSIÓN: Operaciones.Tiempos (24 registros: TIE001 - TIE024)
-- =============================================================================
INSERT INTO Operaciones.Tiempos
(
    TiemposCodigo, TiemposFechaCompleta, TiemposAnio, TiemposTrimestre,
    TiemposMesNumero, TiemposMesNombre, TiemposDiaMes, TiemposDiaSemanaNombre,
    TiemposEstacionClimatica
)
VALUES
('TIE001', '2026-01-05', 2026, 1, 1,  'Enero',      5,  'Lunes',     'Verano'),
('TIE002', '2026-01-18', 2026, 1, 1,  'Enero',      18, 'Domingo',   'Verano'),
('TIE003', '2026-02-02', 2026, 1, 2,  'Febrero',    2,  'Lunes',     'Verano'),
('TIE004', '2026-02-14', 2026, 1, 2,  'Febrero',    14, 'Sabado',    'Verano'),
('TIE005', '2026-03-03', 2026, 1, 3,  'Marzo',      3,  'Martes',    'Verano'),
('TIE006', '2026-03-22', 2026, 1, 3,  'Marzo',      22, 'Domingo',   'Otono'),
('TIE007', '2026-04-08', 2026, 2, 4,  'Abril',      8,  'Miercoles', 'Otono'),
('TIE008', '2026-04-25', 2026, 2, 4,  'Abril',      25, 'Sabado',    'Otono'),
('TIE009', '2026-05-10', 2026, 2, 5,  'Mayo',       10, 'Domingo',   'Otono'),
('TIE010', '2026-05-27', 2026, 2, 5,  'Mayo',       27, 'Miercoles', 'Otono'),
('TIE011', '2026-06-11', 2026, 2, 6,  'Junio',      11, 'Jueves',    'Otono'),
('TIE012', '2026-06-24', 2026, 2, 6,  'Junio',      24, 'Miercoles', 'Invierno'),
('TIE013', '2026-07-09', 2026, 3, 7,  'Julio',      9,  'Jueves',    'Invierno'),
('TIE014', '2026-07-28', 2026, 3, 7,  'Julio',      28, 'Martes',    'Invierno'),
('TIE015', '2026-08-12', 2026, 3, 8,  'Agosto',     12, 'Miercoles', 'Invierno'),
('TIE016', '2026-08-29', 2026, 3, 8,  'Agosto',     29, 'Sabado',    'Invierno'),
('TIE017', '2026-09-07', 2026, 3, 9,  'Septiembre', 7,  'Lunes',     'Invierno'),
('TIE018', '2026-09-25', 2026, 3, 9,  'Septiembre', 25, 'Viernes',   'Primavera'),
('TIE019', '2026-10-06', 2026, 4, 10, 'Octubre',    6,  'Martes',    'Primavera'),
('TIE020', '2026-10-21', 2026, 4, 10, 'Octubre',    21, 'Miercoles', 'Primavera'),
('TIE021', '2026-11-04', 2026, 4, 11, 'Noviembre',  4,  'Miercoles', 'Primavera'),
('TIE022', '2026-11-19', 2026, 4, 11, 'Noviembre',  19, 'Jueves',    'Primavera'),
('TIE023', '2026-12-08', 2026, 4, 12, 'Diciembre',  8,  'Martes',    'Primavera'),
('TIE024', '2026-12-23', 2026, 4, 12, 'Diciembre',  23, 'Miercoles', 'Verano');
GO

-- =============================================================================
-- 2. POBLAMIENTO DE DIMENSIÓN: Operaciones.Aerolineas (6 registros: ARL001 - ARL006)
-- =============================================================================
INSERT INTO Operaciones.Aerolineas
(
    AerolineasCodigo, AerolineasCodigoInternacional, AerolineasNombreComercial,
    AerolineasRazonSocial, AerolineasPaisOrigen, AerolineasEstado
)
VALUES
('ARL001', 'LPE', 'LATAM Peru',       'LATAM Airlines Peru S.A.',              'Peru',     'A'),
('ARL002', 'SKX', 'Sky Airline Peru', 'Sky Airline Peru S.A.C.',               'Peru',     'A'),
('ARL003', 'JAP', 'JetSMART Peru',    'JetSMART Airlines Peru S.A.C.',         'Peru',     'A'),
('ARL004', 'SRU', 'Star Peru',        'Aerolineas Star Peru S.A.',             'Peru',     'A'),
('ARL005', 'AMP', 'ATSA Airlines',    'Aero Transporte S.A.',                  'Peru',     'A'),
('ARL006', 'VPE', 'Andes Air Peru',   'Compania de Aviacion Andina S.A.C.',    'Peru',     'I');
GO

-- =============================================================================
-- 3. POBLAMIENTO DE DIMENSIÓN: Operaciones.Aeropuertos (12 registros: ARP001 - ARP012)
-- =============================================================================
INSERT INTO Operaciones.Aeropuertos
(
    AeropuertosCodigo, AeropuertosCodigoInternacional, AeropuertosNombreTerminal,
    AeropuertosCiudad, AeropuertosDepartamento, AeropuertosAltitudMetros, AeropuertosEstado
)
VALUES
('ARP001', 'SPJC', 'Aeropuerto Internacional Jorge Chavez',                 'Lima',      'Lima',        34,   'A'),
('ARP002', 'SPZO', 'Aeropuerto Internacional Alejandro Velasco Astete',     'Cusco',     'Cusco',       3310, 'A'),
('ARP003', 'SPQU', 'Aeropuerto Internacional Rodriguez Ballon',             'Arequipa',  'Arequipa',    2560, 'A'),
('ARP004', 'SPRU', 'Aeropuerto Internacional Capitan FAP Carlos Martinez',  'Trujillo',  'La Libertad', 32,   'A'),
('ARP005', 'SPUR', 'Aeropuerto Internacional Capitan FAP Guillermo Concha', 'Piura',     'Piura',       53,   'A'),
('ARP006', 'SPQT', 'Aeropuerto Internacional Coronel FAP Francisco Secada', 'Iquitos',   'Loreto',      93,   'A'),
('ARP007', 'SPST', 'Aeropuerto Cadete FAP Guillermo del Castillo Paredes',  'Tarapoto',  'San Martin',  262,  'A'),
('ARP008', 'SPHI', 'Aeropuerto Internacional Capitan FAP Jose Abelardo',    'Chiclayo',  'Lambayeque',  30,   'A'),
('ARP009', 'SPJR', 'Aeropuerto Mayor General FAP Armando Revoredo Iglesias','Cajamarca', 'Cajamarca',   2676, 'A'),
('ARP010', 'SPJL', 'Aeropuerto Internacional Inca Manco Capac',             'Juliaca',   'Puno',        3826, 'A'),
('ARP011', 'SPCL', 'Aeropuerto Internacional Capitan FAP David Abensur',    'Pucallpa',  'Ucayali',     156,  'A'),
('ARP012', 'SPTN', 'Aeropuerto Internacional Coronel FAP Carlos Ciriani',   'Tacna',     'Tacna',       469,  'A');
GO

-- =============================================================================
-- 4. POBLAMIENTO DE DIMENSIÓN: Operaciones.Aeronaves (15 registros: ANV001 - ANV015)
-- =============================================================================
INSERT INTO Operaciones.Aeronaves
(
    AeronavesCodigo, AeronavesMatricula, AeronavesFabricante,
    AeronavesModelo, AeronavesCapacidadPasajeros, AeronavesCapacidadCombustible, AeronavesEstado
)
VALUES
('ANV001', 'OB2101', 'Airbus',   'A319-100',     144, 24210.00, 'A'),
('ANV002', 'OB2102', 'Airbus',   'A320-200',     180, 24210.00, 'A'),
('ANV003', 'OB2103', 'Airbus',   'A320neo',      186, 26730.00, 'A'),
('ANV004', 'OB2104', 'Airbus',   'A321neo',      224, 32940.00, 'A'),
('ANV005', 'OB2105', 'Boeing',   'B737-300',     143, 20100.00, 'A'),
('ANV006', 'OB2106', 'Boeing',   'B737-800',     189, 26020.00, 'A'),
('ANV007', 'OB2107', 'DeHavilland', 'Dash 8-Q400', 76, 6526.00, 'A'),
('ANV008', 'OB2108', 'Airbus',   'A320-214',     174, 24210.00, 'A'),
('ANV009', 'OB2109', 'Airbus',   'A320neo',      186, 26730.00, 'A'),
('ANV010', 'OB2110', 'Airbus',   'A319-132',     144, 24210.00, 'A'),
('ANV011', 'OB2111', 'Boeing',   'B737-500',     120, 17860.00, 'A'),
('ANV012', 'OB2112', 'Airbus',   'A320-232',     180, 24210.00, 'A'),
('ANV013', 'OB2113', 'Airbus',   'A321-200',     220, 30030.00, 'A'),
('ANV014', 'OB2114', 'Embraer',  'E190-LR',      104, 12971.00, 'A'),
('ANV015', 'OB2115', 'Airbus',   'A320neo',      186, 26730.00, 'I');
GO

-- =============================================================================
-- 5. POBLAMIENTO DE DIMENSIÓN: Operaciones.Rutas (15 registros: RUT001 - RUT015)
-- =============================================================================
INSERT INTO Operaciones.Rutas
(
    RutasCodigo, RutasCodigoRuta, RutasCiudadOrigen, RutasCiudadDestino,
    RutasDistanciaKilometros, RutasDuracionEstimadaMinutos, RutasEstado
)
VALUES
('RUT001', 'LIM-CUS', 'Lima',      'Cusco',     585.00, 80,  'A'),
('RUT002', 'CUS-LIM', 'Cusco',     'Lima',      585.00, 85,  'A'),
('RUT003', 'LIM-AQP', 'Lima',      'Arequipa',  766.00, 90,  'A'),
('RUT004', 'AQP-LIM', 'Arequipa',  'Lima',      766.00, 95,  'A'),
('RUT005', 'LIM-TRU', 'Lima',      'Trujillo',  489.00, 65,  'A'),
('RUT006', 'TRU-LIM', 'Trujillo',  'Lima',      489.00, 65,  'A'),
('RUT007', 'LIM-PIU', 'Lima',      'Piura',     858.00, 100, 'A'),
('RUT008', 'PIU-LIM', 'Piura',     'Lima',      858.00, 100, 'A'),
('RUT009', 'LIM-IQT', 'Lima',      'Iquitos',   1008.00,115, 'A'),
('RUT010', 'IQT-LIM', 'Iquitos',   'Lima',      1008.00,115, 'A'),
('RUT011', 'LIM-TPP', 'Lima',      'Tarapoto',  620.00, 80,  'A'),
('RUT012', 'LIM-CIX', 'Lima',      'Chiclayo',  662.00, 85,  'A'),
('RUT013', 'LIM-CJA', 'Lima',      'Cajamarca', 565.00, 75,  'A'),
('RUT014', 'LIM-JUL', 'Lima',      'Juliaca',   842.00, 100, 'A'),
('RUT015', 'CUS-JUL', 'Cusco',     'Juliaca',   295.00, 50,  'A');
GO

-- =============================================================================
-- 6. POBLAMIENTO DE DIMENSIÓN: Operaciones.Itinerarios (20 registros: ITI001 - ITI020)
-- =============================================================================
INSERT INTO Operaciones.Itinerarios
(
    ItinerariosCodigo, ItinerariosNumeroVuelo, ItinerariosHoraSalidaProgramada,
    ItinerariosHoraLlegadaProgramada, ItinerariosTurnoOperacion, ItinerariosEstado
)
VALUES
('ITI001', 'LA2010', '05:30:00', '06:50:00', 'Madrugada', 'A'),
('ITI002', 'LA2025', '06:45:00', '08:10:00', 'Manana',    'A'),
('ITI003', 'LA2112', '07:30:00', '09:00:00', 'Manana',    'A'),
('ITI004', 'LA2140', '08:15:00', '09:20:00', 'Manana',    'A'),
('ITI005', 'LA2205', '09:30:00', '11:10:00', 'Manana',    'A'),
('ITI006', 'H85010', '10:15:00', '12:10:00', 'Manana',    'A'),
('ITI007', 'H85042', '11:00:00', '12:20:00', 'Manana',    'A'),
('ITI008', 'H85115', '12:30:00', '13:55:00', 'Tarde',     'A'),
('ITI009', 'H85200', '13:45:00', '15:00:00', 'Tarde',     'A'),
('ITI010', 'JA7010', '14:20:00', '16:00:00', 'Tarde',     'A'),
('ITI011', 'JA7055', '15:10:00', '16:30:00', 'Tarde',     'A'),
('ITI012', 'JA7120', '16:00:00', '17:35:00', 'Tarde',     'A'),
('ITI013', 'JA7210', '17:15:00', '18:20:00', 'Tarde',     'A'),
('ITI014', '2I1102', '18:00:00', '19:20:00', 'Noche',     'A'),
('ITI015', '2I1145', '18:45:00', '20:40:00', 'Noche',     'A'),
('ITI016', '2I1210', '19:30:00', '20:45:00', 'Noche',     'A'),
('ITI017', '4A4010', '20:15:00', '21:40:00', 'Noche',     'A'),
('ITI018', '4A4088', '21:00:00', '22:05:00', 'Noche',     'A'),
('ITI019', 'LA2390', '22:10:00', '23:50:00', 'Noche',     'A'),
('ITI020', 'H85399', '23:00:00', '00:15:00', 'Madrugada', 'A');
GO

-- =============================================================================
-- 7. POBLAMIENTO DE DIMENSIÓN: Operaciones.CondicionesClimaticas (15 registros: CLI001 - CLI015)
-- =============================================================================
INSERT INTO Operaciones.CondicionesClimaticas
(
    CondicionesClimaticasCodigo, CondicionesClimaticasFenomenoTipo, CondicionesClimaticasNivelSeveridad,
    CondicionesClimaticasVisibilidadMetros, CondicionesClimaticasVelocidadViento,
    CondicionesClimaticasPrecipitacionMilimetros, CondicionesClimaticasTemperaturaGrados,
    CondicionesClimaticasPresionAtmosferica
)
VALUES
('CLI001', 'Cielo Despejado',                     'Bajo',     10000.00, 8.50,  0.00,  22.50, 1013.25),
('CLI002', 'Bruma Costera Ligera',                'Bajo',     6500.00,  12.00, 0.20,  18.00, 1012.80),
('CLI003', 'Neblina Densa en Pista',              'Alto',     900.00,   14.20, 1.50,  14.50, 1010.40),
('CLI004', 'Niebla Severa de Invierno',           'Extremo',  350.00,   16.80, 2.80,  12.20, 1009.10),
('CLI005', 'Lluvia Moderada Amazónica',           'Moderado', 3800.00,  22.40, 18.50, 25.00, 1008.60),
('CLI006', 'Tormenta Electrica Tropical',         'Extremo',  800.00,   58.00, 65.40, 23.10, 1002.30),
('CLI007', 'Viento Cruzado Andino Moderado',      'Moderado', 7500.00,  34.50, 0.00,  11.80, 1018.50),
('CLI008', 'Rafagas de Viento Severas en Altura', 'Alto',     4200.00,  52.30, 4.20,  7.50,  1020.10),
('CLI009', 'Granizada y Helada Altiplanica',      'Extremo',  600.00,   46.00, 32.00, -3.50, 1022.40),
('CLI010', 'Lluvias Intensas Fenomeno El Nino',   'Alto',     1500.00,  41.20, 48.90, 27.80, 1004.70),
('CLI011', 'Anomalia Termica Extrema Costera',    'Moderado', 8200.00,  19.00, 5.10,  31.40, 1007.90),
('CLI012', 'Nubosidad Baja en Aproximacion',      'Moderado', 2800.00,  25.60, 6.40,  15.30, 1011.20),
('CLI013', 'Cizalladura de Viento en Umbral',     'Extremo',  1900.00,  64.50, 12.00, 9.40,  1005.80),
('CLI014', 'Llovizna Persistente y Techo Bajo',   'Moderado', 2400.00,  21.00, 8.70,  16.10, 1010.90),
('CLI015', 'Tormenta de Arena y Viento Paracas',  'Alto',     1100.00,  49.80, 0.00,  24.60, 1006.50);
GO

-- =============================================================================
-- 8. POBLAMIENTO DE DIMENSIÓN: Operaciones.CausasDemoras (10 registros: CAU001 - CAU010)
-- =============================================================================
INSERT INTO Operaciones.CausasDemoras
(
    CausasDemorasCodigo, CausasDemorasCategoria, CausasDemorasDescripcion,
    CausasDemorasFuerzaMayor, CausasDemorasAplicaIndemnizacion, CausasDemorasEstado
)
VALUES
('CAU001', 'Sin Demora',     'Operacion puntual dentro del margen de itinerario',                'NO', 'NO', 'A'),
('CAU002', 'Meteorologica',  'Visibilidad reducida por neblina densa en umbral de pista',       'SI', 'NO', 'A'),
('CAU003', 'Meteorologica',  'Vientos cruzados severos y cizalladura en aproximacion',          'SI', 'NO', 'A'),
('CAU004', 'Meteorologica',  'Tormenta electrica y precipitacion pluvial intensa',              'SI', 'NO', 'A'),
('CAU005', 'Meteorologica',  'Congelamiento de pista y granizada en terminal de altura',        'SI', 'NO', 'A'),
('CAU006', 'Meteorologica',  'Cierre temporal de terminal por anomalias de El Nino Costero',    'SI', 'NO', 'A'),
('CAU007', 'Efecto Cascada', 'Llegada tardia de aeronave por mal clima en tramo previo',        'SI', 'NO', 'A'),
('CAU008', 'Logistica',      'Demora en reprogramacion de tripulacion tras contingencia',       'NO', 'SI', 'A'),
('CAU009', 'Operativa',      'Congestion en plataforma y reabastecimiento lento en rampa',      'NO', 'SI', 'A'),
('CAU010', 'Trafico Aereo',  'Restriccion de flujo en ruta por saturacion de espacio aereo',    'SI', 'NO', 'A');
GO

-- =============================================================================
-- 9. POBLAMIENTO DE DIMENSIÓN: Operaciones.Tripulaciones (15 registros: TRI001 - TRI015)
-- =============================================================================
INSERT INTO Operaciones.Tripulaciones
(
    TripulacionesCodigo, TripulacionesCodigoEquipo, TripulacionesComandanteNombre,
    TripulacionesCopilotoNombre, TripulacionesCantidadIntegrantes,
    TripulacionesHorasVueloAcumuladas, TripulacionesNivelFatiga, TripulacionesEstado
)
VALUES
('TRI001', 'EQP-A01', 'Carlos Mendoza Vargas',     'Diego Salazar Quispe',    6, 42.50, 'Normal',   'A'),
('TRI002', 'EQP-A02', 'Roberto Paredes Lozano',    'Valeria Castro Montes',   6, 58.00, 'Normal',   'A'),
('TRI003', 'EQP-A03', 'Fernando Silva Huaman',     'Jorge Chavez Pinedo',     6, 71.20, 'Moderado', 'A'),
('TRI004', 'EQP-A04', 'Miguel Angel Torres Ruiz',  'Andrea Morales Diaz',     5, 36.80, 'Normal',   'A'),
('TRI005', 'EQP-A05', 'Ricardo Gomez Villavicencio','Sebastian Rojas Medina', 6, 84.50, 'Critico',  'A'),
('TRI006', 'EQP-B01', 'Alejandro Vargas Benites',  'Lucia Fernandez Soto',    6, 49.00, 'Normal',   'A'),
('TRI007', 'EQP-B02', 'Hector Delgado Palacios',   'Martin Caceres Luna',     6, 65.40, 'Moderado', 'A'),
('TRI008', 'EQP-B03', 'Gustavo Herrera Zavaleta',  'Camila Ortiz Guevara',    6, 53.10, 'Normal',   'A'),
('TRI009', 'EQP-B04', 'Eduardo Carrillo Espinoza', 'Daniela Ramos Aguila',    4, 39.00, 'Normal',   'A'),
('TRI010', 'EQP-B05', 'Javier Montoya Sempertegui','Rodrigo Alarcon Vera',    6, 78.90, 'Moderado', 'A'),
('TRI011', 'EQP-C01', 'Oscar Bustamante Leon',     'Patricia Navarro Cruz',   6, 88.20, 'Critico',  'A'),
('TRI012', 'EQP-C02', 'Sergio Villanueva Prado',   'Alvaro Fuentes Merino',   6, 44.75, 'Normal',   'A'),
('TRI013', 'EQP-C03', 'Cesar Augusto Mejia Rios',  'Natalia Cordova Paz',     6, 61.30, 'Moderado', 'A'),
('TRI014', 'EQP-C04', 'Raul Santisteban Galvez',   'Gabriel Pacheco Tapia',   5, 50.60, 'Normal',   'A'),
('TRI015', 'EQP-C05', 'Marco Antonio Ponce Cuba',  'Fiorella Guzman Salas',   6, 74.00, 'Moderado', 'A');
GO

-- =============================================================================
-- 10. POBLAMIENTO DE TABLA DE HECHOS: Operaciones.HechosDemorasVuelos 
--     (150 REGISTROS DIFERENTES: HDV001 - HDV150)
-- =============================================================================
INSERT INTO Operaciones.HechosDemorasVuelos
(
    HechosDemorasVuelosCodigo,
    HechosDemorasVuelosTiemposCodigo,
    HechosDemorasVuelosAerolineasCodigo,
    HechosDemorasVuelosAeropuertosCodigo,
    HechosDemorasVuelosAeronavesCodigo,
    HechosDemorasVuelosRutasCodigo,
    HechosDemorasVuelosItinerariosCodigo,
    HechosDemorasVuelosCondicionesClimaticasCodigo,
    HechosDemorasVuelosCausasDemorasCodigo,
    HechosDemorasVuelosTripulacionesCodigo,
    HechosDemorasVuelosMinutosRetrasoSalida,
    HechosDemorasVuelosMinutosRetrasoLlegada,
    HechosDemorasVuelosMinutosRetrasoAcumulados,
    HechosDemorasVuelosConsumoCombustible,
    HechosDemorasVuelosCostoOperativoAdicional,
    HechosDemorasVuelosMontoIndemnizacion,
    HechosDemorasVuelosPasajerosAfectados,
    HechosDemorasVuelosVueloCancelado,
    HechosDemorasVuelosFechaRegistro
)
VALUES
('HDV001','TIE001','ARL001','ARP001','ANV001','RUT001','ITI001','CLI001','CAU001','TRI001',0,0,0,2450.00,0.00,0.00,0,'NO','2026-01-05 07:00:00'),
('HDV002','TIE001','ARL001','ARP002','ANV002','RUT002','ITI002','CLI007','CAU003','TRI002',25,30,55,2890.50,1450.00,0.00,168,'NO','2026-01-05 08:45:00'),
('HDV003','TIE001','ARL002','ARP004','ANV003','RUT005','ITI003','CLI002','CAU001','TRI003',5,0,5,2110.00,120.00,0.00,15,'NO','2026-01-05 09:10:00'),
('HDV004','TIE001','ARL003','ARP003','ANV004','RUT003','ITI004','CLI008','CAU003','TRI004',45,50,95,3420.75,2850.00,0.00,210,'NO','2026-01-05 11:00:00'),
('HDV005','TIE001','ARL004','ARP006','ANV005','RUT009','ITI005','CLI005','CAU004','TRI005',35,40,75,3680.00,2210.00,0.00,138,'NO','2026-01-05 12:30:00'),
('HDV006','TIE001','ARL005','ARP007','ANV007','RUT011','ITI006','CLI006','CAU004','TRI006',120,130,250,1850.00,6400.00,0.00,74,'SI','2026-01-05 14:20:00'),
('HDV007','TIE002','ARL001','ARP005','ANV002','RUT007','ITI007','CLI010','CAU006','TRI007',65,70,135,3150.20,4120.00,0.00,175,'NO','2026-01-18 14:35:00'),
('HDV008','TIE002','ARL002','ARP008','ANV008','RUT012','ITI008','CLI010','CAU006','TRI008',50,55,105,2740.00,3180.00,0.00,162,'NO','2026-01-18 15:40:00'),
('HDV009','TIE002','ARL003','ARP001','ANV009','RUT006','ITI009','CLI011','CAU008','TRI009',40,45,85,2290.00,2540.00,1850.00,170,'NO','2026-01-18 16:30:00'),
('HDV010','TIE002','ARL001','ARP010','ANV010','RUT014','ITI010','CLI009','CAU005','TRI010',90,95,185,3390.40,5420.00,0.00,140,'NO','2026-01-18 19:05:00'),
('HDV011','TIE002','ARL004','ARP011','ANV011','RUT009','ITI011','CLI005','CAU004','TRI011',30,35,65,2950.00,1920.00,0.00,115,'NO','2026-01-18 17:40:00'),
('HDV012','TIE002','ARL002','ARP009','ANV012','RUT013','ITI012','CLI012','CAU002','TRI012',20,25,45,2380.00,1310.00,0.00,154,'NO','2026-01-18 18:20:00'),
('HDV013','TIE003','ARL001','ARP001','ANV003','RUT001','ITI013','CLI001','CAU001','TRI013',0,0,0,2510.00,0.00,0.00,0,'NO','2026-02-02 18:30:00'),
('HDV014','TIE003','ARL003','ARP002','ANV004','RUT002','ITI014','CLI008','CAU003','TRI014',55,60,115,3510.80,3490.00,0.00,215,'NO','2026-02-02 21:15:00'),
('HDV015','TIE003','ARL002','ARP004','ANV006','RUT005','ITI015','CLI010','CAU006','TRI015',75,80,155,2640.00,4680.00,0.00,182,'NO','2026-02-02 23:10:00'),
('HDV016','TIE003','ARL005','ARP006','ANV007','RUT010','ITI016','CLI006','CAU004','TRI001',110,120,230,1920.50,6100.00,0.00,72,'SI','2026-02-02 23:30:00'),
('HDV017','TIE003','ARL001','ARP005','ANV001','RUT008','ITI017','CLI010','CAU008','TRI002',60,65,125,2980.00,3750.00,2420.00,142,'NO','2026-02-02 23:45:00'),
('HDV018','TIE003','ARL004','ARP003','ANV005','RUT004','ITI018','CLI007','CAU007','TRI003',25,30,55,2790.00,1640.00,0.00,136,'NO','2026-02-02 23:55:00'),
('HDV019','TIE004','ARL002','ARP001','ANV008','RUT001','ITI019','CLI002','CAU001','TRI004',0,5,5,2560.00,140.00,0.00,12,'NO','2026-02-14 23:58:00'),
('HDV020','TIE004','ARL003','ARP012','ANV009','RUT003','ITI020','CLI015','CAU003','TRI005',45,50,95,2890.00,2890.00,0.00,178,'NO','2026-02-14 23:59:00'),
('HDV021','TIE004','ARL001','ARP004','ANV002','RUT006','ITI001','CLI010','CAU006','TRI006',80,85,165,2490.30,4920.00,0.00,176,'NO','2026-02-14 09:35:00'),
('HDV022','TIE004','ARL002','ARP005','ANV003','RUT007','ITI002','CLI010','CAU006','TRI007',95,100,195,3320.00,5810.00,0.00,184,'NO','2026-02-14 11:25:00'),
('HDV023','TIE004','ARL003','ARP008','ANV010','RUT012','ITI003','CLI011','CAU009','TRI008',30,35,65,2580.00,1950.00,1340.00,140,'NO','2026-02-14 10:15:00'),
('HDV024','TIE004','ARL004','ARP007','ANV011','RUT011','ITI004','CLI005','CAU004','TRI009',40,45,85,2610.00,2480.00,0.00,118,'NO','2026-02-14 10:50:00'),
('HDV025','TIE005','ARL001','ARP002','ANV012','RUT002','ITI005','CLI008','CAU003','TRI010',50,55,105,2970.00,3120.00,0.00,172,'NO','2026-03-03 13:00:00'),
('HDV026','TIE005','ARL002','ARP010','ANV013','RUT014','ITI006','CLI009','CAU005','TRI011',105,115,220,3840.50,6540.00,0.00,212,'SI','2026-03-03 15:50:00'),
('HDV027','TIE005','ARL005','ARP009','ANV014','RUT013','ITI007','CLI012','CAU002','TRI012',35,40,75,2120.00,2190.00,0.00,98,'NO','2026-03-03 13:45:00'),
('HDV028','TIE005','ARL003','ARP004','ANV001','RUT005','ITI008','CLI010','CAU006','TRI013',70,75,145,2390.00,4320.00,0.00,141,'NO','2026-03-03 16:20:00'),
('HDV029','TIE005','ARL001','ARP006','ANV002','RUT009','ITI009','CLI006','CAU004','TRI014',85,90,175,3750.00,5210.00,0.00,179,'NO','2026-03-03 17:55:00'),
('HDV030','TIE005','ARL002','ARP001','ANV003','RUT003','ITI010','CLI002','CAU001','TRI015',0,0,0,2810.00,0.00,0.00,0,'NO','2026-03-03 16:10:00'),
('HDV031','TIE006','ARL003','ARP003','ANV004','RUT004','ITI011','CLI007','CAU003','TRI001',20,25,45,3120.00,1350.00,0.00,198,'NO','2026-03-22 17:15:00'),
('HDV032','TIE006','ARL004','ARP011','ANV005','RUT010','ITI012','CLI005','CAU007','TRI002',35,40,75,3410.00,2250.00,0.00,139,'NO','2026-03-22 18:50:00'),
('HDV033','TIE006','ARL001','ARP001','ANV006','RUT001','ITI013','CLI003','CAU002','TRI003',45,50,95,2780.00,2840.00,0.00,185,'NO','2026-03-22 19:55:00'),
('HDV034','TIE006','ARL002','ARP002','ANV008','RUT015','ITI014','CLI008','CAU003','TRI004',30,35,65,1890.00,1940.00,0.00,166,'NO','2026-03-22 20:30:00'),
('HDV035','TIE006','ARL005','ARP004','ANV007','RUT006','ITI015','CLI002','CAU008','TRI005',25,30,55,1540.00,1620.00,1120.00,70,'NO','2026-03-22 21:40:00'),
('HDV036','TIE006','ARL003','ARP005','ANV009','RUT008','ITI016','CLI011','CAU001','TRI006',5,5,10,2950.00,290.00,0.00,22,'NO','2026-03-22 21:00:00'),
('HDV037','TIE007','ARL001','ARP001','ANV010','RUT005','ITI017','CLI003','CAU002','TRI007',40,45,85,2240.00,2510.00,0.00,140,'NO','2026-04-08 23:05:00'),
('HDV038','TIE007','ARL002','ARP009','ANV012','RUT013','ITI018','CLI012','CAU002','TRI008',50,55,105,2460.00,3150.00,0.00,171,'NO','2026-04-08 23:50:00'),
('HDV039','TIE007','ARL004','ARP006','ANV011','RUT009','ITI019','CLI005','CAU004','TRI009',30,35,65,3180.00,1960.00,0.00,116,'NO','2026-04-08 23:55:00'),
('HDV040','TIE007','ARL001','ARP002','ANV013','RUT002','ITI020','CLI013','CAU003','TRI010',95,105,200,3690.00,5980.00,0.00,218,'SI','2026-04-08 23:59:00'),
('HDV041','TIE007','ARL003','ARP003','ANV001','RUT003','ITI001','CLI001','CAU001','TRI011',0,0,0,2650.00,0.00,0.00,0,'NO','2026-04-08 07:05:00'),
('HDV042','TIE007','ARL002','ARP008','ANV002','RUT012','ITI002','CLI014','CAU002','TRI012',25,30,55,2590.00,1650.00,0.00,169,'NO','2026-04-08 09:10:00'),
('HDV043','TIE008','ARL001','ARP001','ANV003','RUT001','ITI003','CLI003','CAU002','TRI013',55,60,115,2820.00,3420.00,0.00,181,'NO','2026-04-25 11:00:00'),
('HDV044','TIE008','ARL005','ARP007','ANV014','RUT011','ITI004','CLI005','CAU004','TRI014',35,40,75,2190.00,2210.00,0.00,101,'NO','2026-04-25 10:40:00'),
('HDV045','TIE008','ARL003','ARP010','ANV004','RUT014','ITI005','CLI009','CAU005','TRI015',80,85,165,3780.00,4950.00,0.00,216,'NO','2026-04-25 13:55:00'),
('HDV046','TIE008','ARL002','ARP004','ANV006','RUT006','ITI006','CLI014','CAU009','TRI001',30,35,65,2340.00,1940.00,1480.00,177,'NO','2026-04-25 13:20:00'),
('HDV047','TIE008','ARL004','ARP012','ANV005','RUT004','ITI007','CLI015','CAU003','TRI002',45,50,95,2840.00,2810.00,0.00,135,'NO','2026-04-25 14:00:00'),
('HDV048','TIE008','ARL001','ARP005','ANV008','RUT007','ITI008','CLI001','CAU001','TRI003',0,0,0,2890.00,0.00,0.00,0,'NO','2026-04-25 14:05:00'),
('HDV049','TIE009','ARL002','ARP001','ANV009','RUT001','ITI009','CLI003','CAU002','TRI004',60,65,125,2880.00,3740.00,0.00,180,'NO','2026-05-10 17:10:00'),
('HDV050','TIE009','ARL003','ARP002','ANV010','RUT002','ITI010','CLI008','CAU007','TRI005',45,50,95,2740.00,2850.00,0.00,141,'NO','2026-05-10 17:40:00'),
('HDV051','TIE009','ARL001','ARP003','ANV012','RUT003','ITI011','CLI007','CAU003','TRI006',25,30,55,2910.00,1620.00,0.00,174,'NO','2026-05-10 17:30:00'),
('HDV052','TIE009','ARL004','ARP006','ANV011','RUT010','ITI012','CLI006','CAU004','TRI007',90,100,190,3490.00,5680.00,0.00,119,'NO','2026-05-10 20:45:00'),
('HDV053','TIE009','ARL005','ARP009','ANV007','RUT013','ITI013','CLI012','CAU002','TRI008',40,45,85,1680.00,2540.00,0.00,73,'NO','2026-05-10 19:45:00'),
('HDV054','TIE009','ARL002','ARP004','ANV013','RUT005','ITI014','CLI014','CAU002','TRI009',30,35,65,2610.00,1950.00,0.00,208,'NO','2026-05-10 20:30:00'),
('HDV055','TIE010','ARL001','ARP001','ANV001','RUT006','ITI015','CLI004','CAU002','TRI010',85,90,175,2480.00,5240.00,0.00,143,'NO','2026-05-27 23:35:00'),
('HDV056','TIE010','ARL003','ARP010','ANV002','RUT014','ITI016','CLI009','CAU005','TRI011',110,120,230,3420.00,6890.00,0.00,178,'SI','2026-05-27 23:50:00'),
('HDV057','TIE010','ARL002','ARP008','ANV003','RUT012','ITI017','CLI014','CAU008','TRI012',45,50,95,2690.00,2840.00,1920.00,182,'NO','2026-05-27 23:55:00'),
('HDV058','TIE010','ARL004','ARP011','ANV005','RUT009','ITI018','CLI005','CAU004','TRI013',35,40,75,3290.00,2230.00,0.00,140,'NO','2026-05-27 23:58:00'),
('HDV059','TIE010','ARL001','ARP005','ANV004','RUT008','ITI019','CLI001','CAU001','TRI014',0,0,0,3180.00,0.00,0.00,0,'NO','2026-05-27 23:59:00'),
('HDV060','TIE010','ARL005','ARP002','ANV014','RUT015','ITI020','CLI008','CAU003','TRI015',50,55,105,1790.00,3140.00,0.00,102,'NO','2026-05-27 23:59:00'),
('HDV061','TIE011','ARL001','ARP001','ANV006','RUT001','ITI001','CLI004','CAU002','TRI001',95,100,195,2950.00,5820.00,0.00,187,'NO','2026-06-11 10:10:00'),
('HDV062','TIE011','ARL002','ARP002','ANV008','RUT002','ITI002','CLI013','CAU003','TRI002',115,125,240,3120.00,7150.00,0.00,171,'SI','2026-06-11 12:15:00'),
('HDV063','TIE011','ARL003','ARP004','ANV009','RUT005','ITI003','CLI003','CAU002','TRI003',50,55,105,2410.00,3120.00,0.00,183,'NO','2026-06-11 10:45:00'),
('HDV064','TIE011','ARL004','ARP003','ANV011','RUT003','ITI004','CLI007','CAU010','TRI004',30,35,65,2680.00,1950.00,0.00,117,'NO','2026-06-11 10:30:00'),
('HDV065','TIE011','ARL001','ARP010','ANV010','RUT014','ITI005','CLI009','CAU005','TRI005',85,95,180,3350.00,5390.00,0.00,142,'NO','2026-06-11 14:15:00'),
('HDV066','TIE011','ARL002','ARP009','ANV012','RUT013','ITI006','CLI012','CAU002','TRI006',40,45,85,2490.00,2540.00,0.00,175,'NO','2026-06-11 13:35:00'),
('HDV067','TIE012','ARL003','ARP001','ANV013','RUT004','ITI007','CLI004','CAU002','TRI007',100,110,210,3620.00,6280.00,0.00,214,'NO','2026-06-24 15:50:00'),
('HDV068','TIE012','ARL005','ARP007','ANV007','RUT011','ITI008','CLI005','CAU004','TRI008',25,30,55,1690.00,1640.00,0.00,71,'NO','2026-06-24 14:55:00'),
('HDV069','TIE012','ARL001','ARP006','ANV001','RUT009','ITI009','CLI006','CAU004','TRI009',75,80,155,3480.00,4620.00,0.00,140,'NO','2026-06-24 17:35:00'),
('HDV070','TIE012','ARL002','ARP004','ANV002','RUT006','ITI010','CLI003','CAU007','TRI010',45,50,95,2390.00,2850.00,0.00,176,'NO','2026-06-24 17:40:00'),
('HDV071','TIE012','ARL004','ARP012','ANV005','RUT003','ITI011','CLI015','CAU003','TRI011',55,60,115,2890.00,3420.00,0.00,138,'NO','2026-06-24 18:30:00'),
('HDV072','TIE012','ARL003','ARP008','ANV003','RUT012','ITI012','CLI014','CAU009','TRI012',35,40,75,2640.00,2240.00,1560.00,180,'NO','2026-06-24 18:50:00'),
('HDV073','TIE013','ARL001','ARP001','ANV004','RUT001','ITI013','CLI004','CAU002','TRI013',105,115,220,3390.00,6580.00,0.00,220,'SI','2026-07-09 22:00:00'),
('HDV074','TIE013','ARL002','ARP010','ANV006','RUT014','ITI014','CLI009','CAU005','TRI014',90,100,190,3410.00,5690.00,0.00,186,'NO','2026-07-09 22:30:00'),
('HDV075','TIE013','ARL003','ARP002','ANV008','RUT002','ITI015','CLI008','CAU003','TRI015',60,65,125,2960.00,3740.00,0.00,170,'NO','2026-07-09 22:50:00'),
('HDV076','TIE013','ARL005','ARP009','ANV014','RUT013','ITI016','CLI012','CAU008','TRI001',50,55,105,2180.00,3120.00,2100.00,100,'NO','2026-07-09 22:35:00'),
('HDV077','TIE013','ARL001','ARP004','ANV009','RUT005','ITI017','CLI003','CAU002','TRI002',40,45,85,2370.00,2540.00,0.00,181,'NO','2026-07-09 23:10:00'),
('HDV078','TIE013','ARL004','ARP005','ANV011','RUT007','ITI018','CLI001','CAU001','TRI003',0,0,0,2750.00,0.00,0.00,0,'NO','2026-07-09 22:15:00'),
('HDV079','TIE014','ARL001','ARP001','ANV010','RUT001','ITI019','CLI004','CAU002','TRI004',80,85,165,2740.00,4920.00,0.00,143,'NO','2026-07-28 23:55:00'),
('HDV080','TIE014','ARL002','ARP002','ANV012','RUT002','ITI020','CLI013','CAU003','TRI005',95,105,200,3080.00,5980.00,0.00,179,'NO','2026-07-28 23:59:00'),
('HDV081','TIE014','ARL003','ARP003','ANV013','RUT003','ITI001','CLI007','CAU010','TRI006',35,40,75,3340.00,2240.00,0.00,215,'NO','2026-07-28 08:10:00'),
('HDV082','TIE014','ARL001','ARP010','ANV001','RUT015','ITI002','CLI009','CAU005','TRI007',70,75,145,1980.00,4320.00,0.00,141,'NO','2026-07-28 10:40:00'),
('HDV083','TIE014','ARL002','ARP004','ANV002','RUT006','ITI003','CLI003','CAU002','TRI008',45,50,95,2420.00,2840.00,0.00,175,'NO','2026-07-28 10:35:00'),
('HDV084','TIE014','ARL004','ARP006','ANV005','RUT010','ITI004','CLI005','CAU004','TRI009',30,35,65,3390.00,1950.00,0.00,137,'NO','2026-07-28 10:30:00'),
('HDV085','TIE015','ARL003','ARP001','ANV003','RUT004','ITI005','CLI004','CAU002','TRI010',90,95,185,3050.00,5520.00,0.00,184,'NO','2026-08-12 14:15:00'),
('HDV086','TIE015','ARL005','ARP007','ANV007','RUT011','ITI006','CLI006','CAU004','TRI011',100,110,210,1840.00,6250.00,0.00,75,'SI','2026-08-12 15:40:00'),
('HDV087','TIE015','ARL001','ARP002','ANV004','RUT001','ITI007','CLI008','CAU003','TRI012',65,70,135,3460.00,4020.00,0.00,219,'NO','2026-08-12 14:35:00'),
('HDV088','TIE015','ARL002','ARP008','ANV006','RUT012','ITI008','CLI014','CAU002','TRI013',35,40,75,2680.00,2240.00,0.00,183,'NO','2026-08-12 15:15:00'),
('HDV089','TIE015','ARL003','ARP012','ANV008','RUT003','ITI009','CLI015','CAU003','TRI014',55,60,115,2920.00,3440.00,0.00,169,'NO','2026-08-12 16:55:00'),
('HDV090','TIE015','ARL001','ARP005','ANV009','RUT008','ITI010','CLI001','CAU001','TRI015',0,0,0,2940.00,0.00,0.00,0,'NO','2026-08-12 16:05:00'),
('HDV091','TIE016','ARL002','ARP001','ANV010','RUT005','ITI011','CLI003','CAU002','TRI001',50,55,105,2350.00,3140.00,0.00,142,'NO','2026-08-29 18:15:00'),
('HDV092','TIE016','ARL004','ARP011','ANV011','RUT009','ITI012','CLI005','CAU008','TRI002',40,45,85,3150.00,2540.00,1780.00,118,'NO','2026-08-29 19:00:00'),
('HDV093','TIE016','ARL001','ARP010','ANV012','RUT014','ITI013','CLI009','CAU005','TRI003',85,90,175,3380.00,5210.00,0.00,177,'NO','2026-08-29 21:15:00'),
('HDV094','TIE016','ARL003','ARP009','ANV013','RUT013','ITI014','CLI012','CAU007','TRI004',30,35,65,2740.00,1950.00,0.00,209,'NO','2026-08-29 20:25:00'),
('HDV095','TIE016','ARL005','ARP004','ANV014','RUT006','ITI015','CLI002','CAU001','TRI005',5,5,10,1890.00,280.00,0.00,18,'NO','2026-08-29 20:50:00'),
('HDV096','TIE016','ARL002','ARP002','ANV001','RUT002','ITI016','CLI008','CAU003','TRI006',60,65,125,2690.00,3740.00,0.00,141,'NO','2026-08-29 22:50:00'),
('HDV097','TIE017','ARL001','ARP001','ANV002','RUT001','ITI017','CLI003','CAU002','TRI007',45,50,95,2790.00,2840.00,0.00,176,'NO','2026-09-07 23:15:00'),
('HDV098','TIE017','ARL003','ARP003','ANV003','RUT004','ITI018','CLI007','CAU003','TRI008',25,30,55,2880.00,1640.00,0.00,182,'NO','2026-09-07 23:00:00'),
('HDV099','TIE017','ARL002','ARP006','ANV004','RUT010','ITI019','CLI006','CAU004','TRI009',95,105,200,3980.00,5980.00,0.00,218,'SI','2026-09-07 23:55:00'),
('HDV100','TIE017','ARL004','ARP008','ANV005','RUT012','ITI020','CLI014','CAU009','TRI010',35,40,75,2590.00,2240.00,1490.00,136,'NO','2026-09-07 23:59:00'),
('HDV101','TIE017','ARL001','ARP004','ANV006','RUT005','ITI001','CLI002','CAU001','TRI011',0,0,0,2280.00,0.00,0.00,0,'NO','2026-09-07 07:00:00'),
('HDV102','TIE017','ARL005','ARP007','ANV007','RUT011','ITI002','CLI005','CAU004','TRI012',30,35,65,1650.00,1940.00,0.00,72,'NO','2026-09-07 09:15:00'),
('HDV103','TIE018','ARL002','ARP002','ANV008','RUT015','ITI003','CLI007','CAU003','TRI013',20,25,45,1820.00,1350.00,0.00,165,'NO','2026-09-25 09:45:00'),
('HDV104','TIE018','ARL003','ARP010','ANV009','RUT014','ITI004','CLI009','CAU005','TRI014',65,70,135,3310.00,4020.00,0.00,180,'NO','2026-09-25 11:35:00'),
('HDV105','TIE018','ARL001','ARP005','ANV010','RUT007','ITI005','CLI011','CAU001','TRI015',0,5,5,2790.00,140.00,0.00,14,'NO','2026-09-25 11:20:00'),
('HDV106','TIE018','ARL004','ARP009','ANV011','RUT013','ITI006','CLI012','CAU002','TRI001',40,45,85,2290.00,2540.00,0.00,115,'NO','2026-09-25 13:35:00'),
('HDV107','TIE018','ARL002','ARP001','ANV012','RUT003','ITI007','CLI002','CAU007','TRI002',25,30,55,2860.00,1640.00,0.00,174,'NO','2026-09-25 13:15:00'),
('HDV108','TIE018','ARL003','ARP004','ANV013','RUT006','ITI008','CLI001','CAU001','TRI003',0,0,0,2540.00,0.00,0.00,0,'NO','2026-09-25 14:00:00'),
('HDV109','TIE019','ARL001','ARP002','ANV001','RUT002','ITI009','CLI008','CAU003','TRI004',55,60,115,2710.00,3440.00,0.00,142,'NO','2026-10-06 16:55:00'),
('HDV110','TIE019','ARL005','ARP011','ANV014','RUT009','ITI010','CLI005','CAU004','TRI005',45,50,95,2480.00,2840.00,0.00,99,'NO','2026-10-06 17:35:00'),
('HDV111','TIE019','ARL002','ARP012','ANV002','RUT004','ITI011','CLI015','CAU003','TRI006',50,55,105,2940.00,3140.00,0.00,176,'NO','2026-10-06 18:15:00'),
('HDV112','TIE019','ARL003','ARP006','ANV003','RUT010','ITI012','CLI006','CAU008','TRI007',70,75,145,3690.00,4320.00,2650.00,183,'NO','2026-10-06 20:00:00'),
('HDV113','TIE019','ARL001','ARP001','ANV004','RUT001','ITI013','CLI002','CAU010','TRI008',20,25,45,3120.00,1340.00,0.00,210,'NO','2026-10-06 19:05:00'),
('HDV114','TIE019','ARL004','ARP004','ANV005','RUT005','ITI014','CLI001','CAU001','TRI009',0,0,0,2210.00,0.00,0.00,0,'NO','2026-10-06 19:25:00'),
('HDV115','TIE020','ARL002','ARP005','ANV006','RUT008','ITI015','CLI010','CAU006','TRI010',60,65,125,3140.00,3740.00,0.00,185,'NO','2026-10-21 22:45:00'),
('HDV116','TIE020','ARL003','ARP008','ANV008','RUT012','ITI016','CLI014','CAU002','TRI011',35,40,75,2580.00,2240.00,0.00,168,'NO','2026-10-21 22:00:00'),
('HDV117','TIE020','ARL001','ARP010','ANV009','RUT014','ITI017','CLI013','CAU003','TRI012',100,110,210,3490.00,6280.00,0.00,184,'SI','2026-10-21 23:50:00'),
('HDV118','TIE020','ARL005','ARP007','ANV007','RUT011','ITI018','CLI005','CAU004','TRI013',30,35,65,1680.00,1940.00,0.00,74,'NO','2026-10-21 23:10:00'),
('HDV119','TIE020','ARL002','ARP003','ANV010','RUT003','ITI019','CLI007','CAU009','TRI014',25,30,55,2740.00,1640.00,1190.00,141,'NO','2026-10-21 23:55:00'),
('HDV120','TIE020','ARL001','ARP002','ANV012','RUT002','ITI020','CLI008','CAU003','TRI015',45,50,95,2950.00,2840.00,0.00,178,'NO','2026-10-21 23:59:00'),
('HDV121','TIE021','ARL003','ARP001','ANV013','RUT001','ITI001','CLI002','CAU001','TRI001',0,0,0,3050.00,0.00,0.00,0,'NO','2026-11-04 07:00:00'),
('HDV122','TIE021','ARL004','ARP009','ANV011','RUT013','ITI002','CLI012','CAU002','TRI002',45,50,95,2340.00,2840.00,0.00,117,'NO','2026-11-04 09:45:00'),
('HDV123','TIE021','ARL001','ARP004','ANV001','RUT006','ITI003','CLI001','CAU001','TRI003',0,0,0,2190.00,0.00,0.00,0,'NO','2026-11-04 09:05:00'),
('HDV124','TIE021','ARL002','ARP006','ANV002','RUT009','ITI004','CLI006','CAU004','TRI004',85,95,180,3680.00,5380.00,0.00,177,'NO','2026-11-04 12:20:00'),
('HDV125','TIE021','ARL003','ARP005','ANV003','RUT007','ITI005','CLI010','CAU006','TRI005',55,60,115,3120.00,3440.00,0.00,181,'NO','2026-11-04 13:05:00'),
('HDV126','TIE021','ARL005','ARP002','ANV014','RUT015','ITI006','CLI008','CAU007','TRI006',35,40,75,1750.00,2240.00,0.00,101,'NO','2026-11-04 13:25:00'),
('HDV127','TIE022','ARL001','ARP003','ANV004','RUT004','ITI007','CLI007','CAU003','TRI007',30,35,65,3280.00,1940.00,0.00,216,'NO','2026-11-19 13:25:00'),
('HDV128','TIE022','ARL002','ARP011','ANV006','RUT010','ITI008','CLI005','CAU004','TRI008',50,55,105,3540.00,3140.00,0.00,184,'NO','2026-11-19 15:40:00'),
('HDV129','TIE022','ARL004','ARP008','ANV005','RUT012','ITI009','CLI011','CAU008','TRI009',40,45,85,2560.00,2540.00,1680.00,139,'NO','2026-11-19 16:25:00'),
('HDV130','TIE022','ARL003','ARP010','ANV008','RUT014','ITI010','CLI009','CAU005','TRI010',75,80,155,3340.00,4620.00,0.00,171,'NO','2026-11-19 18:35:00'),
('HDV131','TIE022','ARL001','ARP001','ANV009','RUT005','ITI011','CLI002','CAU001','TRI011',5,0,5,2310.00,120.00,0.00,16,'NO','2026-11-19 16:35:00'),
('HDV132','TIE022','ARL002','ARP012','ANV010','RUT003','ITI012','CLI015','CAU003','TRI012',45,50,95,2790.00,2840.00,0.00,142,'NO','2026-11-19 19:10:00'),
('HDV133','TIE023','ARL001','ARP002','ANV012','RUT001','ITI013','CLI008','CAU003','TRI013',60,65,125,2960.00,3740.00,0.00,179,'NO','2026-12-08 20:25:00'),
('HDV134','TIE023','ARL003','ARP004','ANV013','RUT006','ITI014','CLI010','CAU006','TRI014',55,60,115,2680.00,3440.00,0.00,213,'NO','2026-12-08 21:15:00'),
('HDV135','TIE023','ARL005','ARP007','ANV007','RUT011','ITI015','CLI006','CAU004','TRI015',110,120,230,1890.00,6850.00,0.00,75,'SI','2026-12-08 23:30:00'),
('HDV136','TIE023','ARL002','ARP005','ANV001','RUT008','ITI016','CLI010','CAU006','TRI001',70,75,145,2920.00,4320.00,0.00,143,'NO','2026-12-08 23:10:00'),
('HDV137','TIE023','ARL004','ARP009','ANV011','RUT013','ITI017','CLI012','CAU009','TRI002',35,40,75,2280.00,2240.00,1420.00,116,'NO','2026-12-08 22:55:00'),
('HDV138','TIE023','ARL001','ARP003','ANV002','RUT004','ITI018','CLI001','CAU001','TRI003',0,0,0,2810.00,0.00,0.00,0,'NO','2026-12-08 22:10:00'),
('HDV139','TIE024','ARL002','ARP001','ANV003','RUT001','ITI019','CLI011','CAU010','TRI004',25,30,55,2740.00,1640.00,0.00,182,'NO','2026-12-23 23:55:00'),
('HDV140','TIE024','ARL003','ARP002','ANV004','RUT002','ITI020','CLI013','CAU003','TRI005',105,115,220,3640.00,6580.00,0.00,221,'SI','2026-12-23 23:59:00'),
('HDV141','TIE024','ARL001','ARP004','ANV006','RUT005','ITI001','CLI010','CAU006','TRI006',65,70,135,2540.00,4020.00,0.00,186,'NO','2026-12-23 09:05:00'),
('HDV142','TIE024','ARL002','ARP005','ANV008','RUT007','ITI002','CLI010','CAU006','TRI007',80,85,165,3180.00,4920.00,0.00,172,'NO','2026-12-23 10:55:00'),
('HDV143','TIE024','ARL004','ARP006','ANV005','RUT009','ITI003','CLI006','CAU004','TRI008',90,95,185,3620.00,5520.00,0.00,140,'NO','2026-12-23 12:05:00'),
('HDV144','TIE024','ARL003','ARP008','ANV009','RUT012','ITI004','CLI010','CAU008','TRI009',50,55,105,2710.00,3140.00,2150.00,183,'NO','2026-12-23 11:05:00'),
('HDV145','TIE024','ARL001','ARP010','ANV010','RUT014','ITI005','CLI009','CAU005','TRI010',85,90,175,3390.00,5210.00,0.00,142,'NO','2026-12-23 14:05:00'),
('HDV146','TIE024','ARL005','ARP011','ANV014','RUT010','ITI006','CLI005','CAU004','TRI011',40,45,85,2490.00,2540.00,0.00,100,'NO','2026-12-23 13:35:00'),
('HDV147','TIE024','ARL002','ARP003','ANV012','RUT003','ITI007','CLI007','CAU007','TRI012',30,35,65,2890.00,1940.00,0.00,177,'NO','2026-12-23 13:25:00'),
('HDV148','TIE024','ARL003','ARP004','ANV013','RUT006','ITI008','CLI001','CAU001','TRI013',0,0,0,2520.00,0.00,0.00,0,'NO','2026-12-23 14:00:00'),
('HDV149','TIE024','ARL001','ARP009','ANV001','RUT013','ITI009','CLI012','CAU002','TRI014',45,50,95,2360.00,2840.00,0.00,141,'NO','2026-12-23 16:35:00'),
('HDV150','TIE024','ARL002','ARP001','ANV002','RUT001','ITI010','CLI002','CAU001','TRI015',0,5,5,2590.00,140.00,0.00,19,'NO','2026-12-23 16:10:00');
GO

SET NOCOUNT OFF;
GO
