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
		tipo_paquete NVARCHAR(50),
		ancho_max DECIMAL(18,2),
		largo_max DECIMAL(18,2),
		alto_max DECIMAL(18,2),
		peso_max DECIMAL(18,2),
		precio DECIMAL(18,2)
	);

	CREATE TABLE [APROBANDO].[usuario] (
		usuario_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		telefono DECIMAL(18,0),
		mail NVARCHAR(255),
		fecha_de_nacimiento DATE,
		dni DECIMAL(18,0),
		nombre NVARCHAR(255),
		apellido NVARCHAR(255),
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
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
);

	CREATE TABLE [APROBANDO].[cupon](
		cupon_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		cupon_nro DECIMAL(18,0),
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
		cupon INTEGER REFERENCES [APROBANDO].[cupon],
		descripcion NVARCHAR(255),
		fecha_reclamo DATETIME,
		fecha_solucion DATETIME,
		calificacion DECIMAL(18,0),
		solucion NVARCHAR(255)
);

CREATE TABLE [APROBANDO].[tipo_estado_reclamo](
		tipo_estado_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		tipo_estado NVARCHAR(50)
);

CREATE TABLE [APROBANDO].[estado_de_reclamo](
		estado_reclamo_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		nro_reclamo DECIMAL(18,0) REFERENCES [APROBANDO].[reclamo],
		tipo_estado INTEGER REFERENCES [APROBANDO].[tipo_estado_reclamo]
);

