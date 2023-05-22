USE [GD1C2023]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'APROBANDO')
	EXEC('CREATE SCHEMA APROBANDO')
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name = 'DROP_TABLES')
	EXEC('CREATE PROCEDURE [APROBANDO].[DROP_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[DROP_TABLES]
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
	
	EXEC sp_MSforeachtable 'DROP TABLE ?', @whereand='AND schema_name(schema_id) = ''APROBANDO'' AND o.name NOT LIKE ''BI_%'''
END
GO

EXEC [APROBANDO].[DROP_TABLES]
GO


IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='CREATE_TABLES')
   EXEC('CREATE PROCEDURE [APROBANDO].[CREATE_TABLES] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[CREATE_TABLES]
AS
BEGIN

	CREATE TABLE [APROBANDO].[producto] (
		producto_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nombre NVARCHAR(50),
		descripcion NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[informacion_personal](
		info_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		telefono DECIMAL(18,0),
		mail NVARCHAR(255),
		fecha_de_nacimiento DATE,
		dni DECIMAL(18,0),
		nombre NVARCHAR(255),
		apellido NVARCHAR(255)
	);

	CREATE TABLE [APROBANDO].[tipo_local] (
		tipo_local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_local NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[dia] (
		dia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		dia NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tipo_estado_mensajeria] (
		tipo_estado_mensajeria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tipo_medio_pago] (
		t_medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_medio_pago NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tipo_movilidad] (
		movilidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		movilidad NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tipo_paquete] (
		tipo_paquete_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		ancho_max DECIMAL(18,2),
		largomax DECIMAL(18,2),
		alto_max DECIMAL(18,2),
		peso_max DECIMAL(18,2),
		precio DECIMAL(18,2)
	);

	CREATE TABLE [APROBANDO].[usuario] (
		usuario_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		info_codigo INTEGER REFERENCES [APROBANDO].[informacion_personal],
		fecha_de_registro DATETIME2(3)
	);


	CREATE TABLE [APROBANDO].[tipo_estado_pedido] (
		t_estado_pedido_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado_pedido NVARCHAR(50)
	);


	CREATE TABLE [APROBANDO].[tipo_de_reclamo](
		tipo_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_de_reclamo NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tipo_cupon](
		tipo_cupon_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_cupon NVARCHAR(50)
	);

	CREATE TABLE [APROBANDO].[tarjeta](
		tarjeta_codigo INTEGER IDENTITY(1,1) PRIMARY KEY, 
		numero NVARCHAR(50),
		marca NVARCHAR(100)
	);

		CREATE TABLE [APROBANDO].[tarjeta_por_usuario](
		tarjeta_codigo INTEGER REFERENCES [APROBANDO].[tarjeta],
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario]
		PRIMARY KEY(tarjeta_codigo,usuario_codigo)
	);

	CREATE TABLE [APROBANDO].[medio_de_pago] (
		medio_pago_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_medio_pago INTEGER REFERENCES [APROBANDO].[tipo_medio_pago],
		tarjeta_codigo INTEGER, 
		usuario_codigo  INTEGER, 
		FOREIGN KEY (tarjeta_codigo,usuario_codigo) REFERENCES [APROBANDO].[tarjeta_por_usuario](tarjeta_codigo,usuario_codigo) 
	);

	CREATE TABLE [APROBANDO].[categoria] (
		categoria_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_local_codigo INTEGER REFERENCES [APROBANDO].[tipo_local],
		categoria NVARCHAR(50)
	);

CREATE TABLE [APROBANDO].[local] (
		local_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		categoria INTEGER REFERENCES [APROBANDO].[categoria],
		nombre NVARCHAR(255),
		direccion DECIMAL(18,0)
	);

		CREATE TABLE [APROBANDO].[pedido](
		nro_pedido DECIMAL(18,0) PRIMARY KEY,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
		local_codigo INTEGER REFERENCES [APROBANDO].[local],
		medio_de_pago INTEGER REFERENCES [APROBANDO].[medio_de_pago],
		fecha_pedido DATETIME,
		tarifa_delivery DECIMAL(18,2),
		total DECIMAL(18,2),
		observaciones VARCHAR(255),
		tiempo_estimado_entrega DECIMAL(18,2),
		fecha_entrga DATETIME,
		calificacion DECIMAL(18,0)
	);		

CREATE TABLE [APROBANDO].[estado_pedido] (
		estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_pedido],
		nro_pedido DECIMAL(18,0) REFERENCES [APROBANDO].[pedido],
		fecha_estado DATE
	);



CREATE TABLE [APROBANDO].[horario_apertura] (
		horario_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		local_codigo INTEGER REFERENCES [APROBANDO].[local],
		dia INTEGER REFERENCES [APROBANDO].[dia],
		horario_inicio DECIMAL(18,0),
		horario_fin DECIMAL(18,0)
	);



CREATE TABLE [APROBANDO].[provincia] (
		provincia_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		provincia NVARCHAR(255)
	);

CREATE TABLE [APROBANDO].[localidad](
		localidad_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		provincia_codigo INTEGER REFERENCES [APROBANDO].[provincia],
		localidad NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[direccion](
		direccion_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		localidad_codigo INTEGER REFERENCES [APROBANDO].[localidad],
		direccion NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[direccion_por_usuario](
		direccion_codigo INTEGER REFERENCES [APROBANDO].[direccion],
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
		tipo_direccion NVARCHAR(50),
		PRIMARY KEY(direccion_codigo,usuario_codigo)
);

CREATE TABLE [APROBANDO].[operador](
		operador_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		info_codigo INTEGER REFERENCES [APROBANDO].[informacion_personal],
);

	CREATE TABLE [APROBANDO].[cupon](
		cupon_codigo DECIMAL(18,0) PRIMARY KEY,
		tipo_cupon INTEGER REFERENCES [APROBANDO].[tipo_cupon],
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
		fecha_alta DATETIME,
		fecha_vencimiento DATETIME,
		usado BIT,
		monto decimal(18,2)
	);


CREATE TABLE [APROBANDO].[reclamo](
		nro_reclamo DECIMAL(18,0) PRIMARY KEY,
		usuario INTEGER REFERENCES [APROBANDO].[usuario],
		pedido DECIMAL(18,0) REFERENCES [APROBANDO].[pedido],
		tipo_de_reclamo INTEGER REFERENCES [APROBANDO].[tipo_de_reclamo],
		operador_codigo INTEGER REFERENCES [APROBANDO].[operador],
		cupon DECIMAL(18,0) REFERENCES [APROBANDO].[cupon],
		descripcion NVARCHAR(255),
		fecha_reclamo DATETIME,
		fecha_solucion DATETIME,
		calificacion DECIMAL(18,0),
		solucion NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[tipo_estado](
		tipo_estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado NVARCHAR(50)
);

CREATE TABLE [APROBANDO].[estado_de_reclamo](
		estado_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nro_reclamo DECIMAL(18,0) REFERENCES [APROBANDO].[reclamo],
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado]
);

CREATE TABLE [APROBANDO].[repartidor](
		repartidor_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		info_codigo INTEGER REFERENCES [APROBANDO].[informacion_personal],
		movilidad INTEGER REFERENCES [APROBANDO].[tipo_movilidad]
	);


CREATE TABLE [APROBANDO].[envio_mensajeria](
		nro_envio_msj DECIMAL(18,0) PRIMARY KEY,
		usuario INTEGER REFERENCES [APROBANDO].[usuario],
		direccion_origen INTEGER REFERENCES [APROBANDO].[direccion],
		direccion_destino INTEGER REFERENCES [APROBANDO].[direccion],
		tipo_paquete_codigo INTEGER REFERENCES [APROBANDO].[tipo_paquete],
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor],
		medio_de_pago_codigo INTEGER REFERENCES [APROBANDO].[medio_de_pago],
		fecha_envio_msj NVARCHAR(255),
		distancia_en_km DECIMAL(18,2),
		valor_asegurado DECIMAL(18,2),
		observaciones NVARCHAR(255),
		precio_envio DECIMAL(18,2),
		precio_seguro DECIMAL(18,2),
		propina DECIMAL(18,2),
		total DECIMAL(18,2),
		tiempo_estimado_entrega DECIMAL(18,2),
		fecha_hora_entrega DATETIME,
		calificacion DECIMAL(18,0)
);

CREATE TABLE [APROBANDO].[estado_mensajeria](
		estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_mensajeria],
		nro_envio_msj DECIMAL(18,0) REFERENCES [APROBANDO].[envio_mensajeria],
		fecha_estado DATETIME
);


CREATE TABLE [APROBANDO].[envio](
		envio_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		direccion INTEGER REFERENCES [APROBANDO].[direccion],
		precio DECIMAL(18,2),
		propina DECIMAL(18,2),
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor],
		nro_pedido DECIMAL(18,0) REFERENCES [APROBANDO].[pedido]
);

