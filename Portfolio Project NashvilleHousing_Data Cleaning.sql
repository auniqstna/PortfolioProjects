/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------



--Standardize Date Format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-----------------------------------------------------------------------------------



--Populate Property Address

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS null
order by ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
FROM PortfolioProject.dbo.NashvilleHousing AS a
	JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
	JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



-----------------------------------------------------------------------------------



--Breaking out address into Address, City and, State

--1) For PropertyAddress
SELECT 
	SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS PropertyCity
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD Address NVARCHAR(255) 

UPDATE PortfolioProject.dbo.NashvilleHousing
SET Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyCity NVARCHAR(255) 

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--2) For OwnerAddress
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressStreet NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerAddressCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerAddressState NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-----------------------------------------------------------------------------------



--Set 'Yes' for 'Y' and 'NO' for 'N' in SoldAsVacant Column

SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant


SELECT SoldAsVacant,
	CASE SoldAsVacant 
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE SoldAsVacant 
					WHEN 'Y' THEN 'Yes'
					WHEN 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END	
				   


-----------------------------------------------------------------------------------



--Removing Duplicates
WITH RowNumCTE AS(
SELECT
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference
					   ORDER BY UniqueID) AS RowNum,
	ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
FROM NashvilleHousing
)
--DELETE
--From RowNumCTE
--WHERE RowNum <>1
SELECT *
From RowNumCTE
WHERE RowNum <>1



-----------------------------------------------------------------------------------




--Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate



-----------------------------------------------------------------------------------