CREATE TABLE [APROBANDO].[repartidor](
		repartidor_codigo INTEGER IDENTITY(1,1) PRIMARY KEY,
		usuario_codigo INTEGER REFERENCES [APROBANDO].[usuario],
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
		cupon_codigo INTEGER REFERENCES [APROBANDO].[cupon],
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

	--usuario

	INSERT INTO [APROBANDO].[usuario] (nombre,apellido,dni,telefono,mail,fecha_de_nacimiento,fecha_de_registro)
	SELECT DISTINCT USUARIO_NOMBRE,USUARIO_APELLIDO,USUARIO_DNI,USUARIO_TELEFONO,USUARIO_MAIL,USUARIO_FECHA_NAC,USUARIO_FECHA_REGISTRO
	FROM [gd_esquema].[Maestra]
	WHERE USUARIO_DNI IS NOT NULL
	UNION 
	SELECT DISTINCT REPARTIDOR_NOMBRE,REPARTIDOR_APELLIDO,REPARTIDOR_DNI,REPARTIDOR_TELEFONO,REPARTIDOR_EMAIL,REPARTIDOR_FECHA_NAC,NULL
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_DNI IS NOT NULL
	UNION
	SELECT DISTINCT OPERADOR_RECLAMO_NOMBRE,OPERADOR_RECLAMO_APELLIDO,OPERADOR_RECLAMO_DNI,OPERADOR_RECLAMO_TELEFONO,OPERADOR_RECLAMO_MAIL,OPERADOR_RECLAMO_FECHA_NAC,NULL
	FROM [gd_esquema].[Maestra]
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL

	--direccion por usuario

	INSERT INTO [APROBANDO].[direccion_por_usuario] (direccion_codigo,usuario_codigo,tipo_direccion)
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,DIRECCION_USUARIO_NOMBRE
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[localidad] l on DIRECCION_USUARIO_LOCALIDAD = l.localidad
	JOIN [APROBANDO].[direccion] d on DIRECCION_USUARIO_DIRECCION = d.direccion and d.localidad_codigo = l.localidad_codigo
	JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	WHERE DIRECCION_USUARIO_NOMBRE IS NOT NULL
	UNION 
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[direccion] d on OPERADOR_RECLAMO_DIRECCION = d.direccion 
	JOIN [APROBANDO].[usuario] u on u.dni = OPERADOR_RECLAMO_DNI
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL
	UNION 
	SELECT DISTINCT d.direccion_codigo,u.usuario_codigo,NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[direccion] d on REPARTIDOR_DIRECION = d.direccion 
	JOIN [APROBANDO].[usuario] u on u.dni = REPARTIDOR_DNI
	WHERE REPARTIDOR_DNI IS NOT NULL

	--OPERADOR

	INSERT INTO [APROBANDO].[operador] (usuario_codigo)
	SELECT DISTINCT u.usuario_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON u.dni = OPERADOR_RECLAMO_DNI
	WHERE OPERADOR_RECLAMO_DNI IS NOT NULL AND u.fecha_de_registro IS NULL

	--tipo movilidad

	INSERT INTO [APROBANDO].[tipo_movilidad] (movilidad)
	SELECT DISTINCT REPARTIDOR_TIPO_MOVILIDAD
	FROM [gd_esquema].[Maestra]
	WHERE REPARTIDOR_TIPO_MOVILIDAD IS NOT NULL

	-- repartidor 

	INSERT INTO [APROBANDO].[repartidor] (usuario_codigo,movilidad)
	SELECT DISTINCT u.usuario_codigo, tm.movilidad_codigo 
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u ON u.dni = REPARTIDOR_DNI
	JOIN [APROBANDO].[tipo_movilidad] tm on REPARTIDOR_TIPO_MOVILIDAD = tm.movilidad
	WHERE REPARTIDOR_DNI IS NOT NULL

	-- localidad por repartidor

	INSERT INTO [APROBANDO].[localidad_por_repartidor](localidad_codigo,repartidor_codigo,activa)
	SELECT DISTINCT l.localidad_codigo, r.repartidor_codigo, NULL
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] ur on ur.dni = REPARTIDOR_DNI JOIN repartidor r on r.usuario_codigo = ur.usuario_codigo
	JOIN [APROBANDO].[localidad] l on LOCAL_LOCALIDAD = l.localidad
	WHERE REPARTIDOR_DNI IS NOT NULL AND LOCAL_LOCALIDAD IS NOT NULL

	-- tipo cupon 

	INSERT INTO [APROBANDO].[tipo_cupon](tipo_cupon)
	SELECT DISTINCT CUPON_TIPO
	FROM [gd_esquema].[Maestra]
	WHERE CUPON_TIPO IS NOT NULL
	UNION
	SELECT DISTINCT CUPON_RECLAMO_TIPO
	FROM [gd_esquema].[Maestra]
	WHERE CUPON_RECLAMO_TIPO IS NOT NULL

	-- cupon 

	INSERT INTO [APROBANDO].[cupon](cupon_nro,fecha_alta,fecha_vencimiento,usuario_codigo,monto,usado,tipo_cupon)
	SELECT DISTINCT CUPON_NRO,CUPON_FECHA_ALTA,CUPON_FECHA_VENCIMIENTO,u.usuario_codigo,CUPON_MONTO,1,tc.tipo_cupon_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	JOIN [APROBANDO].[tipo_cupon] tc on tc.tipo_cupon = CUPON_TIPO
	WHERE CUPON_NRO IS NOT NULL
	UNION
	SELECT DISTINCT CUPON_RECLAMO_NRO,CUPON_RECLAMO_FECHA_ALTA,CUPON_RECLAMO_FECHA_VENCIMIENTO,u.usuario_codigo,CUPON_RECLAMO_MONTO,1,tc.tipo_cupon_codigo
	FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[usuario] u on u.dni = USUARIO_DNI
	JOIN [APROBANDO].[tipo_cupon] tc on tc.tipo_cupon = CUPON_RECLAMO_TIPO
	WHERE CUPON_RECLAMO_NRO IS NOT NULL

	-- tipo reclamo

	INSERT INTO [APROBANDO].[tipo_de_reclamo](tipo_de_reclamo)
	SELECT DISTINCT RECLAMO_TIPO 
	FROM [gd_esquema].[Maestra]
	WHERE RECLAMO_TIPO IS NOT NULL

	-- tarjeta

    INSERT INTO [APROBANDO].[tarjeta] (numero,marca)
    SELECT DISTINCT MEDIO_PAGO_NRO_TARJETA, MARCA_TARJETA
    FROM [gd_esquema].[Maestra]
    WHERE MEDIO_PAGO_NRO_TARJETA IS NOT NULL

    -- tarjeta por usuario

    INSERT INTO [APROBANDO].[tarjeta_por_usuario] (tarjeta_codigo, usuario_codigo)
    SELECT DISTINCT t.tarjeta_codigo, u.usuario_codigo 
    FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tarjeta] t ON t.numero = MEDIO_PAGO_NRO_TARJETA
    JOIN [APROBANDO].[usuario] u ON u.dni = USUARIO_DNI
    WHERE USUARIO_DNI IS NOT NULL

    -- tipo medio de pago

    INSERT INTO [APROBANDO].[tipo_medio_pago] (tipo_medio_pago)
    SELECT DISTINCT MEDIO_PAGO_TIPO
    FROM [gd_esquema].[Maestra]
    WHERE MEDIO_PAGO_TIPO IS NOT NULL

	  -- medio de pago

    INSERT INTO [APROBANDO].[medio_de_pago] (tipo_medio_pago, tarjeta_codigo, usuario_codigo)
    SELECT DISTINCT tmp.t_medio_pago_codigo, t.tarjeta_codigo, u.usuario_codigo
    FROM [gd_esquema].[Maestra] JOIN [APROBANDO].[tipo_medio_pago] tmp ON MEDIO_PAGO_TIPO = tmp.tipo_medio_pago
    JOIN [APROBANDO].[tarjeta] t ON MEDIO_PAGO_NRO_TARJETA = t.numero
    JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
    WHERE USUARIO_DNI IS NOT NULL AND MEDIO_PAGO_NRO_TARJETA IS NOT NULL

    -- tipo_estado

    INSERT INTO [APROBANDO].[tipo_estado_reclamo] (tipo_estado)
    SELECT DISTINCT RECLAMO_ESTADO
    FROM [gd_esquema].[Maestra]
    WHERE RECLAMO_ESTADO IS NOT NULL

	-- dia

	INSERT INTO [APROBANDO].[dia](dia)
	SELECT DISTINCT HORARIO_LOCAL_DIA
	FROM [gd_esquema].[Maestra]
	WHERE HORARIO_LOCAL_DIA IS NOT NULL

	--  tipo estado pedido 

	INSERT INTO [APROBANDO].[tipo_estado_pedido](tipo_estado_pedido)
	SELECT DISTINCT PEDIDO_ESTADO
	FROM [gd_esquema].[Maestra]
	WHERE PEDIDO_ESTADO IS NOT NULL

	-- tipo estado mensajeria

    INSERT INTO [APROBANDO].[tipo_estado_mensajeria] (tipo_estado)
    SELECT DISTINCT ENVIO_MENSAJERIA_ESTADO
    FROM [gd_esquema].[Maestra]
    WHERE ENVIO_MENSAJERIA_ESTADO IS NOT NULL

	--tipo local

	INSERT INTO [APROBANDO].[tipo_local] (tipo_local)
	select distinct LOCAL_TIPO
	from [gd_esquema].[Maestra]
 
	--producto

