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
	nombre NVARCHAR(255),
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
	rango_menor INT,
	rango_mayor INT
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
	rango_id INTEGER IDENTITY(1,1) PRIMARY KEY,
	hora_inicial TIME,
	hora_final TIME
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

	INSERT INTO [APROBANDO].[BI_rango_etario] (rango_menor,rango_mayor)
	values (0,25),(25,35),(35,55),(55,150)

	--BI_local

	INSERT INTO [APROBANDO].[BI_local](nombre,tipo_local_codigo,localidad_codigo)
	(select l.nombre,bitl.tipo_local_codigo,biloc.localidad_codigo from [APROBANDO].[local] l
	JOIN [APROBANDO].[categoria] c on l.categoria = c.categoria_codigo
	JOIN [APROBANDO].[tipo_local] tl on tl.tipo_local_codigo = c.tipo_local_codigo
	JOIN [APROBANDO].[BI_tipo_local] bitl on bitl.tipo_local = tl.tipo_local
	JOIN [APROBANDO].[direccion] dir on dir.direccion_codigo = l.direccion
	JOIN [APROBANDO].[localidad] loc on loc.localidad_codigo = dir.localidad_codigo
	JOIN [APROBANDO].[provincia] prov on loc.provincia_codigo = prov.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia
	JOIN [APROBANDO].[BI_localidad] biloc on loc.localidad = biloc.localidad and biloc.provincia_codigo = biprov.provincia_codigo
	)

	--BI_rango_horario

	 INSERT INTO [APROBANDO].[BI_rango_horario] (hora_inicial,hora_final) 
	 VALUES ('08:00:00','10:00:00'),
	 ('10:00:00','12:00:00'),
	 ('12:00:00','14:00:00'),
	 ('14:00:00','16:00:00'),
	 ('16:00:00','18:00:00'),
	 ('18:00:00','20:00:00'),
	 ('20:00:00','22:00:00'),
	 ('22:00:00','23:59:59')


	 --HECHOS 

	--hecho pedido 
	
	INSERT INTO [APROBANDO].[BI_hecho_pedido] 
	(tipo_estado_codigo,dia_codigo,rango_horario_codigo,
	local_codigo,fecha,medio_pago_codigo,rango_etario_codigo,
	monto,calificacion,monto_cupones)

	(select bite.t_estado_pedido_codigo, bidia.dia_codigo, birh.rango_id,
	bil.local_codigo,ti.fecha,bitmp.medio_pago_codigo, bire.rango_id,
	p.total,p.calificacion,
	(select isnull(SUM(cc.importe),0) from cupon_canjeado cc
	where p.pedido_codigo = cc.pedido_codigo
	)


	from [APROBANDO].[pedido] p 
	JOIN [APROBANDO].[estado_pedido] e on e.nro_pedido = p.pedido_codigo
	JOIN [APROBANDO].[tipo_estado_pedido] te on e.tipo_estado = te.t_estado_pedido_codigo
	JOIN [APROBANDO].[BI_tipo_estado_pedido] bite on bite.tipo_estado_pedido = te.tipo_estado_pedido
	JOIN [APROBANDO].[BI_dia] bidia on bidia.dia = 
		case DATEPART(WEEKDAY,p.fecha_pedido)
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'  
		end
	JOIN [APROBANDO].[BI_rango_horario] birh on
	convert(time,p.fecha_pedido) <= birh.hora_final and 
	convert(time,p.fecha_pedido) >= birh.hora_inicial
	JOIN [APROBANDO].[local] l on l.local_codigo = p.local_codigo
	JOIN [APROBANDO].[BI_local] bil on l.nombre = bil.nombre
	JOIN [APROBANDO].[BI_tiempo] ti on ti.anio = YEAR(p.fecha_pedido) and ti.mes = MONTH(p.fecha_pedido)
	JOIN [APROBANDO].[medio_de_pago] mp on mp.medio_pago_codigo = p.medio_de_pago
	JOIN [APROBANDO].[tipo_medio_pago] tmp on tmp.t_medio_pago_codigo = mp.tipo_medio_pago
	JOIN [APROBANDO].[BI_tipo_medio_pago] bitmp on bitmp.tipo_medio_pago = tmp.tipo_medio_pago
	JOIN [APROBANDO].[usuario] u on u.usuario_codigo = p.usuario_codigo
	JOIN [APROBANDO].[BI_rango_etario] bire on 
	DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) >= bire.rango_menor 
	and DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) <= bire.rango_mayor
	)

	--hecho envio_mensajeria

	INSERT INTO [APROBANDO].[BI_hecho_envio_mensajeria]
	(fecha,rango_horario_codigo,dia_codigo,tipo_movilidad_codigo,
	localidad_codigo,rango_etario_codigo,tipo_paquete_codigo,tipo_estado_msj_codigo,medio_pago_codigo,
	monto,valor_asegurado)

	(select ti.fecha, birh.rango_id, bidia.dia_codigo, bitim.movilidad_codigo,
			biloc.localidad_codigo, bire.rango_id, bitp.tipo_paquete_codigo,bitem.tipo_estado_mensajeria_codigo,bitmp.medio_pago_codigo, 
			e.total,e.valor_asegurado  
	
	from [APROBANDO].[envio_mensajeria] e 
	JOIN [APROBANDO].[BI_tiempo] ti on ti.anio = YEAR(e.fecha_envio_msj) and ti.mes = MONTH(e.fecha_envio_msj)
	JOIN [APROBANDO].[BI_rango_horario] birh on
	convert(time,e.fecha_envio_msj) <= birh.hora_final and 
	convert(time,e.fecha_envio_msj) >= birh.hora_inicial
	JOIN [APROBANDO].[BI_dia] bidia on bidia.dia = 
		case DATEPART(WEEKDAY,e.fecha_envio_msj)
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Lunes'
			WHEN 3 THEN 'Martes'
			WHEN 4 THEN 'Miercoles'
			WHEN 5 THEN 'Jueves'
			WHEN 6 THEN 'Viernes'
			WHEN 7 THEN 'Sabado'  
		end
	JOIN [APROBANDO].[repartidor] rep on rep.repartidor_codigo = e.repartidor_codigo
	JOIN [APROBANDO].[tipo_movilidad] tim on tim.movilidad_codigo = rep.movilidad
	JOIN [APROBANDO].[BI_tipo_movilidad] bitim on bitim.movilidad = tim.movilidad
	JOIN [APROBANDO].[direccion] dir on dir.direccion_codigo = e.direccion_origen
	JOIN [APROBANDO].[localidad] loc on loc.localidad_codigo = dir.localidad_codigo
	JOIN [APROBANDO].[provincia] prov on prov.provincia_codigo = loc.provincia_codigo
	JOIN [APROBANDO].[BI_provincia] biprov on biprov.provincia = prov.provincia
	JOIN [APROBANDO].[BI_localidad] biloc on  biloc.localidad = loc.localidad and biloc.provincia_codigo = biprov.provincia_codigo
	JOIN [APROBANDO].[usuario] u on u.usuario_codigo = e.usuario
	JOIN [APROBANDO].[BI_rango_etario] bire on 
	DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) >= bire.rango_menor 
	and DATEDIFF(YEAR,u.fecha_de_nacimiento,GETDATE()) <= bire.rango_mayor
	JOIN [APROBANDO].[tipo_paquete] tp on tp.tipo_paquete_codigo = e.tipo_paquete_codigo
	JOIN [APROBANDO].[BI_tipo_paquete] bitp on bitp.tipo_paquete = tp.tipo_paquete
	JOIN [APROBANDO].[estado_mensajeria] em on em.envio_msj_codigo = e.envio_msj_codigo
	JOIN [APROBANDO].[tipo_estado_mensajeria] tem on tem.tipo_estado_mensajeria_codigo = em.tipo_estado
	JOIN [APROBANDO].[BI_tipo_estado_mensajeria] bitem on bitem.tipo_estado = tem.tipo_estado
	JOIN [APROBANDO].[medio_de_pago] mp on mp.medio_pago_codigo = e.medio_de_pago_codigo
	JOIN [APROBANDO].[tipo_medio_pago] tmp on tmp.t_medio_pago_codigo = mp.tipo_medio_pago
	JOIN [APROBANDO].[BI_tipo_medio_pago] bitmp on bitmp.tipo_medio_pago = tmp.tipo_medio_pago
	)

END
GO

EXEC [APROBANDO].[MIGRAR_BI]
GO

/*

select * from [APROBANDO].[BI_hecho_envio_mensajeria]

select * from [APROBANDO].[envio_mensajeria]
join [APROBANDO].[direccion] on direccion_origen = direccion_codigo

select * from [APROBANDO].[BI_hecho_pedido]

select * from [APROBANDO].[cupon_canjeado]

select * from [APROBANDO].[BI_hecho_pedido]

select * from [APROBANDO].[BI_dia]

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

select * from [APROBANDO].[BI_local]

select * from [APROBANDO].[BI_rango_horario]

*/