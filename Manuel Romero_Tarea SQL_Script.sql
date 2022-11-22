DROP DATABASE IF EXISTS TAREA1;
CREATE DATABASE TAREA1;

USE TAREA1;

CREATE TABLE CATEGORIA
(
DESCRIPCION_CAT VARCHAR(100),
IDCAT CHAR(2) UNIQUE not null,
primary key (IDCAT)
);


ALTER TABLE CATEGORIA
ADD COLUMN DESCUENTO DECIMAL(10,2) AS
(CASE
            WHEN IDCAT='A' THEN 0.05
            WHEN IDCAT='B' THEN 0.10
            WHEN IDCAT='C' THEN  0.15
            WHEN IDCAT='D' THEN 0.20 
            ELSE NULL
            END);
            
DESCRIBE CATEGORIA;


CREATE TABLE TIENDA
(
IDTIENDA CHAR(5) UNIQUE not null,
NOMBRE_TIENDA VARCHAR(20),
LIMCRED DECIMAL(10,2) CHECK(LIMCRED<=30000),
IDCAT CHAR(5),
PRIMARY KEY (IDTIENDA),
FOREIGN KEY (IDCAT) REFERENCES CATEGORIA(IDCAT)
);


CREATE TABLE PROVEEDOR
(
NOMBRE VARCHAR(100),
IDPROV CHAR(5) UNIQUE not null,
CALLEPROV VARCHAR(100),
NUMPROV VARCHAR(2),
POBLACIÓNPROV VARCHAR(100),
CIUDADPROV VARCHAR(100),
TLFPROV CHAR(12),
EMAILPROV VARCHAR(100),
PRIMARY KEY (IDPROV)
);


CREATE TABLE PEDIDOS
(
IDPED CHAR(5) UNIQUE not null,
IDPROV CHAR(5),
FECHA DATETIME,
PRIMARY KEY (IDPED),
FOREIGN KEY (IDPROV) REFERENCES PROVEEDOR(IDPROV)
);

CREATE TABLE DIRECCIONES
(
CALLE VARCHAR(100),
NUM VARCHAR(2),
POBLACIÓN VARCHAR(100),
CIUDAD VARCHAR(100),
TLF CHAR(12),
EMAIL VARCHAR(100),
IDTIENDA CHAR(5),
IDPED CHAR(5),
FOREIGN KEY (IDTIENDA) REFERENCES TIENDA(IDTIENDA),
FOREIGN KEY (IDPED) REFERENCES PEDIDOS(IDPED)
);

CREATE TABLE ARTICULOS
(
IDART CHAR(5) UNIQUE not null,
PRECIO_UNITARIO DECIMAL(10,2) CHECK(PRECIO_UNITARIO>0),
DESCRIPCION_ART VARCHAR(100),
PRIMARY KEY (IDART)
);

CREATE TABLE LINEA_PEDIDO
(
IDPED CHAR(5),
IDART CHAR(5),
PRECIO_UNITARIO DECIMAL(10,2) CHECK(PRECIO_UNITARIO>0),
NUDS int CHECK(NUDS>0),
TOTALPED DECIMAL(10,2) AS (PRECIO_UNITARIO*NUDS),
FOREIGN KEY (IDART) REFERENCES ARTICULOS(IDART),
FOREIGN KEY (IDPED) REFERENCES PEDIDOS(IDPED)
);

# AQUI TERMINA EL ER

# CAMBIAMOS LINEA_PEDIDO PARA LOS TRIGGERS
ALTER TABLE LINEA_PEDIDO
ADD COLUMN IDTIENDA CHAR(5),
ADD COLUMN IDPROV CHAR(5);

CREATE TABLE CATEGORIA_PROVEEDOR
(
DESCRIPCION_CAT VARCHAR (50),
IDCATPROV CHAR(2) UNIQUE NOT NULL,
PRIMARY KEY (IDCATPROV)
);

    # CAMBIAMOS PROVEEDOR
ALTER TABLE PROVEEDOR
ADD COLUMN IDCATPROV CHAR(2),
ADD FOREIGN KEY (IDCATPROV) REFERENCES CATEGORIA_PROVEEDOR(IDCATPROV);

