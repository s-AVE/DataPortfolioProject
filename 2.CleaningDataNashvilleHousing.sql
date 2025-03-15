
--Cleaning Data in SQL Queries

Select *
From
	PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------

-- Standarize Date Format
Select SaleDateC, CONVERT(Date, SaleDate)
From
	PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateC date;

Update NashvilleHousing
Set SaleDateC = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data
Select *
From
	PortfolioProject..NashvilleHousing
Order by ParcelID



Select 
	a.ParcelID
	,a.PropertyAddress
	,b.ParcelID
	,b.PropertyAddress
	,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
	Join
		PortfolioProject..NashvilleHousing as b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
	SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
	Join
		PortfolioProject..NashvilleHousing as b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


-- Checking table
Select *
From
	PortfolioProject..NashvilleHousing
Order by ParcelID


--------------------------------------------------------------------------------------------------------------------
-- Breaking out Property Address into Individual Columns (Address, City, State)
Select PropertyAddress
From
	PortfolioProject..NashvilleHousing
Order by ParcelID


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City

FROM PortfolioProject..NashvilleHousing


-- Update and Create new Colomn for Property Address
ALTER TABLE NashvilleHousing
Add PropSplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Update and Create new Colomn for City
ALTER TABLE NashvilleHousing
Add PropCity Nvarchar(255);

Update NashvilleHousing
Set PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select *
From
	PortfolioProject..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------
-- Breaking out Owner Address into Individual Columns (Address, City, State)
Select 
	OwnerAddress
From
	PortfolioProject..NashvilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as OwnerAddressSplit
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as OwnerCity
	,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as OwnerCountry
From 
	PortfolioProject..NashvilleHousing

 
 -- Update and Create new Colomn for Owner Address
ALTER TABLE NashvilleHousing
Add 
	OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

-- Update and Create new Colomn for City
ALTER TABLE NashvilleHousing
Add 
	OwnerCity Nvarchar(255);

Update NashvilleHousing
Set 
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

-- Update and Create new Colomn for State
ALTER TABLE NashvilleHousing
Add 
	OwnerState Nvarchar(255);

Update NashvilleHousing
Set 
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- Or using this to simplify the update of new colomns
/* 
ALTER TABLE NashvilleHousing
Add
	OwnerSplittAddress Nvarchar(255)
	,OwnerCity Nvarchar(255)
	,OwnerState Nvarchar(255);

Update NashvilleHousing
Set
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
	,OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
	,OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

*/

Select *
From
	PortfolioProject..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------
-- Change Y to Yes and N to No in Colom "SoldAsVacant
Select 
	Distinct(SoldAsVacant)
From
	PortfolioProject..NashvilleHousing


Select 
	SoldAsVacant
	,Case 
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From
	PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set
	SoldAsVacant = Case 
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From
	PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates Data
WITH RowNumCTE AS
(
Select *
	,ROW_NUMBER() OVER (
		PARTITION BY ParcelID
					,PropertyAddress
					,SalePrice
					,SaleDate
					,LegalReference
					ORDER BY
						UniqueID
					) as RowNum
From
	PortfolioProject..NashvilleHousing
)


Select *
From
	RowNumCTE
Where
	RowNum > 1
Order By
	PropertyAddress

/*--Delete the duplicates
DELETE
From
	RowNumCTE
Where
	RowNum > 1
*/


-- Delete Unused Colomns

Select *
From
	PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN
	OwnerAddress
	,TaxDistrict
	,PropertyAddress
	,SaleDate
