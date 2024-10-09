/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM [Nashville Housing Project]..[Nashville Housing]

----------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data
	--UniquelID's with the same ParcellID's have the same PropertyAddress
	--Populate the null PropertyAddress's which have the same ParcelID

UPDATE N1
SET PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress)
FROM [Nashville Housing Project]..[Nashville Housing] N1
JOIN [Nashville Housing Project]..[Nashville Housing] N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.UniqueID <> N2.UniqueID
WHERE N1.PropertyAddress IS NULL

--Check if there are any more nulls
SELECT * 
FROM [Nashville Housing Project]..[Nashville Housing]
WHERE PropertyAddress IS NULL
	


----------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State) 

--PropertyAdderess

	--SELECT UniqueID, 
	--		PropertyAddress, 
	--		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) AS Address,
	--		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS City
	--FROM [Nashville Housing Project]..[Nashville Housing]

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD PropertySplitAddress NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) 

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD PropertySplitCity NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

--OwnerAddress

	--SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
	--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	--FROM [Nashville Housing Project]..[Nashville Housing]

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerSplitState NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerSplitCity NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and N in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing Project]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

	-- The results show that "Sold as Vacant" field has Y, Yes, N, and No. We want them all to be in one form.
	-- After running the code below, the code above will show that there are no Y/N data anymore b/c they have been turned into Yes/No.
 
UPDATE [Nashville Housing Project]..[Nashville Housing]
SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates (although this is not common to do, it's still good to know how to)

	--Create new table with column counting how many dublicates there are of ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference (1 meaning there are no dublicates and 2 meaning there is one duplicate).
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	ORDER BY UniqueID
		) row_num
FROM [Nashville Housing Project]..[Nashville Housing]
)
	--DELETE the duplicates 
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Check if there are any more duplicates. The code below should have no results. (Same code as above but replace DELETE with SELECT *)

WITH RowNumCTE AS(
	SELECT *, 
		ROW_NUMBER() OVER (
			PARTITION BY ParcelID, 
						 PropertyAddress,
						 SalePrice,
						 SaleDate,
						 LegalReference
			ORDER BY UniqueID
		) row_num
	FROM [Nashville Housing Project]..[Nashville Housing]
) 


SELECT *
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unsused Columns: TaxDistrict, OwnerAddress, PropertyAddress, PropertyCity

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
DROP COLUMN TaxDistrict, OwnerAddress, PropertyAddress, PropertyCity;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--BELOW UPDATES WHERE NOT DIRECTED BY VIDEO--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

--Change column names so that they no longer say 'Split'

--Property Address
	--Create new column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD PropertyAddress NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET PropertyAddress = PropertySplitAddress;

	--Delete old column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
DROP COLUMN PropertySplitAddress;

--Owner Address
	--Create new column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerAddress NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerAddress = OwnerSplitAddress;

	--Delete old column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
DROP COLUMN OwnerSplitAddress;

--Owner City
	--Create new column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerCity NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerCity = OwnerSplitCity;

	--Delete old column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
DROP COLUMN OwnerSplitCity;

--Owner State
	--Create new column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerState NVARCHAR(225);

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerState = OwnerSplitState;

	--Delete old column
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
DROP COLUMN OwnerSplitState;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Add a column with the number of owners the property has

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ADD OwnerCount INT

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET OwnerCount = LEN(OwnerName) - LEN(REPLACE(OwnerName, '&', '')) +1;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Alter Sale Price from decimal to integer

ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ALTER COLUMN SalePrice INT;

--Drop off the ".00" of ParcelID 

UPDATE [Nashville Housing Project]..[Nashville Housing]
SET ParcelID = PARSENAME(ParcelID, 2);

--Round Acreage to the 100th decimal point
ALTER TABLE [Nashville Housing Project]..[Nashville Housing]
ALTER COLUMN Acreage DECIMAL(10, 2);



