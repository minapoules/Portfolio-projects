/*
Cleaning Data in SQL Queries
*/

SELECT *
  FROM [PortfolioProject].[dbo].[nashvillehousing]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out the propertyaddress to be Address, city 
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) AS address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) city

FROM [PortfolioProject].[dbo].[nashvillehousing]

ALTER 
	TABLE [PortfolioProject].[dbo].[nashvillehousing] ADD propertysplitaddress varchar(255)

UPDATE
	[PortfolioProject].[dbo].[nashvillehousing] SET 
	propertysplitaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

ALTER	
	TABLE [PortfolioProject].[dbo].[nashvillehousing] ADD propertysplitcity varchar(255)

UPDATE
	[PortfolioProject].[dbo].[nashvillehousing] SET
	propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------

-- Break out the owneraddress to address, city and state
SELECT
	owneraddress, PARSENAME(REPLACE(owneraddress, ',', '.'), 3) ownersplitaddress,
	PARSENAME(REPLACE(owneraddress, ',', '.'), 2) ownersplitcity,
	PARSENAME(REPLACE(owneraddress, ',', '.'), 1)ownersplitstate
FROM
	[PortfolioProject].[dbo].[nashvillehousing]

ALTER	
	TABLE [PortfolioProject].[dbo].[nashvillehousing] ADD ownersplitaddress varchar(255)

UPDATE
	[PortfolioProject].[dbo].[nashvillehousing] SET
	ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER	
	TABLE [PortfolioProject].[dbo].[nashvillehousing] ADD ownersplitcity varchar(30)

UPDATE
	[PortfolioProject].[dbo].[nashvillehousing] SET
	ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2) 

ALTER	
	TABLE [PortfolioProject].[dbo].[nashvillehousing] ADD ownersplitstate varchar(10)

UPDATE
	[PortfolioProject].[dbo].[nashvillehousing] SET
	ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Turn Y and N to Yes and No in SoldAsVacant column
SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(soldasvacant)
FROM 
	[PortfolioProject].[dbo].[nashvillehousing]
GROUP BY
	SoldAsVacant
ORDER BY 
	2

SELECT SoldAsVacant,
	CASE
		WHEN soldasvacant = 'Y' THEN 'YES'
		WHEN soldasvacant = 'N' THEN 'No' 
		ELSE soldasvacant
		END
FROM	
	[PortfolioProject].[dbo].[nashvillehousing]

UPDATE 
	[PortfolioProject].[dbo].[nashvillehousing] SET
	SoldAsVacant = CASE
					WHEN soldasvacant = 'Y' THEN 'YES'
					WHEN soldasvacant = 'N' THEN 'No' 
					ELSE soldasvacant
					END

--------------------------------------------------------------------------------------------------------------------------

--Remove duplicates 
WITH rownumCTE AS(SELECT *,
	ROW_NUMBER() OVER 
					(PARTITION BY
						parcelid,
						propertyaddress,
						saledate,
						saleprice,
						legalreference,
						ownername
						ORDER BY uniqueid) rownum
FROM	
	PortfolioProject.dbo.nashvillehousing
)
SELECT -- DELETE the duplicates rows
	*
FROM
	rownumCTE
WHERE
	rownum > 1

--------------------------------------------------------------------------------------------------------------------------

-- Remove unused columns
SELECT
	*
FROM
	PortfolioProject.dbo.nashvillehousing

ALTER TABLE PortfolioProject.dbo.nashvillehousing 
DROP COLUMN propertyaddress, owneraddress, taxdistrict