CREATE TABLE [APROBANDO].[producto_local] (
		producto_codigo INTEGER NOT NULL REFERENCES [APROBANDO].[producto],
		local_codigo INTEGER NOT NULL REFERENCES [APROBANDO].[local],
		PRIMARY KEY (producto_codigo,local_codigo),
		precio_en_total DECIMAL(18,2) 
);



CREATE TABLE [APROBANDO].[item] (
		producto_codigo INTEGER NOT NULL,
		local_codigo INTEGER NOT NULL,
		nro_pedido DECIMAL(18,0) NOT NULL REFERENCES [APROBANDO].[pedido],
		FOREIGN KEY (producto_codigo,local_codigo) REFERENCES [APROBANDO].[producto_local](producto_codigo,local_codigo),
		PRIMARY KEY (producto_codigo,local_codigo,nro_pedido),
		cantidad DECIMAL(18,0),
		precio_unitario DECIMAL(18,2) NOT NULL,
		total DECIMAL(18,0)
);




	CREATE TABLE [APROBANDO].[cupon_canjeado](
		cupon_codigo DECIMAL(18,0) REFERENCES [APROBANDO].[cupon],
		pedido_codigo DECIMAL(18,0) REFERENCES [APROBANDO].[pedido],
		importe DECIMAL(18,2),
		PRIMARY KEY(cupon_codigo,pedido_codigo)
	);

	

	CREATE TABLE [APROBANDO].[localidad_por_repartidor](
		localidad_codigo INTEGER REFERENCES [APROBANDO].[localidad],
		repartidor_codigo INTEGER REFERENCES [APROBANDO].[repartidor],
		activa BIT
	);

	

