/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |         1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SET STATISTICS IO, TIME ON

--SELECT TOP 100 * FROM [Sales].[Invoices]
--SELECT TOP 100 * FROM [Application].[People] WHERE  SearchName LIKE '%Tailspin%' and PersonID BETWEEN 2 AND 6 
--SELECT TOP 100 * FROM [Sales].[InvoiceLines]

--select SUBSTRING(c.CustomerName, CHARINDEX('(',c.CustomerName) + 1 , LEN(c.CustomerName) -  CHARINDEX('(',c.CustomerName) - 1 )
--from Sales.Customers c
--where CustomerName like '%Tailspin Toys%' AND CustomerID in (2,3,4,5,6)



;WITH
person as (
	SELECT 
		FORMAT(s.InvoiceDate, 'dd.MM.yyyy') as InvoiceMonth, 
		SUBSTRING( c.CustomerName, CHARINDEX('(',c.CustomerName) + 1 , LEN(c.CustomerName) - CHARINDEX('(',c.CustomerName) - 1 ) as [Client]
	FROM Sales.Customers c
	LEFT JOIN [Sales].[Invoices] s on s.CustomerID=c.CustomerID 
	WHERE CustomerName like '%Tailspin Toys%' 
		AND c.CustomerID in (2,3,4,5,6)
		AND s.InvoiceDate IS NOT NULL
),
PivotTab as ( 
	SELECT * FROM person
	PIVOT(
	COUNT(Client) FOR  Client IN ([Sylvanite, MT],
									[Peeples Valley, AZ],
									[Medicine Lodge, KS],
									[Gasport, NY],
									[Jessie, ND])
	) as PVT
)
SELECT
*, 
	+ [Sylvanite, MT]  
	+ [Peeples Valley, AZ] 
	+ [Medicine Lodge, KS] 
	+ [Gasport, NY] 
	+ [Jessie, ND]
	as  [TotalQty]
FROM PivotTab
ORDER BY CAST( SUBSTRING(InvoiceMonth, 7,4) as int),  CAST( SUBSTRING(InvoiceMonth, 4,2) as int), CAST( SUBSTRING(InvoiceMonth, 0,2) as int)

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

--SELECT TOP 100 * FROM Sales.Customers


;WITH 
	Adres as (
	SELECT *
	FROM(
		SELECT 
			CustomerID,
			CustomerName,
			DeliveryAddressLine1,
			DeliveryAddressLine2,
			PostalAddressLine1,
			PostalAddressLine2
		FROM Sales.Customers 
		WHERE CustomerName like '%Tailspin Toys%'
	) t
	UNPIVOT (AddressLine FOR Name IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1,PostalAddressLine2)) AS unpt
)

SELECT 
	c.CustomerName, 
	TailspinToys.AddressLine
FROM Sales.Customers c
CROSS APPLY(
	SELECT *
	FROM Adres ad
	WHERE  ad.CustomerID=c.CustomerID
) as TailspinToys



/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT *
FROM (
	SELECT  
		CountryId, 
		CountryName, 
		CAST( IsoAlpha3Code as VARCHAR(255) ) as IsoAlpha3Code ,
		CAST( IsoNumericCode as VARCHAR(255) ) as IsoNumericCode
	FROM Application.Countries 
) c
UNPIVOT (
	Code FOR Name IN (IsoAlpha3Code, IsoNumericCode)
) AS unpt




--SELECT TOP 100  * FROM Application.Countries c


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT 
	c.CustomerID, 
	c.CustomerName, 
	inv.StockItemID,
	--inv.Description,
	inv.UnitPrice, 
	inv.[MaxInvoiceDate]
FROM Sales.Customers c
CROSS APPLY(
	SELECT TOP 2 
		s.CustomerID,
		il.StockItemID,
		il.Description,
		il.UnitPrice,
		MAX(s.InvoiceDate) AS [MaxInvoiceDate]
	FROM [Sales].[InvoiceLines] il
	LEFT JOIN  [Sales].[Invoices] s on s.InvoiceID=il.InvoiceID
	--WHERE s.CustomerID=1
	WHERE s.CustomerID=c.CustomerID
	GROUP BY
		s.CustomerID,
		il.StockItemID,
		il.Description,
		il.UnitPrice
	ORDER BY 
		il.UnitPrice desc
		--[MaxInvoiceDate] desc
) as inv

--SELECT TOP 100 * FROM [Sales].[Invoices] s
--SELECT TOP 100 * FROM [Sales].[InvoiceLines]
--SELECT TOP 100 * FROM  [Warehouse].[StockItems]