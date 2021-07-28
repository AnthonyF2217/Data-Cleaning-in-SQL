/*
Cleaning data in SQL queries

Skills used: Select, From, Where, Group By, Order By, Joins, Alias, 
			 Alter table, Alter column, Update, Set, IsNull, Substring, Len, Charindex, 
			 Parsename, Case, Windows functions, CTEs, Removing duplicates, Deleting unused columns
*/

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing

/* Standardizing date format */

SELECT SaleDate, CONVERT(Date, SaleDate) AS ConvertedSaleDate
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

/* Populating PropertyAddress data */

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS ThisAddressWillBeUsed
FROM PortfolioProject2.dbo.NashvilleHousing AS A
JOIN PortfolioProject2.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing AS A
JOIN PortfolioProject2.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID

/* Breaking PropertyAddress and OwnerAddress into individual columns (Address, City, State) */

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

/* Changing Y and N to "Yes" and "No" in the SoldAsVacant field */

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Y'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject2.dbo.NashvilleHousing

UPDATE PortfolioProject2.dbo.NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Y'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject2.dbo.NashvilleHousing

/* Removing Duplicates */

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS Row_Num
FROM PortfolioProject2.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1

/* Deleting unused columns */

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict