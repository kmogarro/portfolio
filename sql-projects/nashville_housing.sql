/*

Using SQL to clean Nashville housing sales data 
from Jan 2013 to Oct 2016 (and two dates in 2019)

*/

SELECT * FROM nashville_housing.dbo.HousingData

---------------------------------------------------------------------

-- Standardizing "Sale Date" format
SELECT
	SaleDate,
	CONVERT(Date, Saledate)
FROM nashville_housing.dbo.HousingData

UPDATE nashville_housing.dbo.HousingData
SET SaleDate = CONVERT(Date, Saledate)

ALTER TABLE nashville_housing.dbo.HousingData
ADD SaleDateConverted Date;

UPDATE nashville_housing.dbo.HousingData
SET SaleDateConverted = CONVERT(Date, Saledate)

---------------------------------------------------------------------

-- Populate "Property Address" data
SELECT *
FROM nashville_housing..HousingData
--where PropertyAddress is null
ORDER BY ParcelID

SELECT
	t1.ParcelID,
	t1.PropertyAddress,
	t2.ParcelID,
	t2.PropertyAddress,
	ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM nashville_housing..HousingData t1
JOIN nashville_housing..HousingData t2
	ON t1.ParcelID=t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress is null

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM nashville_housing..HousingData t1
JOIN nashville_housing..HousingData t2
	ON t1.ParcelID=t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress is null

---------------------------------------------------------------------

--Breaking up Address into individual columns (street address, city, state)
SELECT
	PropertyAddress
FROM nashville_housing.dbo.HousingData

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM nashville_housing.dbo.HousingData

ALTER TABLE nashville_housing.dbo.HousingData
ADD StreetAddress NVARCHAR(255);

UPDATE nashville_housing.dbo.HousingData
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE nashville_housing.dbo.HousingData
ADD City NVARCHAR(255);

UPDATE nashville_housing.dbo.HousingData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM nashville_housing.dbo.HousingData

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville_housing..HousingData

ALTER TABLE nashville_housing.dbo.HousingData
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashville_housing.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville_housing.dbo.HousingData
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashville_housing.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville_housing.dbo.HousingData
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville_housing.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field so all results are consistent
SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM nashville_housing.dbo.HousingData

UPDATE nashville_housing.dbo.HousingData
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

---------------------------------------------------------------------

--Removing duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num

FROM nashville_housing.dbo.HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------

-- Deleting unused columns

SELECT *
FROM nashville_housing.dbo.HousingData

ALTER TABLE nashville_housing.dbo.HousingData
DROP COLUMN SaleDate

