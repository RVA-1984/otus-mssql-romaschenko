Начало проектной работы. 
Создание таблиц и представлений для своего проекта.

Нужно написать операторы DDL для создания БД вашего проекта:
1. Создать базу данных.
2. 3-4 основные таблицы для своего проекта. 
3. Первичные и внешние ключи для всех созданных таблиц.
4. 1-2 индекса на таблицы.
5. Наложите по одному ограничению в каждой таблице на ввод данных.

Обязательно (если еще нет) должно быть описание предметной области.

--1.Cоздание базы данных
CREATE DATABASE credit_portfolio;
GO

--2 Cоздание таблиц+ 3.Присвоение ключей

--Создание таблиц по менеджерам
CREATE TABLE dbo.managers (
manager_id int not null PRIMARY KEY,
manager_name varchar (100) not null,
city_name varchar (100) not null)

INSERT INTO dbo.managers VALUES
(10,'Кулакова Кристина Геннадьевна','Москва'),
(15,'Киров Никита Романович','Барнаул'),
(45,'Куприян Армен Сергеевич','Люберцы'),
(60,'Андрейко Валентин Аристархович','Москва'),
(77,'Куликова Татьяна Васильевна','Нижний Новгород'),
(92,'Литресова Екатерина Ивановна','Санкт-Петербург'),
(94,'Карапетян Рафик Иванович','Екатеринбург'),
(101,'Полетаева Кристина Альбертовна','Липецк')

select * from dbo.managers

--Создание таблицы по продуктам

CREATE TABLE dbo.products (
product_id int not null PRIMARY KEY,
product_name varchar (100) not null)


INSERT INTO dbo.products VALUES
(7565,'Ипотека_вторичка'),
(444,'Потребительский_без залога'),
(2785,'Ипотека_первичка'),
(458,'Кредитная карта_много плюсов'),
(990,'Кредитование_МБ'),
(145,'Кредитование_ИП'),
(12,'Корпоративное кредитование'),
(75,'Кредитование_СБ')

select * from dbo.products

--Создание таблицы по клиентам


CREATE TABLE dbo.clients (
id_client int not null PRIMARY KEY,
client_name varchar (100) not null,
date_birth date not null,
home_address varchar (100) not null)

INSERT INTO dbo.clients VALUES
(100,'Иванов Иван Иванович','1985-07-21', 'Люберцы'),
(101,'Петров Илья Сергеевич','1970-02-15', 'Люберцы'),
(102,'Завьялова Вероника Александровна','1981-03-17', 'Нижний Новгород'),
(103,'Кусторица Михаил Иванович','1979-04-15', 'Нижний Новгород'),
(104,'Перепатько Валентина Ивановна','1984-07-17', 'Екатеринбург'),
(105,'Штольц Ангелина Рудольфовна','1975-01-15', 'Екатеринбург'),
(106,'Лаврова Зинаида Николаевна','1990-08-27', 'Екатеринбург'),
(107,'Либерман Соня Семеновна','1972-01-01', 'Москва'),
(108,'Мартиросян Радик Сергеевич','1989-04-15', 'Нижний Новгород'),
(109, 'Курпало Валентин Иванович', '1974-03-21', 'Люберцы'),
(110, 'ООО "Ромашка"', '1992-01-01', 'Барнаул'),
(111, 'ООО "Вип Трэвэл"', '1999-07-01', 'Барнаул'),
(112, 'ИП Мурашко Иван Сергеевич', '1970-07-19', 'Санкт-Петербург'),
(113, 'АО ГК "Пульс"', '2001-12-25', 'Липецк'),
(114, 'ООО "Касабланка"', '2004-05-31','Липецк'),
(115, 'Романов Роман Геннадьевич', '1987-06-19', 'Москва'),
(116, 'ООО "Промышленная компания"', '2002-03-15', 'Москва'),
(117, 'Тришковец Наталья Ивановна', '1991-09-15', 'Нижний Новгород'),
(118, 'Пузиков Илья Валентинович', '1985-08-17', 'Люберцы'),
(119, 'Гаас Вячеслав Генрихович', '1992-01-31', 'Екатеринбург')

