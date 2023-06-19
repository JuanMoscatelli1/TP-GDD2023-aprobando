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

CREATE TABLE [APROBANDO].[BI_tiempo] (
	fecha INTEGER IDENTITY(1,1) PRIMARY KEY,
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
	rango_id INTEGER IDENTITY (1,1) PRIMARY KEY,
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
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	medio_pago_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_medio_pago],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	monto DECIMAL(18,2),
	calificacion DECIMAL(18,0),
	monto_cupones DECIMAL(18,0),
	PRIMARY KEY(hecho_pedido_codigo, tipo_estado_codigo, dia_codigo, rango_horario_codigo, local_codigo, fecha, medio_pago_codigo, rango_etario_codigo)
	)


CREATE TABLE [APROBANDO].[BI_hecho_envio](
	hecho_envio_codigo INTEGER IDENTITY(1,1),
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	tipo_movilidad_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_movilidad],
	localidad_codigo INTEGER REFERENCES [APROBANDO].[BI_localidad],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	monto DECIMAL(18,2),
	tiempo_entrega INTEGER,
	PRIMARY KEY(hecho_envio_codigo, fecha, tipo_movilidad_codigo, localidad_codigo, rango_etario_codigo)
	)


CREATE TABLE [APROBANDO].[BI_hecho_reclamo](
	hecho_reclamo_codigo INTEGER IDENTITY(1,1),
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	local_codigo INTEGER REFERENCES [APROBANDO].[BI_local],
	tipo_reclamo_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_de_reclamo],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	tipo_estado_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_pedido],
	tiempo_resolucion INTEGER,
	monto_en_cupon DECIMAL(18,2),
	PRIMARY KEY(hecho_reclamo_codigo, dia_codigo, rango_horario_codigo, local_codigo, tipo_reclamo_codigo, rango_etario_codigo, fecha, tipo_estado_codigo)
	)


