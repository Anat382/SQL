/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
*/

-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument  xml

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'E:\SQL_Developer\8 Выборки из XML и JSON полей\StockItems-188-f89807.xml',  SINGLE_CLOB) as data 

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument as [@xmlDocument]

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument

-- docHandle - это просто число
SELECT @docHandle as docHandle

-- можно вставить в таблицу
DROP TABLE IF EXISTS #StockItems

CREATE TABLE #StockItems(
	[StockItemName] nvarchar (100)  ,
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal,
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal,
	[UnitPrice] decimal
)

INSERT INTO #StockItems
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName]			nvarchar (100)  '@Name' ,
	[SupplierID]			int 'SupplierID',
	[UnitPackageID]			int 'Package/UnitPackageID',
	[OuterPackageID]		int 'Package/OuterPackageID',
	[QuantityPerOuter]		int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit]	decimal 'Package/TypicalWeightPerUnit',
	[LeadTimeDays]			int 'LeadTimeDays',
	[IsChillerStock]		bit 'IsChillerStock',
	[TaxRate]				decimal 'TaxRate',
	[UnitPrice]				decimal 'UnitPrice'
)

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle

--SELECT * FROM #StockItems

MERGE Warehouse.StockItems AS T_Base
	USING (
		SELECT 
			[StockItemName]			
			,[SupplierID]			
			,[UnitPackageID]			
			,[OuterPackageID]		
			,[QuantityPerOuter]		
			,[TypicalWeightPerUnit]	
			,[LeadTimeDays]			
			,[IsChillerStock]		
			,[TaxRate]				
			,[UnitPrice]				
		FROM #StockItems 
		) AS T_Source
		ON (T_Base.[StockItemName] = T_Source.[StockItemName]  COLLATE Cyrillic_General_CI_AS)
	WHEN MATCHED THEN
	UPDATE 
		SET T_Base.[SupplierID]				= 	T_Source.[SupplierID]			,
			T_Base.[UnitPackageID]			= 	T_Source.[UnitPackageID]		,
			T_Base.[OuterPackageID]			= 	T_Source.[OuterPackageID]		,
			T_Base.[QuantityPerOuter]		= 	T_Source.[QuantityPerOuter]		,
			T_Base.[TypicalWeightPerUnit]	= 	T_Source.[TypicalWeightPerUnit]	,
			T_Base.[LeadTimeDays]			= 	T_Source.[LeadTimeDays]			,
			T_Base.[IsChillerStock]			= 	T_Source.[IsChillerStock]		,
			T_Base.[TaxRate]				= 	T_Source.[TaxRate]				,
			T_Base.[UnitPrice]				= 	T_Source.[UnitPrice]				

	WHEN NOT MATCHED THEN
	INSERT (
		[StockItemName]			,
		[SupplierID]			,	
		[UnitPackageID]			,
		[OuterPackageID]		,	
		[QuantityPerOuter]		,
		[TypicalWeightPerUnit]	,
		[LeadTimeDays]			,
		[IsChillerStock]		,	
		[TaxRate]				,
		[UnitPrice]				,
		[LastEditedBy]
		)
	VALUES (
		T_Source.[StockItemName],
		T_Source.[SupplierID]			,
		T_Source.[UnitPackageID]		,
		T_Source.[OuterPackageID]		,
		T_Source.[QuantityPerOuter]		,
		T_Source.[TypicalWeightPerUnit]	,
		T_Source.[LeadTimeDays]			,
		T_Source.[IsChillerStock]		,
		T_Source.[TaxRate]				,
		T_Source.[UnitPrice]			,
		( SELECT MAX([LastEditedBy]) FROM  Warehouse.StockItems )
	)
	OUTPUT $action AS [Log],
		Inserted.*
		;		   
DROP TABLE IF EXISTS #StockItems
GO


--SELECT * FROM #StockItems
--use [tempdb]
--SELECT *
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME='#StockItems_________________________________________________________________________________________________________000000000009'

--SELECT * 
--FROM INFORMATION_SCHEMA.TABLES
	

--SELECT * FROM Warehouse.StockItems --227
--WHERE [StockItemName] IN(SELECT  [StockItemName] FROM #StockItems )

--SELECT COUNT(*) FROM Warehouse.StockItems --227

--SELECT COLUMN_NAME, IIF(CHARACTER_MAXIMUM_LENGTH > 0, CONCAT(DATA_TYPE,' (',CHARACTER_MAXIMUM_LENGTH,')'), DATA_TYPE) FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME='StockItems'
--	AND COLUMN_NAME IN('StockItemName', 'SupplierID', 'UnitPackageID', 'OuterPackageID', 'QuantityPerOuter', 'TypicalWeightPerUnit', 'LeadTimeDays', 'IsChillerStock', 'TaxRate', 'UnitPrice')
----ORDER BY COLUMN_NAME

--SELECT StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 
--FROM Warehouse.StockItems



/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/


SELECT
	[StockItemName]			as [@Name] ,
	[SupplierID]			as [SupplierID],
	[UnitPackageID]			as [Package/UnitPackageID],
	[OuterPackageID]		as [Package/OuterPackageID],
	[QuantityPerOuter]		as [Package/QuantityPerOuter],
	[TypicalWeightPerUnit]	as [Package/TypicalWeightPerUnit],
	[LeadTimeDays]			as [LeadTimeDays],
	[IsChillerStock]		as [IsChillerStock],
	[TaxRate]				as [TaxRate],
	[UnitPrice]				as [UnitPrice]
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems'), type


DECLARE @xmlDocument  xml

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'E:\SQL_Developer\8 Выборки из XML и JSON полей\StockItems-Write_HW.xml',  SINGLE_CLOB) as data 

SELECT @xmlDocument as [@xmlDocument]



/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/


SELECT 
	StockItemID,
	StockItemName,
	CustomFields,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	IIF( LEN( split.[FirstTag] ) > 1, 
		split.[FirstTag], NULL) as [FirstTag],
	JSON_VALUE(CustomFields, '$.Range') as [Range]
FROM Warehouse.StockItems
CROSS APPLY(
	SELECT TOP 1 
		REPLACE( REPLACE( REPLACE(value,'[','') ,']','')  ,'"','') as [FirstTag]
	FROM
		STRING_SPLIT( JSON_QUERY(CustomFields, '$.Tags') , ',')
) split


/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT 
	StockItemID,
	StockItemName,
	CustomFields,
	JSON_QUERY(CustomFields, '$.Tags')  as [Tags]
FROM Warehouse.StockItems
CROSS APPLY(
	SELECT
		REPLACE( REPLACE( REPLACE(value,'[','') ,']','')  ,'"','') as [FirstTag]
	FROM
		STRING_SPLIT( JSON_QUERY(CustomFields, '$.Tags') , ',')
) split
WHERE split.[FirstTag] = 'Vintage'
GROUP BY 
	StockItemID,
	StockItemName,
	CustomFields