select * from dbo.clients

--Создание таблицы кредитных договоров

CREATE TABLE dbo.loan_agreements (
id_agreement int not null PRIMARY KEY,
id_client int not null,
product_id int not null, 
manager_id int not null)

INSERT INTO dbo.loan_agreements VALUES
(245, 100,7565, 45),
(352, 101, 7565,45),
(485, 102, 444, 77),
(675, 103,  444,  77),
(985, 104,  2785, 94),
(1020, 105,  2785,94),
(2152, 106,  2785,  94),
(8755, 107,  458,  60),
(348556, 108,  444,  77),
(4523687, 109,  7565,  45),
(2587657, 110,	 990,  15),
(75, 111,  990,  15),
(478965, 112,  145, 92),
(347856, 113,  12,  101),
(9745634, 114,	 12, 101),
(54769856, 115,  458,  60),
(9533542, 116,	 75, 10),
(54884222, 117, 444, 77),
(2145752125, 118, 7565, 45),
(324522151, 119, 2785, 94)

select * from dbo.loan_agreements

--Создание основной таблицы "Кредитный портфель"

CREATE TABLE dbo.loan_portfolio (
id_agreement int not null PRIMARY KEY,
id_client int not null,
date_from date not null,
date_to date not null,
date_change date not null,
сurrency varchar (100) not null,
interest_rate decimal (19,2) not null,
amount_agreement decimal (19,2) not null,
balance_owed decimal (19,2) not null,
interest_charges decimal (19,2) not null,
overdue_debt decimal (19,2),
overdue_interest decimal (19,2),
accrued_reserves decimal (19,2),
loan_status varchar (100) not null)

INSERT INTO dbo.loan_portfolio VALUES
(245,100,'2020-10-27','2040-10-27','2023-09-30',	'RUB',6.9,7500000.00,	7145131.00,	40521.70,0.00,0.00,	179641.32,'Open'),
(352, 101,'2017-08-15','2032-08-15', '2023-09-30','RUB',7.5,3400000.00,	3045131.00,	18771.36,0.00,0.00,76597.56,'Open'),
(485, 102, 	'2014-01-01','2024-01-01','2023-09-30','RUB',17.5,700000.00,345131.00, 4964.21,0.00,0.00,8752.38,'Open'),
(675, 103,'2019-02-14','2026-02-14','2023-09-30','RUB',10.4,1250000.00,	895131.00,	7651.53,	0.00,	0.00,	22569.56,	'Open'),
(985,	104,	'2016-05-17','2031-05-17','2023-09-30','RUB',4.5,	10500000.00,	10145131.00,	37523.09,	0.00,	0.00,	254566.35,	'Open'),
(1020,	105,	'2021-06-21','2041-06-21','2023-10-05','RUB',4.5,	2950000.00,	2595131.00,	9598.43,	0.00,	0.00,	65118.24,	'Open'),
(2152,	106,	'2011-07-15','2031-07-15','2023-10-05','RUB',4.5,	5420000.00,	5065131.00,	18734.05,	0.00,	0.00,	127096.63,	'Open'),
(8755,	107,'2018-07-17','2200-12-31','2023-10-05','RUB',39.9,	250000.00,	250000.00,	8198.63,	0.00,	0.00,	250000.00,	'Open'),
(348556,	108,	'2015-08-29','2025-08-29','2023-10-08','RUB',17.5,	1000000.00,	645131.00,	9279.28,	0.00,	0.00,	16360.26,	'Open'),
(4523687,	109,	'2016-07-24','2036-07-24','2023-10-08','RUB',7.5,	9250000.00,	8895131.00,	54833.00,	0.00,	0.00,	223749.10,	'Open'),
(2587657,	110,	'2020-02-05','2027-02-05','2023-10-08','RUB',7.2,175000000.00,	173541380.00,	1026984.60,	0.00,	0.00,	4364209.12,	'Open'),
(75,	111,	'2018-03-14','2028-03-14','2023-10-08','RUB',7.2,450000000.00,	448541380.00,	2654381.87,	0.00,	0.00,	11279894.05,	'Open'),
(478965,	112,	'2020-03-17','2030-03-17','2023-10-08','RUB',8.9,250000000.00,	248541380.00,	1818097.22,	0.00,	0.00,	6258986.93,	'Open'),
(347856,	113,	'2020-01-21','2025-01-21','2023-10-13','RUB',10.6,500000000.00,	498541380.00,	4343456.41,	0.00,	0.00,	12572120.91,	'Open'),
(9745634,	114,	'2019-03-17','2024-03-17','2023-10-13','RUB',10.6,750000000.00,	748541380.00,	6521538.60,	0.00,	0.00,	18876572.96,	'Open'),
(54769856,	115,	'2019-02-03','2200-12-31','2023-10-13','RUB',39.9,100000.00,	100000.00,	3279.45,	0.00,	0.00,	100000.00,	'Open'),
(9533542,	116,	'2020-05-15','2025-05-15','2023-10-13','RUB',11.5,400000000.00,	398541380.00,	3767034.96,	0.00,	0.00,	10057710.37,'Open'),
(54884222,	117,	'2019-07-21','2027-07-21','2023-10-17','RUB',3.9,2000000.00,	1645131.00,	5273.43,	0.00,	0.00,	41260.11,	'Open'),
(2145752125,	118,	'2013-09-23','2043-09-23','2023-10-17','RUB',10.2,6450000.00,	6095131.00,	51098.91,	0.00,	0.00,	153655.75,	'Open'),
(324522151,	119,	'2022-10-19','2042-10-19','2023-10-17','RUB',4.5,3000000.00,	2645131.00,	9783.36,	0.00,	0.00,	66372.86,	'Open')

