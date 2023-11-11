/*

Думаем какие запросы у вас будут в базе и добавляем для них индексы. Проверяем, что они используются в запросе. 

*/
--Колоночные индексы (Column-store indexes)


 USE credit_portfolio;

--Создание таблицы для индексов
 
 DROP TABLE IF EXISTS dbo.Index_loan_portfolio1

 SELECT 
 id_agreement,
 id_client,
 date_from,
 date_to,
 amount_agreement
 INTO dbo.Index_loan_portfolio1
 FROM dbo.loan_portfolio
 GO

 --Создание Column Store индекс в Index_loan_portfolio
CREATE COLUMNSTORE INDEX Index_loan_portfolio1
ON dbo.Index_loan_portfolio1 (id_agreement);
GO

SELECT 
id_agreement,
 id_client,
 date_from,
 date_to,
 amount_agreement
 FROM dbo.Index_loan_portfolio1 OPTION(MAXDOP 1);
 GO

 --Cоставные индексы (Composite indexes)

 USE credit_portfolio;
 --WHERE manager_id =  60
 DROP INDEX IF EXISTS Inx_manager_id ON [managers];
 DROP INDEX IF EXISTS Inx_manager_name ON [managers];
 GO

CREATE INDEX Inx_manager_id
ON [managers] (manager_id, manager_name);
GO

SELECT manager_id, manager_name
FROM [managers]
WHERE manager_id =  60;
GO

--Покрывающие (Covering index)

USE credit_portfolio;
SET STATISTICS IO ON;

-- Index Seek 
SELECT Id_agreement
FROM dbo.loan_portfolio
WHERE Id_agreement = 2152;

-- Index Seek + Key Lookup 
SELECT Id_agreement, client_name
FROM dbo.loan_portfolio
WHERE Id_agreement = 2152;

-- Добавляем индекс с INCLUDE
CREATE NONCLUSTERED INDEX [NONCL_loan_portfolio_Id_agreement_INCL_Id_agreement] 
ON [loan_portfolio]
(
	[Id_agreement] ASC
)
INCLUDE(id_client);
GO

-- Фильтрованные индексы (Filtered index)
USE credit_portfolio;

CREATE TABLE #product (
product_id int not null,
product_name varchar (100) not null);

INSERT INTO #product VALUES
(7565,'Ипотека_вторичка'),
(444,'Потребительский_без залога'),
(2785,'Ипотека_первичка'),
(458,'Кредитная карта_много плюсов'),
(990,'Кредитование_МБ'),
(145,'Кредитование_ИП'),
(12,'Корпоративное кредитование'),
(75,'Кредитование_СБ')

CREATE UNIQUE NONCLUSTERED INDEX InX_product
ON #product (product_id, product_name)
WHERE(product_id is not null);

SELECT product_id, product_name FROM #product