# TRIGGER PARA ACTUALIZAR CATEGORÍAS
DROP TRIGGER IF EXISTS UPDATE_CATEGORIA
DELIMITER // 

CREATE TRIGGER UPDATE_CATEGORIA
AFTER INSERT ON LINEA_PEDIDO FOR EACH ROW
BEGIN
	DECLARE VOLUMEN DECIMAL(10,2);
    SET VOLUMEN :=(SELECT SUM(TOTALPED) FROM LINEA_PEDIDO WHERE IDTIENDA=NEW.IDTIENDA GROUP BY IDTIENDA);
    IF (VOLUMEN < 10000) THEN 
    UPDATE TIENDA SET IDCAT='A' WHERE IDTIENDA=NEW.IDTIENDA;
    ELSEIF (VOLUMEN >= 15000 and VOLUMEN < 20000) THEN
	UPDATE TIENDA SET IDCAT='B' WHERE IDTIENDA=NEW.IDTIENDA;
    ELSEIF (VOLUMEN >= 20000 and VOLUMEN < 25000) THEN
	UPDATE TIENDA SET IDCAT='C' WHERE IDTIENDA=NEW.IDTIENDA;
    ELSEIF (VOLUMEN >= 25000) THEN
	UPDATE TIENDA SET IDCAT='D' WHERE IDTIENDA=NEW.IDTIENDA;
	END IF;
	End;
//

# TRIGGER PARA ACTUALIZAR PROVEEDORES
DELIMITER //
CREATE TRIGGER UPDATE_PROVEEDOR
AFTER INSERT ON LINEA_PEDIDO FOR EACH ROW
BEGIN
	DECLARE PEDIDOS_SUMA DECIMAL(10,2);
    SET PEDIDOS_SUMA := (SELECT SUM(TOTALPED) FROM LINEA_PEDIDO WHERE IDPROV=NEW.IDPROV);
    IF (PEDIDOS_SUMA < 15000) THEN 
    UPDATE PROVEEDOR SET IDCATPROV='A' WHERE IDPROV=NEW.IDPROV;
    ELSEIF (PEDIDOS_SUMA >= 20000 and PEDIDOS_SUMA < 25000) THEN
	UPDATE PROVEEDOR SET IDCATPROV='B'  WHERE IDPROV=NEW.IDPROV;
    ELSEIF (PEDIDOS_SUMA >= 25000 and PEDIDOS_SUMA < 30000) THEN
	UPDATE PROVEEDOR SET IDCATPROV='C'  WHERE IDPROV=NEW.IDPROV;
    ELSEIF (PEDIDOS_SUMA >= 30000) THEN
	UPDATE PROVEEDOR SET IDCATPROV='D'  WHERE IDPROV=NEW.IDPROV;
	END IF;
	End;
// 

INSERT INTO CATEGORIA(DESCRIPCION_CAT, IDCAT) VALUES
	('Bajo', 'A'),
	('Medio','B'),
	('Alto', 'C'),
	('Muy Alto', 'D');

SELECT * FROM CATEGORIA;

DESCRIBE TIENDA;

INSERT INTO TIENDA(IDTIENDA, NOMBRE_TIENDA, LIMCRED) VALUES
	('11', 'Alcampo', 10230.00),
    ('12', 'El Corte Inglés', 25600.00),
    ('13', 'Super Todo a 100', 21000.00),
    ('14', 'Maxi China', 10300.00),
    ('15', 'MediaMarkt', 21400.00),
    ('16', 'Carrefour', 29000.00),
    ('17', 'Worten', 27800.00);
    
SELECT * FROM TIENDA;

DESCRIBE PROVEEDOR;