CREATE TABLE [APROBANDO].[BI_hecho_envio_mensajeria](
	hecho_envio_mensajeria_codigo INTEGER IDENTITY(1,1),
	fecha INTEGER REFERENCES [APROBANDO].[BI_tiempo],
	rango_horario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_horario],
	dia_codigo INTEGER REFERENCES [APROBANDO].[BI_dia],
	tipo_movilidad_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_movilidad],
	localidad_codigo INTEGER REFERENCES [APROBANDO].[BI_localidad],
	rango_etario_codigo INTEGER REFERENCES [APROBANDO].[BI_rango_etario],
	tipo_paquete_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_paquete],
	tipo_estado_msj_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_estado_mensajeria],
	medio_pago_codigo INTEGER REFERENCES [APROBANDO].[BI_tipo_medio_pago],
	monto DECIMAL(18,2),
	valor_asegurado DECIMAL(18,2),
	PRIMARY KEY(hecho_envio_mensajeria_codigo, fecha, rango_horario_codigo, dia_codigo, tipo_movilidad_codigo, localidad_codigo, rango_etario_codigo,
	 tipo_paquete_codigo, tipo_estado_msj_codigo, medio_pago_codigo)
	)

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

	--DIMESIONES:

	-- BI_tiempo

	INSERT INTO [APROBANDO].[BI_tiempo] (anio, mes)
	(
	SELECT DISTINCT YEAR(fecha_pedido), MONTH(fecha_pedido)
	FROM [APROBANDO].[pedido]
	UNION
	SELECT DISTINCT YEAR(fecha_reclamo), MONTH(fecha_reclamo)
	FROM [APROBANDO].[reclamo]
	UNION 
	SELECT DISTINCT YEAR(fecha_envio_msj), MONTH(fecha_envio_msj)
	FROM [APROBANDO].[envio_mensajeria]
	)

	--BI_provincia

	INSERT INTO [APROBANDO].[BI_provincia] (provincia)
	(select provincia from [APROBANDO].[provincia])
	
	--BI_localidad

	INSERT INTO [APROBANDO].[BI_localidad] (localidad, provincia_codigo)
	(select loc.localidad, biprov.provincia_codigo from [APROBANDO].[localidad] loc
	JOIN [APROBANDO].[provincia] prov on loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia)

	--BI_tipo_movilidad
	
	INSERT INTO [APROBANDO].[BI_tipo_movilidad] (movilidad)
	(select movilidad from [APROBANDO].[tipo_movilidad]) 


	--BI_tipo_local

	INSERT INTO [APROBANDO].[BI_tipo_local] (tipo_local)
	(select tipo_local from [APROBANDO].[tipo_local])

	--BI_tipo_estado_mensajeria

	INSERT INTO [APROBANDO].[BI_tipo_estado_mensajeria] (tipo_estado)
	(select tipo_estado from [APROBANDO].[tipo_estado_mensajeria])

	--BI_tipo_paquete

	INSERT INTO [APROBANDO].[BI_tipo_paquete] (ancho_max,largo_max,alto_max,peso_max,precio,tipo_paquete)
	(select ancho_max,largo_max,alto_max,peso_max,precio,tipo_paquete from [APROBANDO].[tipo_paquete])

	--BI_tipo_de_reclamo

	INSERT INTO [APROBANDO].[BI_tipo_de_reclamo] (tipo_de_reclamo)
	(select t.tipo_de_reclamo from [APROBANDO].[tipo_de_reclamo] t)

	--BI_tipo_estado_reclamo

	INSERT INTO [APROBANDO].[BI_tipo_estado_reclamo] (tipo_estado)
	(select t.tipo_estado from [APROBANDO].[tipo_estado_reclamo] t)

	--BI_tipo_estado_pedido

	INSERT INTO [APROBANDO].[BI_tipo_estado_pedido] (tipo_estado_pedido)
	(select t.tipo_estado_pedido from [APROBANDO].[tipo_estado_pedido] t)

	--BI_dia

	INSERT INTO [APROBANDO].[BI_dia] (dia)
	(select d.dia from [APROBANDO].[dia] d)

	--BI_tipo_medio_pago

	INSERT INTO [APROBANDO].[BI_tipo_medio_pago] (tipo_medio_pago)
	(select t.tipo_medio_pago from [APROBANDO].[tipo_medio_pago] t)

	--BI_categoria (va a estar en null la categoria, no existe en la tabla maestra => no existe en las tablas de la entrega pasada)

	INSERT INTO [APROBANDO].[BI_categoria] (categoria,tipo_local_codigo)
	(select c.categoria,bitip.tipo_local_codigo from [APROBANDO].[categoria] c
	JOIN [APROBANDO].[tipo_local] t on t.tipo_local_codigo = c.tipo_local_codigo
	JOIN [APROBANDO].[BI_tipo_local] bitip on t.tipo_local = bitip.tipo_local)

	--BI_rango_etario

	INSERT INTO [APROBANDO].[BI_rango_etario] (rango)
	values ('< a 25'),('25 - 35'),('35-55'),('>55')

	--BI_


END
GO

EXEC [APROBANDO].[MIGRAR_BI]
GO

/*

select * from gd_esquema.Maestra

select * from [APROBANDO].[BI_provincia]

select * from [APROBANDO].[BI_localidad]

select * from [APROBANDO].[BI_tipo_movilidad]

select * from [APROBANDO].[BI_tipo_local]

select * from [APROBANDO].[BI_tipo_estado_mensajeria]

select * from [APROBANDO].[BI_tipo_paquete]

select * from [APROBANDO].[BI_tipo_de_reclamo]

select * from [APROBANDO].[BI_tipo_estado_reclamo]

select * from [APROBANDO].[categoria]

select * from [APROBANDO].[BI_categoria]

select * from [APROBANDO].[BI_rango_etario]
*/