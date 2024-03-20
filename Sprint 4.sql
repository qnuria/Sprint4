#0 creacion BBDD: schema
CREATE DATABASE transacciones;
# creacion tablas
CREATE TABLE `transacciones`.`companies` (
  `company_id` VARCHAR(6) NOT NULL,
  `company_name` VARCHAR(45) NULL,
  `phone` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `country` VARCHAR(45) NULL,
  `website` VARCHAR(45) NULL,
  PRIMARY KEY (`company_id`),
  UNIQUE INDEX `company_id_UNIQUE` (`company_id` ASC) VISIBLE);
#importacion datos desde fichero csv, desde GRID "import records from an external file"
#cada columna con el tipo correcto en funcion del tipo de dato que se analiza viendo el csv..

#union de 3 tablas en una porque tienen la misma estructura
CREATE TABLE USERS_TOTAL AS
	SELECT * FROM USERS_USA
	UNION
	SELECT * FROM USERS_UK
	UNION
	SELECT * FROM USERS_CA
;
#Añado primary Key a la tabla recien creada y marco que sera unica.
ALTER TABLE `transacciones`.`users_total` 
ADD PRIMARY KEY (`id`),
ADD UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE;
;
#añado indice.
CREATE INDEX id_index ON users_total(id);

#creacion de las relaciones entre tablas, creando FK -PK en tabla transacciones, y cambios CASCADE

#Ejercicio 1
SELECT users_total.name, COUNT(transaction.id) as NumTransactions
FROM users_total
JOIN transaction
On users_total.id=transaction.user_id
GROUP BY users_total.name
HAVING COUNT(transaction.id)>30;

#Ejercicio 2
SELECT companies.company_name, credit_cards.iban, AVG(transaction.amount) as MediaTransaccion
FROM credit_cards
JOIN transaction
On credit_cards.id=transaction.card_id
JOIN companies
ON companies.company_id=transaction.business_id
WHERE companies.company_name = "Donec Ltd"
GROUP BY companies.company_name, credit_cards.iban;

#Nivel 2
#Ejercicio 1
CREATE TABLE Estado_tarjetas
	SELECT CARD_ID,IF(SUM(DECLINED)=3,"INACTIVA","ACTIVA") AS ESTADO
	FROM  (
		SELECT CARD_ID, TIMESTAMP, DECLINED, 
		row_number() OVER(PARTITION BY CARD_ID ORDER BY TIMESTAMP DESC) AS FILA
		FROM transaction) AS NUEVATABLA
		WHERE FILA<=3
	GROUP BY CARD_ID
;

SELECT COUNT(CARD_ID) AS NºTARJETAS_ACTIVAS
FROM estado_tarjetas
WHERE ESTADO ="ACTIVA";

#Nivel 3
#creando variable usuario @num
CREATE TABLE transactionNew
SELECT * ,
    @num := 1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', ''))              AS num,
    IF(@num >= 1, SUBSTRING_INDEX(product_ids, ',', 1), NULL)                           AS Pdt_id1,
    IF(@num > 1, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1), NULL) AS Pdt_id2,
    IF(@num > 2, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1), NULL) AS Pdt_id3,
    IF(@num > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1), NULL) AS Pdt_id4
   FROM transaction;
   
#idem pero sin variable usuario @num
CREATE TABLE transactionNew
   SELECT * ,
     (1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')))              AS num,
    IF((1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', ''))) >= 1, SUBSTRING_INDEX(product_ids, ',', 1), NULL)                           AS Pdt_id1,
    IF((1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')))> 1, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1), NULL) AS Pdt_id2,
    IF((1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', ''))) > 2, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1), NULL) AS Pdt_id3,
    IF((1 + LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', ''))) > 3, SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1), NULL) AS Pdt_id4
   FROM transaction;
   
#Ejercicio 1

SELECT PRODUCTOSVENDIDOS.IDPRODUCTO AS NºPRODUCTO, products.product_name ,COUNT(PRODUCTOSVENDIDOS.IDPRODUCTO) AS NºVECESCOMPRADO
FROM products
JOIN 
	(SELECT PDT_ID1 AS IDPRODUCTO FROM TRANSACTIONNEW
    UNION ALL
    SELECT PDT_ID2 AS IDPRODUCTO FROM TRANSACTIONNEW
    UNION ALL
    SELECT PDT_ID3 AS IDPRODUCTO FROM TRANSACTIONNEW
    UNION ALL
    SELECT PDT_ID4 AS IDPRODUCTO FROM TRANSACTIONNEW) AS PRODUCTOSVENDIDOS
ON products.id=productosvendidos.idproducto
WHERE 
	IDPRODUCTO IS NOT NULL
GROUP BY IDPRODUCTO;