INSERT INTO PROVEEDOR(NOMBRE, IDPROV, CALLEPROV, NUMPROV, POBLACIÓNPROV, CIUDADPROV, TLFPROV, EMAILPROV) VALUES
	('Joaquín', 'P1', 'Leopoldo López', 34, 'Osuna', 'Sevilla',  '+34567753221', 'qwasf@gmail.com'),
 	('Jesús', 'P2', 'Manuel Fraga', 24, 'Carmona', 'Sevilla',  '+34567775221', 'abced@gmail.com'),
	('Esteban', 'P3', 'Portugal', 31, 'Jerez', 'Cádiz',  '+34568953221', 'estjer@gmail.com'),
	('Pablo', 'P4', 'Fuencarral', 22, 'Madrid', 'Madrid',  '+34567748921', 'pabmad@gmail.com'),
	('Joaquín', 'P5', 'Leopoldo López', 12, 'Osuna', 'Sevilla',  '+34567753221', 'qwasf@gmail.com'),
	('Laura', 'P6', 'Alegría', 2, 'Gijón', 'Asturias',  '+34567753118', 'larast@gmail.com');
    
    
SELECT * FROM PROVEEDOR;

DESCRIBE PEDIDOS;

INSERT INTO PEDIDOS VALUES
	('AAAAA', 'P1', '2022-01-23 13:01:44'),
    ('AAAAB', 'P1', '2021-01-21 11:01:44'),
    ('AAAAC', 'P1', '2022-04-11 13:22:22'),
    ('AAAAD', 'P2', '2022-01-07 07:14:44'),
    ('AAAAE', 'P2', '2021-12-23 20:01:21'),
    ('AAAAF', 'P3', '2021-11-03 13:01:11'),
    ('AAAAG', 'P3', '2021-07-15 19:01:12'),
    ('AAAAH', 'P3', '2022-01-23 13:01:44'),
    ('AAAAI', 'P4', '2021-10-11 09:01:56'),
    ('AAAAJ', 'P5', '2022-04-01 08:55:32'),
    ('AAAAK', 'P5', '2022-05-13 11:47:09'),
    ('AAAAL', 'P6', '2021-11-06 18:01:23');

SELECT * FROM PEDIDOS;


DESCRIBE DIRECCIONES;

INSERT INTO DIRECCIONES VALUES
	('Amor de Dios', 43, 'Madrid', 'Madrid', '+34678800961', 'alc1@gmail.com', '11', 'AAAAA'),
    ('Luca de Tena', 3, 'Madrid', 'Madrid', '+34678823961', 'alc2@gmail.com', '11', 'AAAAB'),
    ('Miguel Hernández', 11, 'Móstoles', 'Madrid', '+34679900961', 'eci1@gmail.com', '12', 'AAAAC'),
    ('Victoria Kent', 11, 'Rivas', 'Madrid', '+34611900961', 'eci2@gmail.com', '12', 'AAAAD'),
    ('Libertad', 21, 'Madrid', 'Madrid', '+34611904421', 'SP100@gmail.com', '13', 'AAAAE'),
    ('Guzmán el Bueno', 43, 'Madrid', 'Madrid', '+34611081961', 'mch@gmail.com', '14', 'AAAAF'),
    ('Sierpes', 43, 'Getafe', 'Madrid', '+34666781961', 'mch@gmail.com', '14', 'AAAAG'),   
    ('Fernando III', 12, 'Aranjuez', 'Madrid', '+34611074661', 'mmarkt@gmail.com', '15', 'AAAAH'),
    ('General Perón', 32, 'Madrid', 'Madrid', '+34611454961', 'mmarkt@gmail.com', '15', 'AAAAI'),
	('Guzmán el Bueno', 21, 'Madrid', 'Madrid', '+34619761961', 'crrfr@gmail.com', '16', 'AAAAJ'),
    ('Alemania', 23, 'Getafe', 'Madrid', '+34619432961', 'crrfr@gmail.com', '16', 'AAAAK'),
    ('Eva Perón', 36, 'Madrid', 'Madrid', '+34611081865', 'wrt@gmail.com', '17', 'AAAAL');    

SELECT * FROM DIRECCIONES;

DESCRIBE ARTICULOS;

INSERT INTO ARTICULOS VALUES 
	('A11', 40, 'Lego'),
    ('A12', 25, 'Funko Pop'),
    ('A13', 300, 'XBOX'),
    ('A14', 60, 'Juego XBOX'),
    ('A15', 30, 'My Little Pony'),
    ('A16', 45, 'Auriculares'),
    ('A17', 245, 'Smartphone'),
    ('A18', 50, 'PlayMobil'),
    ('A19', 25, 'Cómic'),
    ('A20', 20, 'Novela'),
    ('A21', 15, 'Poesía'),
    ('A22', 10, 'Libro infantil'),
    ('A23', 400, 'Lavadora'),
    ('A24', 300, 'Secadora'),
    ('A25', 40, 'Plancha'),
    ('A26', 230, 'Lavavajillas'),
    ('A27', 350, 'Horno');

