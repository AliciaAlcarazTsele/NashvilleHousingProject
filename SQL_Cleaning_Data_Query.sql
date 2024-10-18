/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning];

----------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data
	--UniquelID's with the same ParcellID's have the same PropertyAddress
	--Populate the null PropertyAddress's which have the same ParcelID

UPDATE N1
SET PropertyAddress = ISNULL(N1.PropertyAddress, N2.PropertyAddress)
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning] N1
JOIN [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning] N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.UniqueID <> N2.UniqueID
WHERE N1.PropertyAddress IS NULL;

--Check if there are any more nulls
SELECT * 
FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
WHERE PropertyAddress IS NULL;
	
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Break out Address into Individual Columns (Address, City, State) 

	-- PropertyAdderess

	ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	ADD PropertySplitAddress NVARCHAR(225);

		UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
		SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1); 
	
	ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	ADD PropertyCity NVARCHAR(225);

		UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
		SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress));

	-- OwnerAddress

	ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	ADD OwnerSplitAddress NVARCHAR(225);

		UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
		SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

	ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	ADD OwnerState NVARCHAR(225);

		UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
		SET OwnerState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

	ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	ADD OwnerCity NVARCHAR(225);

		UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
		SET OwnerCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);
 
 ----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and N in "Sold as Vacant" field

	-- The results in the code belwo show that "Sold as Vacant" field has Y, Yes, N, and No. We want them all to be in one form.

	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	GROUP BY SoldAsVacant
	ORDER BY 2;


	-- After running the code below, the code above will show that there are no Y/N data anymore b/c they have been turned into Yes/No.

	UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							 WHEN SoldAsVacant = 'N' THEN 'No'
							 ELSE SoldAsVacant
							 END;

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (although this is not common to do, it's still good to know how to)

	-- Create new table with column counting how many dublicates there are of ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference (1 meaning there are no dublicates and 2 meaning there is one duplicate).
	
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
	FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
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
		FROM [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
	) 


	SELECT *
	FROM RowNumCTE
	WHERE row_num > 1;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unsused Columns: TaxDistrict, OwnerAddress, PropertyAddress, PropertyCity (although this is not common to delete columns, it's still good to know how to)

ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
DROP COLUMN TaxDistrict;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--BELOW UPDATES WHERE NOT DIRECTED BY VIDEO--
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

--Add a column with the number of owners the property has

ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
ADD OwnerCount INT;

UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
SET OwnerCount = LEN(OwnerName) - LEN(REPLACE(OwnerName, '&', '')) +1;

----------------------------------------------------------------------------------------------------------------------------------------------------

--Alter Sale Price from money to integer

ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
ALTER COLUMN SalePrice INT;

--Drop off the ".00" of ParcelID 

UPDATE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
SET ParcelID = PARSENAME(ParcelID, 2);

--Round Acreage to the 100th decimal point
ALTER TABLE [Nashville Housing Project]..[Nashville_Housing_Data_Cleaning]
ALTER COLUMN Acreage DECIMAL(10, 2);