select * from dbo.loan_portfolio

--4. Индексы на таблицы

CREATE INDEX idx_clients ON dbo.clients (id_client,
client_name,
date_birth,
home_address)

CREATE INDEX idx_managers ON dbo.managers (
manager_id,
manager_name,
city_name)

CREATE INDEX idx_products ON dbo.products ( 
product_id,
product_name)

CREATE INDEX idx_agreements ON dbo.loan_agreements (
id_agreement,
id_client,
product_id,
manager_id)


CREATE INDEX idx_loan_portfolio ON dbo.loan_portfolio (
Id_agreement,
id_client,
date_from,
date_to,
date_change,
сurrency,
interest_rate,
amount_agreement,
balance_owed,
interest_charges,
overdue_debt,
overdue_interest,
accrued_reserves,
loan_status)

--5. Наложение по одному ограничению на ввод данных
ALTER TABLE dbo.loan_portfolio
ADD CONSTRAINT chack_date 
CHECK (date_from <= date_to);

GO
CREATE FUNCTION get_date_birthd(@date_birth DATE)
RETURNS VARCHAR (50)
AS BEGIN 
RETURN (SELECT date_birth FROM dbo.clients WHERE date_birth=@date_birth);
END;


CREATE FUNCTION get_manager_id(@manager_id int)
RETURNS VARCHAR (50)
AS BEGIN 
RETURN (SELECT manager_id FROM dbo.managers WHERE manager_id=@manager_id);
END;

ALTER TABLE dbo.managers
ADD CONSTRAINT chack_manager_id
CHECK (dbo.get_manager_id (manager_id) is not null)

GO



CREATE FUNCTION get_id_agreements(@id_agreement int)
RETURNS VARCHAR (50)
AS BEGIN 
RETURN (SELECT id_agreement FROM dbo.loan_agreements WHERE id_agreement=@id_agreement);
END;

ALTER TABLE dbo.loan_agreements
ADD CONSTRAINT chack_id_agreement
CHECK (dbo.get_id_agreement (id_agreement) is not null)

GO





















































