/*

Creating Tables for Tableau

*/

SELECT *
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]

----------------------------------------------------------------------------------------------------------------------------------------------------

--Table 1: Types of Land Use & if it was Sold as Vacant

SELECT LandUse, SoldAsVacant, COUNT(*) AS NumberOfProperties
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
WHERE LandUse IS NOT NULL
GROUP BY LandUse, SoldAsVacant
ORDER BY 1, 2 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Table 2: City where Homeowners Reside VS Where Properties Located

----Owners - Create Table Owners
	SELECT DISTINCT(OwnerCity), OwnerState, COUNT(OwnerCity) AmountOfProperties
	FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	--WHERE OwnerCity IS NOT NULL
	GROUP BY OwnerCity, OwnerState

--Note that 30,403 properties have an unknown owner address. No nulles showed up in the code above, so I inserted an unknown row.

	INSERT INTO [Nashville Housing Project]..[Owners] (OwnerCity, OwnerState, AmountOfProperties)
	VALUES ('Unknown', 'Unknown', 30403);


----Properties - Create Table Properties
	SELECT DISTINCT(PropertyCity), COUNT(PropertyCity) AmountOfProperties
	FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	WHERE PropertyCity != ' UNKNOWN'
	GROUP BY PropertyCity
	ORDER BY 2 DESC;


SELECT OwnerCity AS City, OwnerState AS 'State', o.AmountOfProperties AS OwnerResidence, COALESCE(p.AmountOfProperties, 0) AS PropertyLocation 
FROM [Nashville Housing Project]..[Owners] o
LEFT JOIN [Nashville Housing Project]..[Properties] p
ON OwnerCity = PropertyCity

----------------------------------------------------------------------------------------------------------------------------------------------------

--Table 3: Average sale based on the year the house was built

SELECT DISTINCT YearBuilt, AVG(CAST(SalePrice AS bigint)) AS AvgSalePrice
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
WHERE YearBuilt IS NOT NULL
GROUP BY YearBuilt
ORDER BY 1 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Table 4: Properties based on their number of owners

WITH OwnerCountCTE AS(
	SELECT DISTINCT(OwnerCount) AS OwnersPerProperty, COUNT(OwnerCount) AS OC
	FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	WHERE OwnerCount IS NOT NULL
	GROUP BY OwnerCount
	)

SELECT OwnersPerProperty, 
		OC AS PropertyCount, 
		(SELECT SUM(OC) FROM OwnerCountCTE) AS TotalPropertyCount,
		CAST((OC*1.)/(SELECT SUM(OC) FROM OwnerCountCTE) * 100 AS DECIMAL(10,2)) AS Percentage
FROM OwnerCountCTE
GROUP BY OwnersPerProperty, OC
ORDER BY 1;
