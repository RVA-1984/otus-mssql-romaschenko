/*

Думаем какие запросы у вас будут в базе и добавляем для них индексы. Проверяем, что они используются в запросе. 

*/
--Колоночные индексы (Column-store indexes)


 USE credit_portfolio;

--Создание таблицы для индексов
 
 DROP TABLE IF EXISTS dbo.Index_loan_portfolio

 SELECT 
 id_agreement,
 id_client,
 client_name,
 date_from,
 date_to,
 amount_agreement
 INTO dbo.Index_loan_portfolio
 FROM dbo.loan_portfolio
 GO

 --Создание Column Store индекс в Index_loan_portfolio
CREATE COLUMNSTORE INDEX Index_loan_portfolio
ON dbo.Index_loan_portfolio (id_agreement);
GO

SELECT 
id_agreement,
 id_client,
 client_name,
 date_from,
 date_to,
 amount_agreement
 FROM dbo.Index_loan_portfolio OPTION(MAXDOP 1);
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
INCLUDE(client_name);
GO

-- Фильтрованные индексы (Filtered index)
USE credit_portfolio;

CREATE TABLE #product (
id_agreement int not null,
product_id int not null,
product_name varchar (100) not null);

INSERT INTO #product VALUES
(245,7565,'Ипотека_вторичка'),
(352,7565,'Ипотека_вторичка'),
(485,444,'Потребительский_без залога'),
(675,444,'Потребительский_без залога'),
(985,2785,'Ипотека_первичка'),
(1020,2785,'Ипотека_первичка'),
(2152,2785,'Ипотека_первичка'),
(8755,458,'Кредитная карта_много плюсов'),
(348556,444,'Потребительский_без залога'),
(4523687,7565,'Ипотека_вторичка'),
(2587657,990,'Кредитование_МБ'),
(75,990,'Кредитование_МБ'),
(478965,145,'Кредитование_ИП'),
(347856,12,'Корпоративное кредитование'),
(9745634,12,'Корпоративное кредитование'),
(54769856,458,'Кредитная карта_много плюсов'),
(9533542,75,'Кредитование_СБ'),
(54884222,444,'Потребительский_без залога'),
(2145752125,7565,'Ипотека_вторичка'),
(324522151,2785,'Ипотека_первичка')

CREATE UNIQUE NONCLUSTERED INDEX InX_product
ON #product (id_agreement,product_id, product_name)
WHERE(id_agreement is not null);

SELECT id_agreement,product_id, product_name FROM #product