INSERT INTO [APROBANDO].[producto] (nombre, descripcion)
	select distinct PRODUCTO_LOCAL_NOMBRE, PRODUCTO_LOCAL_DESCRIPCION 
	from [gd_esquema].[Maestra]

	--tipo paquete

INSERT INTO [APROBANDO].[tipo_paquete] (tipo_paquete,ancho_max, largo_max, alto_max, peso_max, precio)
	select distinct PAQUETE_TIPO,PAQUETE_ANCHO_MAX, PAQUETE_LARGO_MAX, PAQUETE_ALTO_MAX, PAQUETE_PESO_MAX, PAQUETE_TIPO_PRECIO
	from [gd_esquema].[Maestra] 
	where PAQUETE_TIPO is not NULL

	--envio mensajeria (NO AGREGA NADA :()
		
INSERT INTO [APROBANDO].[envio_mensajeria] (nro_envio_msj,distancia_en_km,valor_asegurado,observaciones,precio_envio,
		precio_seguro,propina,total,tiempo_estimado_entrega,fecha_hora_entrega,calificacion,usuario,tipo_paquete_codigo
		,repartidor_codigo,medio_de_pago_codigo)
	select distinct ENVIO_MENSAJERIA_NRO, 
	ENVIO_MENSAJERIA_KM, ENVIO_MENSAJERIA_VALOR_ASEGURADO, 
	ENVIO_MENSAJERIA_OBSERV, ENVIO_MENSAJERIA_PRECIO_ENVIO, 
	ENVIO_MENSAJERIA_PRECIO_SEGURO, ENVIO_MENSAJERIA_PROPINA, 
	ENVIO_MENSAJERIA_TOTAL, ENVIO_MENSAJERIA_TIEMPO_ESTIMADO,
	ENVIO_MENSAJERIA_FECHA_ENTREGA, ENVIO_MENSAJERIA_CALIFICACION,
	u.usuario_codigo,tp.tipo_paquete_codigo,r.repartidor_codigo,
	mp.medio_pago_codigo
	from [gd_esquema].[Maestra]
	JOIN [APROBANDO].[usuario] u ON USUARIO_DNI = u.dni
	JOIN [APROBANDO].[tipo_paquete] tp ON PAQUETE_TIPO = tp.tipo_paquete 
	JOIN [APROBANDO].[usuario] ur ON REPARTIDOR_DNI = ur.dni
	JOIN [APROBANDO].[repartidor] r on u.usuario_codigo = r.usuario_codigo
	JOIN [APROBANDO].[tipo_medio_pago] tmp on tmp.tipo_medio_pago = MEDIO_PAGO_TIPO
	JOIN [APROBANDO].[medio_de_pago] mp on mp.tipo_medio_pago = tmp.t_medio_pago_codigo and u.usuario_codigo = mp.usuario_codigo
	--JOIN [APROBANDO].[direccion] 



END
GO

EXEC [APROBANDO].[MIGRAR]
GO

--select * from [gd_esquema].Maestra
--order by RECLAMO_ESTADO

--select * from [APROBANDO].[localidad_por_repartidor]
--order by repartidor_codigo

--select * from [APROBANDO].[usuario]

--select d.direccion_codigo,d.tipo_direccion,d.usuario_codigo,dir.direccion,l.localidad from [APROBANDO].direccion_por_usuario d
--JOIN  [APROBANDO].[direccion] dir on d.direccion_codigo = dir.direccion_codigo
--JOIN [APROBANDO].[localidad] l on dir.localidad_codigo = l.localidad_codigo
--order by usuario_codigo

--select * from [APROBANDO].[direccion_por_usuario]

--select localidad, provincia_codigo from [APROBANDO].localidad
--group by localidad, provincia_codigo
--order by localidad
--select d.localidad_codigo,l.localidad from [APROBANDO].[direccion] d join [APROBANDO].[localidad] l on d.localidad_codigo = l.localidad_codigo
--where d.direccion = '25 de MAYO 2097'

--select * from [APROBANDO].[direccion]