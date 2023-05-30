--View Our Data to make sure that it was imported properly
SELECT *
FROM NashvilleHousing

-- Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate) AS SaleDateConverted
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--

--Populate Property Address data

--Identify NULL Values 
SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL 

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
ORDER BY PARCELID

--Self Join
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress 
FROM Portfolio_Project.dbo.NashvilleHousing A
	JOIN Portfolio_Project.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL 


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM Portfolio_Project.dbo.NashvilleHousing A
	JOIN Portfolio_Project.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL 


--Update Statement to Change missing Property Address from A.PropertyAddress and replaces it with values in B.PropertyAddress, Gets rid of the Nulls we saw above
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing A
	JOIN Portfolio_Project.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL 



--Breaking Out Address into Individual COlumns (Address, City, State)


Select PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
--ORDER BY PARCELID


--Using substring and character index

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing


--Property Adress Split

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

	--Checking our Work 
SELECT PropertySplitCity,  PropertySplitAddress
FROM NashvilleHousing

--Checking the Owner Address
SELECT OwnerAddress
FROM NashvilleHousing

--Alter Owner Address , OPTION A - Split  using substring
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1 , LEN(OwnerAddress)) 

	--Checking our Work 
SELECT OwnerSplitCity,  OwnerSplitAddress
FROM NashvilleHousing

 
--Adding State with PARSE
SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1) 

--CHECK
SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
FROM NashvilleHousing; 

--Cleaning Data, [Sold As Vacant] 

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2; 

--Convert Y N to 'Yes' and 'No' using a CASE Statement

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Removing Duplicates 

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
				) Row_Num
FROM NashvilleHousing)

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1 
ORDER BY PropertyAddress


--DELETION 
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
				) Row_Num
FROM NashvilleHousing)

DELETE
FROM RowNumCTE 
WHERE Row_Num > 1  

--CHECK for Duplicates After Deletion 

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
				) Row_Num
FROM NashvilleHousing)
SELECT *
FROM RowNumCTE 
WHERE Row_Num > 1  


--Delete Unused Columns

Select *
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE 
Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
ALTER TABLE 
Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate
