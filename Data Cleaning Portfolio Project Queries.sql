/*

Cleaning Data in SQL Queries

*/
Select *
From [PortofolioProject2]..NashvilleHousing


-----------------------------------------------------------------------------------

--Standardize Date Format


Select SaleDateConverted, CONVERT(date,SaleDate)
From PortofolioProject2..NashvilleHousing

Update PortofolioProject2..NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter table PortofolioProject2..NashvilleHousing
Add SaleDateConverted date;

Update PortofolioProject2..NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)


-----------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From PortofolioProject2..NashvilleHousing
--WHEre PropertyAddress is null 
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject2..NashvilleHousing a
JOIN PortofolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHere a.PropertyAddress is null 

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortofolioProject2..NashvilleHousing a
JOIN PortofolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHere a.PropertyAddress is null 


-------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortofolioProject2..NashvilleHousing
--WHEre PropertyAddress is null 
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) Address

From PortofolioProject2..NashvilleHousing

Alter table PortofolioProject2..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortofolioProject2..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table PortofolioProject2..NashvilleHousing
Add PropertSplitCity nvarchar(255);

Update PortofolioProject2..NashvilleHousing
Set PropertSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))




Select 
Parsename(Replace(OwnerAddress,',','.') ,3),
Parsename(Replace(OwnerAddress,',','.') ,2),
Parsename(Replace(OwnerAddress,',','.') ,1)
From PortofolioProject2..NashvilleHousing

Alter table PortofolioProject2..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortofolioProject2..NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.') ,3)

Alter table PortofolioProject2..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortofolioProject2..NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.') ,2)

Alter table PortofolioProject2..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortofolioProject2..NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.') ,1)






Select *
From PortofolioProject2..NashvilleHousing

-------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortofolioProject2..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASe	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From PortofolioProject2..NashvilleHousing


Update PortofolioProject2..NashvilleHousing
Set SoldAsVacant = CASe	
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End



--------------------------------------------------------------------------------------

-- Remove Duplicates


With RowNumCTE AS (
Select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
						UniqueID
						) row_num


From PortofolioProject2..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1


---------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From PortofolioProject2..NashvilleHousing

Alter Table PortofolioProject2..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortofolioProject2..NashvilleHousing
Drop Column SaleDate