SELECT * FROM ARTICULOS;

DESCRIBE LINEA_PEDIDO;

INSERT INTO CATEGORIA_PROVEEDOR VALUES 
("Bajo", "A"),
("Medio", "B"),
("Alto", "C"),
("Muy Alto", "D");

SELECT * FROM CATEGORIA_PROVEEDOR;

INSERT INTO LINEA_PEDIDO(IDPED, IDART, IDTIENDA, PRECIO_UNITARIO, NUDS, IDPROV) VALUES 
('AAAAA', 'A11', '11', 40, 22, 'P1'),
('AAAAA', 'A12', '11', 25, 100,'P1'),
('AAAAB', 'A18', '11', 50, 350, 'P1'),
('AAAAC', 'A13', '12', 300, 40, 'P1'),
('AAAAC', 'A14', '12', 60, 100, 'P1'),
('AAAAD', 'A23', '12', 400, 32, 'P2'),
('AAAAD', 'A24', '12', 300, 50, 'P2'),
('AAAAE', 'A19', '13', 25, 100, 'P2'),
('AAAAE', 'A20', '13', 20, 50, 'P2'),              
('AAAAE', 'A22', '13', 10, 200, 'P2'),
('AAAAF', 'A18', '14', 50, 130, 'P3'),
('AAAAF', 'A11', '14', 40, 200, 'P3'),
('AAAAG', 'A17', '14', 245, 30, 'P3'),
('AAAAG', 'A16', '14', 45, 200, 'P3'),
('AAAAH', 'A26', '15', 230, 25, 'P3'),
('AAAAH', 'A27', '15', 350, 50, 'P3'),
('AAAAI', 'A24', '15', 300, 70, 'P4'),
('AAAAI', 'A23', '15', 400, 30, 'P4'),
('AAAAJ', 'A20', '16', 20, 200, 'P5'),
('AAAAJ', 'A21', '16', 15, 200, 'P5'),
('AAAAK', 'A14', '16', 60, 300, 'P5'),
('AAAAK', 'A16', '16', 45, 160, 'P5'),
('AAAAK', 'A17', '16', 245, 40, 'P5'),
('AAAAL', 'A26', '17', 230, 30, 'P6'),
('AAAAL', 'A27', '17', 350, 25, 'P6');
    
SELECT * FROM LINEA_PEDIDO;

SELECT * FROM TIENDA;

SELECT * FROM PROVEEDOR;
# Preguntas 

# 2. Utilizar la instrucción SQL de inserción de datos para insertar una fila en la tabla de pedidos.
	# Antes debemos insertar la PK en proveedores
INSERT INTO PROVEEDOR(IDPROV) VALUES('P7');
INSERT INTO PEDIDOS VALUES ('AAAAM', 'P7', '2021-02-23 13:01:44');

SELECT * 
FROM  PEDIDOS WHERE IDPROV='P7';

# 3. Visualizar mediante una instrucción SQL todas las tiendas que componen la red de distribución de la fábrica, se deberán detallar: nombre de la tienda, dirección, descripción de la categoría, descuento y límite de crédito asociado a la tienda.
DROP VIEW IF EXISTS INFO_TIENDAS;
CREATE VIEW INFO_TIENDAS AS SELECT T.*, C.DESCRIPCION_CAT, C.DESCUENTO, D.CALLE, D.NUM, D.POBLACIÓN, D.CIUDAD
FROM TIENDA T, CATEGORIA C, DIRECCIONES D WHERE T.IDCAT = C.IDCAT AND T.IDTIENDA=D.IDTIENDA;

DESCRIBE INFO_TIENDAS;

SELECT * FROM INFO_TIENDAS;

	# Como podemos observar, hay varias direcciones según tienda, pero naturalmente todas las tiendas entran en la misma categoría
    
