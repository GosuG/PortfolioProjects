/* Cleaning data in SQL Queries
*/
Select *
From dbo.NashvilleHousing


-- Standardize Date Format
Select saleDateConverted, CONVERT(Date,SaleDate )
From NashvilleProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select *
From NashvilleProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- ISNULL(a.PropertyAddress, b.PropertyAddress) Ahol PropertyAddress Null-nak felel meg azt kicserélem b.PropertyAddressre
-- ha akarnám akkor 'No Address' névre is elnevezhetném. This switch a.PropertyAddress to b.PropertyAdddres where value = null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a 
JOIN NashvilleProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
-- <> means not equal to !!
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleProject.dbo.NashvilleHousing a 
JOIN NashvilleProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns ( Address, City, State )

Select PropertyAddress
From NashvilleProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
--order by ParcelID


SELECT
-- Vessző eltüntetése a cím végén / removing comma at the end
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashvilleProject.dbo.NashvilleHousing

-- Creating new columns with Alter Table and Add functions
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
-- For unknown reason I have to write the whole project name and table name to avoid errors
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From NashvilleProject.dbo.NashvilleHousing




Select OwnerAddress
From NashvilleProject.dbo.NashvilleHousing

-- Easier to separate the column values like this with PARSENAME function
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) as City
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) as State
From NashvilleProject.dbo.NashvilleHousing




ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

-- For unknown reason I have to write the whole project name and table name to avoid errors

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From NashvilleProject.dbo.NashvilleHousing


-- SUBSTITUTE

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as 'number of possibilites'
From NashvilleProject.dbo.NashvilleHousing
-- It doesn t work without Group by
Group by SoldAsVacant
order by 'number of possibilites'

-- Change Y and N to Yes and No in " Sold As Vacant " Column 
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From NashvilleProject.dbo.NashvilleHousing

Update NashvilleProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates ( writing a CTE )
WITH RowNumCTE AS(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num

From NashvilleProject.dbo.NashvilleHousing
)
-- We could check the code with Select all and order by propertyAddress while commenting delete, we would get zero data from it
DELETE
--Select *
From RowNumCTE
Where row_num > 1 
--Order by PropertyAddress


-- Delete Unused Columns

Select *
From NashvilleProject.dbo.NashvilleHousing

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN SaleDate