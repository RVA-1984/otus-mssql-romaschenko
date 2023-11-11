USE credit_portfolio;
--создаем функцию партиционирования по годам 
CREATE PARTITION FUNCTION [fnYearPartition1](DATE) AS RANGE RIGHT FOR VALUES
('2013-01-01','2014-01-01','2015-01-01','2016-01-01', '2017-01-01',
 '2018-01-01', '2019-01-01', '2020-01-01', '2021-01-01','2022-01-01', '2023-01-01');																																																									
GO

-- партиционируем, используя созданную нами функцию
CREATE PARTITION SCHEME [YearPartition1] AS PARTITION [fnYearPartition1] 
ALL TO ([PRIMARY])
GO

--Создание клона таблицы loan_portfolio для партиционирования. Таблица будет называться loan_portfolio1
CREATE TABLE [dbo].[loan_portfolio2](
[id_agreement] [int] not null,
[id_client] [int] not null,
[date_from] [date] not null,
[date_to] [date] not null,
[date_change] [date] not null,
[сurrency] [varchar] (100) not null,
[interest_rate] [decimal] (19,2) not null,
[amount_agreement] [decimal] (19,2) not null,
[balance_owed] [decimal] (19,2) not null,
[interest_charges] [decimal] (19,2) not null,
[overdue_debt] [decimal] (19,2),
[overdue_interest] [decimal] (19,2),
[accrued_reserves] [decimal] (19,2),
[loan_status] [varchar] (100) not null,
) ON [YearPartition]([date_from])--в схеме [YearPartition] по ключу [date_from]

--создаем наши секционированные таблицы
SELECT * INTO section_table1
FROM loan_portfolio;