END
GO

EXEC [APROBANDO].[CREATE_TABLES]
GO

IF NOT EXISTS(SELECT name FROM sys.procedures WHERE name='MIGRAR')
	EXEC('CREATE PROCEDURE [APROBANDO].[MIGRAR] AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE [APROBANDO].[MIGRAR]
AS
BEGIN

	--provincia

	INSERT INTO [APROBANDO].[provincia] (provincia)
		SELECT DISTINCT ENVIO_MENSAJERIA_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE ENVIO_MENSAJERIA_PROVINCIA IS NOT NULL
		UNION
		SELECT DISTINCT DIRECCION_USUARIO_PROVINCIA
		FROM [gd_esquema].[Maestra]
		WHERE DIRECCION_USUARIO_PROVINCIA IS NOT NULL	
		UNION
		SELECT DISTINCT LOCAL_PROVINCIA
		FROM [gd_esquema].Maestra
		WHERE LOCAL_PROVINCIA IS NOT NULL

	--localidad
	
	INSERT INTO [APROBANDO].[localidad] (localidad,provincia_codigo)
		SELECT DISTINCT ENVIO_MENSAJERIA_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON ENVIO_MENSAJERIA_PROVINCIA = provincia
		WHERE ENVIO_MENSAJERIA_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT DIRECCION_USUARIO_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON DIRECCION_USUARIO_PROVINCIA= provincia
		WHERE DIRECCION_USUARIO_LOCALIDAD IS NOT NULL
		UNION
		SELECT DISTINCT LOCAL_LOCALIDAD,provincia_codigo
		FROM [gd_esquema].[Maestra] join [APROBANDO].provincia
		ON LOCAL_PROVINCIA = provincia
		WHERE LOCAL_LOCALIDAD IS NOT NULL

	--direccion(los repartidores y operadores tendrían el campo tipo de direccion y la localidad en null ya que no lo especifican)

	INSERT INTO [APROBANDO].[direccion] (direccion,localidad_codigo)
	SELECT DISTINCT DIRECCION_USUARIO_DIRECCION, localidad_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[localidad] 
	ON DIRECCION_USUARIO_LOCALIDAD = localidad
	WHERE DIRECCION_USUARIO_DIRECCION IS NOT NULL
	UNION
	SELECT DISTINCT LOCAL_DIRECCION, localidad_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[localidad] 
	ON LOCAL_LOCALIDAD = localidad
	WHERE LOCAL_DIRECCION IS NOT NULL
	UNION 
	SELECT DISTINCT OPERADOR_RECLAMO_DIRECCION, NULL
	FROM [gd_esquema].[Maestra]
	WHERE OPERADOR_RECLAMO_DIRECCION IS NOT NULL
	UNION
	SELECT DISTINCT REPARTIDOR_DIRECION, NULL
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_DIRECION IS NOT NULL
	UNION
	SELECT DISTINCT ENVIO_MENSAJERIA_DIR_DEST,localidad_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[localidad] 
	ON ENVIO_MENSAJERIA_LOCALIDAD = localidad
	WHERE ENVIO_MENSAJERIA_DIR_DEST IS NOT NULL
	UNION
	SELECT DISTINCT ENVIO_MENSAJERIA_DIR_ORIG,localidad_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[localidad] 
	ON ENVIO_MENSAJERIA_LOCALIDAD = localidad
	WHERE ENVIO_MENSAJERIA_DIR_ORIG IS NOT NULL

	--informacion personal

	INSERT INTO [APROBANDO].[informacion_personal] (nombre,apellido,dni,telefono,mail,fecha_de_nacimiento)
	SELECT DISTINCT USUARIO_NOMBRE,USUARIO_APELLIDO,USUARIO_DNI,USUARIO_TELEFONO,USUARIO_MAIL,USUARIO_FECHA_NAC
	FROM [gd_esquema].[Maestra]
	WHERE USUARIO_DNI IS NOT NULL
	UNION 
	SELECT DISTINCT REPARTIDOR_NOMBRE,REPARTIDOR_APELLIDO,REPARTIDOR_DNI,REPARTIDOR_TELEFONO,REPARTIDOR_EMAIL,REPARTIDOR_FECHA_NAC
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_DNI IS NOT NULL
	UNION
	SELECT DISTINCT OPERADOR_RECLAMO_NOMBRE,OPERADOR_RECLAMO_APELLIDO,OPERADOR_RECLAMO_DNI,OPERADOR_RECLAMO_TELEFONO,OPERADOR_RECLAMO_MAIL,OPERADOR_RECLAMO_FECHA_NAC
	FROM [gd_esquema].[Maestra]
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL

	--usuario

	INSERT INTO [APROBANDO].[usuario] (fecha_de_registro, info_codigo)
	SELECT DISTINCT USUARIO_FECHA_REGISTRO, i.info_codigo 
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[informacion_personal] i
	ON USUARIO_NOMBRE = i.nombre AND USUARIO_APELLIDO = i.apellido AND USUARIO_DNI = i.dni
	WHERE USUARIO_DNI IS NOT NULL
END
GO

EXEC [APROBANDO].[MIGRAR]
GO



--select * from gd_esquema.Maestra
--select localidad, provincia_codigo from [APROBANDO].localidad
--group by localidad, provincia_codigo
--order by localidad
--select d.localidad_codigo,l.localidad from [APROBANDO].[direccion] d join [APROBANDO].[localidad] l on d.localidad_codigo = l.localidad_codigo
--where d.direccion = '25 de MAYO 2097'

--select * from [APROBANDO].[direccion]