# 4. Visualizar mediante una instrucción SQL los pedidos suministrados a cada una de las tiendas en un período determinado (último año). Se deberán obtener los siguientes datos: número de pedido, fecha de suministro, dirección de entrega, y el importe total del pedido.
SELECT P.IDPED, P.FECHA, D.CALLE, D.NUM, D.POBLACIÓN, D.CIUDAD, SUM(LP.TOTALPED) AS TOTAL_PEDIDO
FROM PEDIDOS P, DIRECCIONES D, LINEA_PEDIDO LP 
WHERE P.IDPED = D.IDPED AND P.IDPED = LP.IDPED AND FECHA BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
GROUP BY IDPED;

# 5. Identificar mediante una consulta SQL los repartos realizados por cada uno de los proveedores destinados a ello. Se deberá identificar al menos: Nombre del proveedor de reparto, su dirección y la relación de los artículos suministrados en cada reparto.
SELECT PR.*, LP.IDPED, LP.PRECIO_UNITARIO, LP.NUDS, DESCRIPCION_ART
FROM PEDIDOS P, LINEA_PEDIDO LP, PROVEEDOR PR, ARTICULOS A
WHERE LP.IDPED=P.IDPED AND P.IDPROV=PR.IDPROV AND LP.IDART=A.IDART;



# 6. Totalizar los repartos anuales realizados por cada proveedor de reparto.
SELECT PR.NOMBRE, YEAR(P.FECHA) as Año, SUM(LP.TOTALPED) AS TOTAL_PEDIDOS, COUNT(DISTINCT(LP.IDPED)) AS PEDIDOS_REALIZADOS
FROM PROVEEDOR PR, LINEA_PEDIDO LP, PEDIDOS P
WHERE PR.IDPROV=P.IDPROV AND LP.IDPED=P.IDPED
GROUP BY PR.NOMBRE, Año

# 7. Identificar los cambios a realizar en el modelo relacional y en BBDD para clasificar a los proveedores de reparto en categorías, de la misma forma que clasificamos las tiendas por categorías.
# CREAMOS LA NUEVA TABLA DE CATEGORÍAS DE PROVEEDOR
    
SELECT * FROM PROVEEDOR;

# 8. Necesitamos introducir nuevos atributos en la tabla de artículos, la fábrica ha descubierto que puede comprar un artículo de parecidas características al nuestro y distribuirlo como marca blanca.
	# Introducimos una dicotomía entre artículos originales y de marca blanca
ALTER TABLE ARTICULOS
ADD COLUMN TIPO ENUM("ORIGINAL", "MARCA BLANCA");
SELECT * FROM ARTICULOS;

# 9. Queremos ampliar la información del proveedor de suministro, para ello necesitaríamos incorporar los datos relativos a las zonas de cobertura de este (Países y Regiones). Determinar los cambios a realizar a nivel físico y lógico
CREATE TABLE ZONA_PROVEEDOR
(
PAÍS VARCHAR(50),
REGIÓN VARCHAR(50),
IDPROV CHAR(5),
FOREIGN KEY (IDPROV) REFERENCES PROVEEDOR(IDPROV)
);
SELECT * FROM ZONA_PROVEEDOR



# 10. ¿Qué podríamos hacer para realizar un backup de la tabla de pedidos / líneas de pedido? Esto es, necesitamos hacer todos los días un proceso de backup a otra Base de Datos en las que se consolida toda la venta del grupo (pedidos, líneas de pedido).

DROP PROCEDURE IF EXISTS NUEVA_TABLA
DELIMITER //

CREATE PROCEDURE NUEVA_TABLA()
BEGIN
	SELECT P.FECHA, P.IDPROV, P.IDPED, LP.IDART, LP.IDTIENDA, LP.NUDS, LP.PRECIO_UNITARIO, LP.TOTALPED 
    FROM LINEA_PEDIDO LP, PEDIDOS P
    WHERE P.IDPED=LP.IDPED;
END //

DROP EVENT IF EXISTS GUARDADO_DIARIO;

DELIMITER //
CREATE EVENT GUARDADO_DIARIO
ON SCHEDULE EVERY 24 HOUR
DO
CALL NUEVA_TABLA;
//

CALL NUEVA_TABLA
