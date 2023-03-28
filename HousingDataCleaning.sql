/*
Data Cleaning
*/
Select *
  From NashvilleHousing


--------------------------------------------------------------------


-- Standardize date format
Select SaleDate, Convert(Date, SaleDate)
  From NashvilleHousing

Update NashvilleHousing
  Set SaleDate = Convert(Date, SaleDate)

--------------------------------------------------------------------

-- Populate property address data

Select *
  From NashvilleHousing
-- Where PropertyAddress Is Null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IsNull(a.PropertyAddress, b.PropertyAddress)
  From NashvilleHousing a 
  Join NashvilleHousing b 
    On a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
Where a.PropertyAddress Is Null

Update a
  Set PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
  From NashvilleHousing a 
  Join NashvilleHousing b 
    On a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
  Where a.PropertyAddress Is Null

--------------------------------------------------------------------

--  Putting address into individual comlumns (address, city, state)

Select PropertyAddress
  From NashvilleHousing

Select
  Substring (PropertyAddress, 1, CharIndex(',', PropertyAddress) -1) As Address,
  Substring (PropertyAddress, CharIndex(',', PropertyAddress) +1, Len(PropertyAddress)) As Address 
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress NvarChar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, CharIndex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity NvarChar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, CharIndex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
  From NashvilleHousing


Select 
  ParseName(Replace(OwnerAddress, ',', '.'), 3) As OwnerSplitAddress,
  ParseName(Replace(OwnerAddress, ',', '.'), 2) As OwnerSpltCity,
  ParseName(Replace(OwnerAddress, ',', '.'), 1) As OwnerSplitState
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress NvarChar(255)

Alter Table NashvilleHousing
Add OwnerSplitState NvarChar(255)

Alter Table NashvilleHousing
Add OwnerSpltCity NvarChar(255)

Update NashvilleHousing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSpltCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------

-- Change Y and N to Yes and No "Sold as Vacant" column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
  From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
  Case 
    When SoldAsVacant = 'N' Then 'No'
    When SoldAsVacant = 'Y' Then 'Yes'
    Else SoldAsVacant
  End 
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
  Case 
    When SoldAsVacant = 'N' Then 'No'
    When SoldAsVacant = 'Y' Then 'Yes'
    Else SoldAsVacant
  End

--------------------------------------------------------------------

-- Remove duplicates
With RowNumCTE As (
  Select *,
    Row_Number() Over(
      Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      Order By UniqueID 
    ) row_num 
  From NashvilleHousing 
)
-- Delete 
--   From RowNumCTE
-- Where row_num > 1

Select * 
  From RowNumCTE
Where row_num > 1
Order By PropertyAddress

--------------------------------------------------------------------

-- Remove unused columns
Select *
  From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate