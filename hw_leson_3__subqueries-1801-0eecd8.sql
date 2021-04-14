/*

----------------

Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
SELECT
	PersonID,
	FullName
FROM Application.People
WHERE PersonID NOT IN (
			SELECT DISTINCT
				CustomerID
			FROM Sales.Invoices 
			WHERE InvoiceDate = N'2015-07-04'
			)
	AND IsSalesperson = 1

	-------- WITH
;WITH
Person as(
	SELECT
		PersonID,
		FullName
	FROM Application.People
	WHERE IsSalesperson = 1
),
Sales as (
	SELECT DISTINCT
		CustomerID
	FROM Sales.Invoices 
	WHERE InvoiceDate = N'2015-07-04'
)
SELECT 
	* 
FROM Person 
WHERE PersonID NOT IN (
					SELECT CustomerID FROM Sales
				)


--SELECT TOP 100 * FROM Sales.Invoices
--SELECT TOP 100 * FROM Application.People

--SELECT 
--	PersonID,
--	s.CustomerID
--FROM Application.People p
--JOIN (SELECT DISTINCT CustomerID FROM Sales.Invoices ) s on s.CustomerID=p.PersonID


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 

SELECT
	StockItemID,
	StockItemName,
	[MinPrice]
FROM(
	SELECT
		st.StockItemID,
		st.StockItemName,
		MIN(ol.UnitPrice) as [MinPrice]
	FROM [Warehouse].[StockItems] st
	LEFT JOIN [Sales].[OrderLines] ol on ol.StockItemID=st.StockItemID
	GROUP BY st.StockItemID,
			 st.StockItemName
) gr
WHERE [MinPrice] = (SELECT MIN(UnitPrice) FROM [Sales].[OrderLines])

----------- WITH

;WITH
Prod as (
	SELECT
		st.StockItemID,
		st.StockItemName,
		MIN(ol.UnitPrice) as [MinPrice]
	FROM [Warehouse].[StockItems] st
	LEFT JOIN [Sales].[OrderLines] ol on ol.StockItemID=st.StockItemID
	GROUP BY st.StockItemID,
			 st.StockItemName
),
AllMinPrice(MinPriceAll) as (
	SELECT 
		MIN(UnitPrice) 
	FROM [Sales].[OrderLines]
)
SELECT
	StockItemID,
	StockItemName,
	[MinPrice]
FROM Prod p
JOIN AllMinPrice m on m.MinPriceAll=p.MinPrice

---- ДОПОЛНИТЕЛЬНОЕ РЕШЕНИЕ ----- DECLARE

DECLARE @MinP as float = (SELECT MIN(UnitPrice) FROM [Sales].[OrderLines])

SELECT
	st.StockItemID,
	st.StockItemName,
	MIN(ol.UnitPrice) as [MinPrice]
FROM [Warehouse].[StockItems] st
LEFT JOIN [Sales].[OrderLines] ol on ol.StockItemID=st.StockItemID
GROUP BY st.StockItemID,
			st.StockItemName
HAVING  MIN(ol.UnitPrice)  = @MinP

--SELECT TOP 100 * FROM [Sales].[OrderLines]
--SELECT TOP 100 * FROM [Warehouse].[StockItems]

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO:

SELECT TOP 5
p.PersonID,
p.FullName,
ct.TransactionAmount
FROM Sales.CustomerTransactions ct
LEFT JOIN [Sales].[Invoices] s ON s.InvoiceID=ct.InvoiceID
LEFT JOIN [Application].[People] p on p.PersonID=s.SalespersonPersonID
WHERE ct.InvoiceID IS NOT NULL
ORDER BY ct.TransactionAmount desc

------------------------- WITH 
;WITH
tt as (
	SELECT TOP 5 
		InvoiceID,
		TransactionAmount 
	FROM Sales.CustomerTransactions 
	WHERE InvoiceID IS NOT NULL 
	ORDER BY TransactionAmount desc
)
SELECT 
	p.PersonID,
	p.FullName,
	tt.TransactionAmount
FROM tt
LEFT JOIN [Sales].[Invoices] s ON s.InvoiceID=tt.InvoiceID
LEFT JOIN [Application].[People] p on p.PersonID=s.SalespersonPersonID
ORDER BY tt.TransactionAmount desc


--SELECT COUNT(InvoiceID), COUNT(DISTINCT InvoiceID) FROM Sales.CustomerTransactions
--SELECT TOP 100 * FROM Sales.CustomerTransactions
--SELECT TOP 100 * FROM [Sales].[OrderLines]
--SELECT TOP 100 * FROM [Sales].[Invoices]
--SELECT TOP 100 * FROM [Application].[People]


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 

--SELECT TOP 100 * FROM  [Application].[Cities]
--SELECT TOP 100 * FROM  [Purchasing].[SupplierTransactions]
--SELECT TOP 100 * FROM  [Purchasing].[Suppliers]
--SELECT TOP 100 * FROM [Warehouse].[StockItems] 
--SELECT TOP 100 * FROM  [Sales].[Invoices]
--SELECT TOP 100 * FROM [Sales].[InvoiceLines]

--SELECT TOP 100 * FROM [Sales].[OrderLines]
--SELECT TOP 100 * FROM [Sales].[Orders]

-------- ИТОГОВОЕ РЕШЕНИЕ -------

SELECT DISTINCT
	c.CityID, c.CityName, [EmploeePacked]
FROM [Application].[Cities] c
 JOIN (
	SELECT TOP 3 
		st.StockItemName,
		st.UnitPrice,
		s.PostalCityID,
		(SELECT TOP 1 p.FullName
			FROM  [Sales].[InvoiceLines] il
			LEFT JOIN [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
			LEFT JOIN [Application].[People] p on p.PersonID=i.PackedByPersonID
			WHERE il.StockItemID=st.StockItemID
			ORDER BY StockItemID
		) [EmploeePacked]
	FROM [Warehouse].[StockItems] st
	LEFT JOIN  [Purchasing].[Suppliers] s on s.SupplierID=st.SupplierID
	ORDER BY UnitPrice DESC
) TopProd on TopProd.PostalCityID=c.CityID


---------------- WITH --------------------

;WITH
TopProd as (
	SELECT TOP 3 
		st.StockItemName,
		st.UnitPrice,
		s.PostalCityID,
		(SELECT TOP 1 p.FullName
			FROM  [Sales].[InvoiceLines] il
			LEFT JOIN [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
			LEFT JOIN [Application].[People] p on p.PersonID=i.PackedByPersonID
			WHERE il.StockItemID=st.StockItemID
			ORDER BY StockItemID
		) [EmploeePacked]
	FROM [Warehouse].[StockItems] st
	LEFT JOIN  [Purchasing].[Suppliers] s on s.SupplierID=st.SupplierID
	ORDER BY UnitPrice DESC
)
SELECT DISTINCT
	c.CityID, c.CityName, [EmploeePacked]
FROM [Application].[Cities] c
JOIN TopProd on TopProd.PostalCityID=c.CityID





--SELECT DISTINCT PackedByPersonID, StockItemID
--FROM  [Sales].[InvoiceLines] il
--LEFT JOIN [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
--ORDER BY StockItemID

--SELECT TOP 3
--	--StockItemID,
--	--Description,
--	Description, 
--	st.SupplierID,
--	PackedByPersonID,
--	MAX(il.UnitPrice) as [Max]

--FROM  [Sales].[InvoiceLines] il
--LEFT JOIN [Sales].[Invoices] i on i.InvoiceID=il.InvoiceID
--LEFT JOIN  [Warehouse].[StockItems] st on il.StockItemID=st.StockItemID
--GROUP BY 
--	Description, 
--	st.SupplierID,
--	PackedByPersonID
--ORDER BY [Max] DESC

--SELECT DISTINCT
--	c.CityID, c.CityName, (SELECT TOP 1 p.FullName FROM [Application].[People] p WHERE p.PersonID=i.PackedByPersonID )
--FROM [Application].[Cities] c
--LEFT JOIN [Purchasing].[Suppliers] s on PostalCityID=c.CityID
--LEFT JOIN [Purchasing].[SupplierTransactions] st on st.SupplierID=s.SupplierID
--LEFT JOIN [Sales].[Invoices] i on i.OrderID=st.PurchaseOrderID
--JOIN (
--		SELECT TOP 3
--			st.StockItemID,	
--			st.StockItemName, 
--			st.SupplierID,
--			--p.FullName,
--			MAX(ol.UnitPrice) as [MaxPrice]
--		FROM  [Sales].[InvoiceLines] ol
--		LEFT JOIN  [Warehouse].[StockItems] st on ol.StockItemID=st.StockItemID
--		--LEFT JOIN [Sales].[Invoices] i on ol.OrderID=i.OrderID
--		--LEFT JOIN [Application].[People] p on p.PersonID=i.PackedByPersonID

--		GROUP BY 
--					st.StockItemID,	
--					st.StockItemName, 
--					st.SupplierID
--					--p.FullName
--		ORDER BY [MaxPrice] DESC
--	) tab on tab.SupplierID=s.SupplierID


--SELECT * FROM INFORMATION_SCHEMA.COLUMNS
--WHERE COLUMN_NAME LIKE '%PackedByPersonID%'

--SELECT TOP 100 * FROM [Sales].[OrderLines] ORDER BY UnitPrice DESC
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID,  --- ид продажи
	Invoices.InvoiceDate,  -- дата продажи
	(SELECT People.FullName   
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName, ------  Выводим имя клиента
	SalesTotals.TotalSumm AS TotalSummByInvoice,   --- Выручка с продаж
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems  --- Сумма заказов
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID ---- расчсет выруки с продаж более 27000 у.е.
ORDER BY TotalSumm DESC

-- --

TODO: 
--------- Запрос выводит данные по клиентам которые заплатили более 27000 у.е. и их сумму заказа, в разрезе  счёта, даты реализации и клиента 
--////////////////////////////////////////////////////////
--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/set-statistics-io-transact-sql?view=sql-server-ver15
SET STATISTICS IO, TIME ON

--SELECT TOP 100 * FROM Sales.InvoiceLines
--SELECT TOP 100 * FROM Sales.Invoices


----
------------ ИСХОДНЫЙ КОД ЗАПРОСА -------------
SELECT 
	Invoices.InvoiceID,  --- ид продажи
	Invoices.InvoiceDate,  -- дата продажи
	(SELECT People.FullName   
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName, ------  Выводим имя клиента
	SalesTotals.TotalSumm AS TotalSummByInvoice,   --- Выручка с продаж
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems  --- Сумма заказов
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID ---- расчсет выруки с продаж более 27000 у.е.
ORDER BY TotalSumm DESC


------- ОПТИМИЗАЦИЯ -----------
;WITH
SalesPersonNameTab as (
	SELECT 
		People.PersonID,
		People.FullName as [SalesPersonName]
	FROM Application.People
		--WHERE People.PersonID = Invoices.SalespersonPersonID
),
TotalSummForPickedItemsTab as (
	SELECT 
		OrderLines.OrderId,
		SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as [TotalSummForPickedItems]
	FROM Sales.OrderLines
	WHERE EXISTS (
		SELECT Orders.OrderId 
		FROM Sales.Orders
		WHERE Orders.PickingCompletedWhen IS NOT NULL	
			AND OrderLines.OrderId= Orders.OrderId
			--AND Orders.OrderId = Invoices.OrderId
		)
	GROUP BY 
		OrderLines.OrderId
),   --- Сумма заказов
SalesTotals as (
	SELECT 
		InvoiceId,
		SUM(Quantity*UnitPrice) AS TotalSummByInvoice
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000 
		--ON Invoices.InvoiceID = SalesTotals.InvoiceID ---- расчсет выруки с продаж более 27000 у.е.
)

SELECT  
	Invoices.InvoiceID,  --- ид продажи
	Invoices.InvoiceDate,  -- дата продажи
	People.SalesPersonName, ------  Выводим имя клиента
	SalesTotals.TotalSummByInvoice,   --- Выручка с продаж
	Orders.TotalSummForPickedItems  --- Сумма заказов
FROM Sales.Invoices
JOIN SalesTotals on SalesTotals.InvoiceID =  Invoices.InvoiceID 
LEFT JOIN TotalSummForPickedItemsTab Orders on Orders.OrderId = Invoices.OrderId
LEFT JOIN SalesPersonNameTab People on People.PersonID = Invoices.SalespersonPersonID
ORDER BY TotalSummByInvoice DESC



--При анализе статистики результаты запроса  одинаковые, кроме показателей Время ЦП и затраченное время
--	Так у исходного запроса - Время ЦП = 1018 мс, затраченное время = 111 мс.
--	У Оптимизированного запроа - Время ЦП = 403 мс, затраченное время = 109 мс.
-- Оптимизированный запрос показад реультат лучше
-- Было изменено улсловие в подзапросе  TotalSummForPickedItemsTab с = на EXISTS что ускорило проверку на соответствие и добавлена группировка при агрегации
-- Так же и использована констукция CTE для удобства чтения кода

---/---/----/--/---/ Статистика /----/------/-----/

------ ИСХОДНЫЙ КОД -----
--(затронуто строк: 8)
--Таблица "OrderLines". Число просмотров 96, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 326, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "InvoiceLines". Число просмотров 96, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 322, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 49, логических чтений 725, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 49, логических чтений 11994, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "People". Число просмотров 10, логических чтений 28, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

------ ОПТИМИЗИРОВАННЫЙ КОД -----
-- Время работы SQL Server:
--   Время ЦП = 1018 мс, затраченное время = 111 мс.

--(затронуто строк: 8)
--Таблица "OrderLines". Число просмотров 96, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 326, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "InvoiceLines". Число просмотров 96, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 322, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 49, логических чтений 725, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Invoices". Число просмотров 49, логических чтений 11994, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "People". Число просмотров 10, логических чтений 28, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "Worktable". Число просмотров 0, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 403 мс, затраченное время = 109 мс.

--Время выполнения: 2021-04-14T10:53:11.5379889+07:00




------- Сравнение  TotalSummForPickedItemsTab -------------
	SELECT 
		OrderLines.OrderId,
		SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as [TotalSummForPickedItems]
	FROM Sales.OrderLines
	WHERE OrderLines.OrderId in (
		SELECT Orders.OrderId 
		FROM Sales.Orders
		WHERE Orders.PickingCompletedWhen IS NOT NULL	
			--AND Orders.OrderId = Invoices.OrderId
		)
	GROUP BY 
		OrderLines.OrderId

	SELECT 
		OrderLines.OrderId,
		SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as [TotalSummForPickedItems]
	FROM Sales.OrderLines
	WHERE EXISTS (
		SELECT Orders.OrderId 
		FROM Sales.Orders
		WHERE Orders.PickingCompletedWhen IS NOT NULL	
			AND OrderLines.OrderId= Orders.OrderId
			--AND Orders.OrderId = Invoices.OrderId
		)
	GROUP BY 
		OrderLines.OrderId


--(затронуто строк: 70510)
--Таблица "OrderLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 163, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 1, логических чтений 692, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 141 мс, затраченное время = 1402 мс.

--(затронуто строк: 70510)
--Таблица "OrderLines". Число просмотров 2, логических чтений 0, физических чтений 0, упреждающих чтений 0, lob логических чтений 163, lob физических чтений 0, lob упреждающих чтений 0.
--Таблица "OrderLines". Считано сегментов 1, пропущено 0.
--Таблица "Orders". Число просмотров 1, логических чтений 692, физических чтений 0, упреждающих чтений 0, lob логических чтений 0, lob физических чтений 0, lob упреждающих чтений 0.

-- Время работы SQL Server:
--   Время ЦП = 93 мс, затраченное время = 1443 мс.

--Время выполнения: 2021-04-14T10:40:23.3199451+07:00