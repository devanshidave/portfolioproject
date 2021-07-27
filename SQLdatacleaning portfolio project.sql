/*
Cleaning Data in SQL Queries
*/

select *
from portfolioproject.dbo.NashvilleHousing

-- standardize date format

select SaleDate,CONVERT(date,SaleDate)
FROM portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate= CONVERT(date,SaleDate)

-- Alternate method

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate property address data

select propertyaddress 
from portfolioproject.dbo.NashvilleHousing
where PropertyAddress is NULL

-- to check where it is null 
select *
from portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

-- As we can see in above query there are lot of similar parcel id with the same address we can fix that by 
-- populating parcel id with property address(using self join)(ISNULL constraint)

select a.ParcelID,a.PropertyAddress,b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b ON 
a.ParcelID= b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b ON 
a.ParcelID= b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL

-- Breaking out address into individual columns (address, city, state)

select PropertyAddress
from portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is NULL


-- we are using substring to seperate commas and break address into different columns
select 
substring(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) as Address
from portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD propertysplitaddress nvarchar(255);

UPDATE NashvilleHousing
SET propertysplitaddress = substring(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD propertysplitcity nvarchar(255);

UPDATE NashvilleHousing
SET propertysplitaddress = substring(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress))

select *
from portfolioproject.dbo.NashvilleHousing


-- Let's break owner address into individual columns

select owneraddress
from portfolioproject.dbo.NashvilleHousing

-- we can use parsename function instead of substring to break into different columns it is much easier
-- parsing works backwards so we have to change numbers to 3,2,1 instead of sequence 1,2,3
select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from portfolioproject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD ownersplitaddress nvarchar(255);

UPDATE NashvilleHousing
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD ownersplitcity nvarchar(255);

UPDATE NashvilleHousing
SET ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD ownersplitstate nvarchar(255);

UPDATE NashvilleHousing
SET ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

select *
from portfolioproject.dbo.NashvilleHousing


-- change Y and N to yes and no in soldASvacant column

select DISTINCT(SoldAsVacant)
from portfolioproject.dbo.NashvilleHousing


select DISTINCT(SoldAsVacant), count(SoldASVacant)
from portfolioproject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- we will use case statement to change y and n into yes and no

select SoldAsVacant,
CASE when SoldAsVacant= 'y' Then 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


	 UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant= 'y' Then 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
-- REMOVING DUPLICATES using CTE and Windows function


WITH RowNumCTE as (
select *,
Row_number() over(
          Partition by ParcelID,
		               propertyaddress,
					   saleprice,
					   saledate,
					   legalreference
					   order by 
					     uniqueID
						 ) row_num
from portfolioproject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1 
order by PropertyAddress

-- we can delete this 104 rows using delete function

WITH RowNumCTE as (
select *,
Row_number() over(
          Partition by ParcelID,
		               propertyaddress,
					   saleprice,
					   saledate,
					   legalreference
					   order by 
					     uniqueID
						 ) row_num
from portfolioproject.dbo.NashvilleHousing
--order by ParcelID
)
--delete
select *
from RowNumCTE
where row_num >1 
--order by PropertyAddress


-- Delete unused columns 



select *
from portfolioproject.dbo.NashvilleHousing

ALTER TABLE portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


