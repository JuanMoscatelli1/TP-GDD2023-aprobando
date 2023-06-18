USE [GD1C2023]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'APROBANDO')
	EXEC('CREATE SCHEMA APROBANDO')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='DROP_TABLES_BI')
	EXEC('CREATE PROCEDURE [APROBANDO].[DROP_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[DROP_TABLES_BI]
AS
BEGIN
	DECLARE @sql NVARCHAR(500) = ''
	
	DECLARE cursorTablas CURSOR FOR
	SELECT DISTINCT 'ALTER TABLE [' + tc.TABLE_SCHEMA + '].[' +  tc.TABLE_NAME + '] DROP [' + rc.CONSTRAINT_NAME + '];'
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	ON tc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
	WHERE tc.TABLE_SCHEMA = 'APROBANDO'

	OPEN cursorTablas
	FETCH NEXT FROM cursorTablas INTO @sql

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC sp_executesql @sql
		FETCH NEXT FROM cursorTablas INTO @Sql
	END

	CLOSE cursorTablas
	DEALLOCATE cursorTablas
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand ='AND schema_name(schema_id) = ''APROBANDO'' AND o.name LIKE ''BI_%'''
END
GO

EXEC [APROBANDO].[DROP_TABLES_BI]
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES_BI')
   EXEC('CREATE PROCEDURE [APROBANDO].[CREATE_TABLES_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[CREATE_TABLES_BI] 
AS 
BEGIN

END
GO

EXEC [APROBANDO].[CREATE_TABLES_BI]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='MIGRAR_BI')
	EXEC('CREATE PROCEDURE [APROBANDO].[MIGRAR_BI] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[MIGRAR_BI]
AS
BEGIN

CREATE TABLE [APROBANDO].[BI_tiempo] (
	fecha NVARCHAR(7) IDENTITY(1,1) PRIMARY KEY,
	anio NVARCHAR(4),
	mes NVARCHAR(2)
	)

CREATE TABLE [APROBANDO].[BI_provincia] (
	provincia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	provincia NVARCHAR(255)
	)

CREATE TABLE [APROBANDO].[BI_localidad] (
	localidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	localidad NVARCHAR(255),
	provincia_codigo INTEGER REFERENCES [APROBANDO].[BI_provincia]
	)

CREATE TABLE [APROBANDO].[BI_tipo_local] (
	tipo_local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_local NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_local] (
	local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	local INTEGER,
	tipo_local_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_local],
	localidad_codigo INTEGER REFERENCES [APROBANDO].[BI_localidad]
	)

CREATE TABLE [APROBANDO].[BI_categoria] (
	categoria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	categoria NVARCHAR(50),
	tipo_local_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_local]
	)

CREATE TABLE [APROBANDO].[BI_rango_etario] (
	rango_id INTEGER PRIMARY KEY,
	rango NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_movilidad] (
	movilidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	movilidad NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_mensajeria] (
	tipo_estado_mensajeria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_paquete] (
	tipo_paquete_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	ancho_max DECIMAL(18,2),
	largo_max DECIMAL(18,2),
	alto_max DECIMAL(18,2),
	peso_max DECIMAL(18,2),
	precio DECIMAL(18,2),
	tipo_paquete NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_de_reclamo] (
	tipo_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_de_reclamo NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_reclamo] (
	tipo_estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_dia] (
	dia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	dia NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_medio_pago] (
	medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_medio_pago NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_tipo_estado_pedido] (
	t_estado_pedido_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
	tipo_estado_pedido NVARCHAR(50)
	)

CREATE TABLE [APROBANDO].[BI_rango_horario] (
	rango_id INTEGER PRIMARY KEY,
	hora_inicial NVARCHAR(50),
	hora_final NVARCHAR(50)
	)

-- Hechos:

CREATE TABLE [APROBANDO].[BI_hecho_pedido](
	hecho_pedido_codigo INTEGER IDENTITY(1,1),
	tipo_estado_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_pedido],
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],    
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	local_codigo INTEGER REFERENCES [APROBANDO].[BI_local],
	fecha NVARCHAR(7)REFERENCES [APROBANDO].[BI_tiempo],
	medio_pago_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_medio_pago],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	monto DECIMAL(8,2),
	calificacion DECIMAL(18,0),
	monto_cupones DECIMAL(18,0),
	PRIMARY KEY(hecho_pedido_codigo, tipo_estado_codigo, dia_codigo, rango_horario_codigo, local_codigo,fecha, medio_pago_codigo, rango_etario_codigo)
	)


END
GO

EXEC [APROBANDO].[MIGRAR_BI]
GO


