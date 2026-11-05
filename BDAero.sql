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