/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing


-----Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-----Populate Property Address data
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
INNER JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
INNER JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-----Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress));

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity  Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState  Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);


-----Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..NashvilleHousing


-----Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
		ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
WHERE row_num >1

DELETE
From RowNumCTE
WHERE row_num >1


-----Delete Unused Columns
SELECT * FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;