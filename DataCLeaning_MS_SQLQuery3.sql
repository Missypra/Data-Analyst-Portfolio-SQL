/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
      [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Missy_Database].[dbo].[NashvilleHousing]
; 
-----------------------------------------------------------------------
/* 
Cleaning Data in SQL Queries
*/
select *
from NashvilleHousing
where ownerName is not null
;
-------------------------------------------------------------------------------
--Standarize Data Format

/*select saledate
,CONVERT(date,saledate)
from NashvilleHousing
;
----update NashvilleHousing
set saledate = CONVERT(date,saledate)  
*/
;
select saledate
,FORMAT(saledate,'MM-dd-yyyy')
from NashvilleHousing
;
alter table NashvilleHousing
add ConvertSaleDate Date
;
update NashvilleHousing
set ConvertSaleDate = FORMAT(saledate,'MM-dd-yyyy')
;
alter table NashvilleHousing
add Birthday Date
;
------------------------------------------------------------------------------
---Populate Property Address Data

select *  --- propertyaddress
from NashvilleHousing
---where propertyaddress is null
order by ParcelID
;
/*In this query, we will identfy the same ParcelID but missing the Property Address */

select t1.ParcelID as T1parcelID
,t1.PropertyAddress  as T1PropAddress
,t2.ParcelID
,t2.PropertyAddress
,isnull(t1.PropertyAddress, t2.PropertyAddress) ----if first colunm is Null, than use the properyt address from the 2nd column
from NashvilleHousing t1
join NashvilleHousing t2
on t1.ParcelID = t2.ParcelID
and t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is null
;

select *
from NashvilleHousing
where ParcelID = '025 07 0 031.00'
order by [UniqueID ]
;
select COUNT (*)
from NashvilleHousing

/* this the update to replace the property address where null is with an existing propertyaddresss */

update T1
set propertyaddress = isnull(t1.PropertyAddress, t2.PropertyAddress)
from NashvilleHousing t1
join NashvilleHousing t2
on t1.ParcelID = t2.ParcelID
and t1.[UniqueID ] <> t2.[UniqueID ]
where t1.PropertyAddress is null and t1.ParcelID = '025 07 0 031.00'
;

select *
from NashvilleHousing
where ParcelID = '025 07 0 031.00'
union 
select 
*
from NashvilleHousing
where ParcelID = '025 07 0 031.00'
;

SELECT 
      [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      
  FROM [Missy_Database].[dbo].[NashvilleHousing]
  where ParcelID = '025 07 0 031.00'

  union

  SELECT 
      [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
     
  FROM [Missy_Database].[dbo].[NashvilleHousing]
  where ParcelID = '025 07 0 031.00'
  ;

  SELECT distinct[UniqueID ]
  FROM [Missy_Database].[dbo].[NashvilleHousing]
  where ParcelID = '025 07 0 031.00'
  ;

  SELECT top (1)
       [ParcelID]
	  ,[UniqueID ]
      ,[LandUse]
      ,[PropertyAddress]
     
  FROM [Missy_Database].[dbo].[NashvilleHousing]
  where ParcelID = '025 07 0 031.00'
  order by ParcelID,[UniqueID ] desc

-------------------------------------------------------------------------------------------------------------------------------
  ;
/* let's use Row Number and partition by to identify duplicates */

With rankrows as (
select *
,ROW_NUMBER() over (partition by parcelid order by [UniqueID ] desc)  as RowRank
from NashvilleHousing)
select *
from rankrows
where RowRank = 1 and RowRank < 2 
;
-----------------------------------------------------------------------------------------------------------------------------------------
/* let's create a new dataset, name it NashvilleHousingNew and we will insert the above codes into it. 
To create a new datset right click on NashvilleHousing table > script table as > create to > new query editor window, click run */
--- now let's insert a data rankerows into NashvilleHousingNew

With rankrows as (
select *
,ROW_NUMBER() over (partition by parcelid order by [UniqueID ] desc)  as RowRank
from NashvilleHousing
) 

insert into NashvilleHousingNew (
 [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[ConvertSaleDate]
      ,[Birthday]
       
)
select 
 [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[ConvertSaleDate]
      ,[Birthday]
from rankrows
where RowRank = 1
; 
-----let's check it.
select *
from NashvilleHousingNew
where ParcelID = '025 07 0 031.00'
;
-----------------------------------------------------------------------------------------------------
/* Breaking out Address into Individual colunms (Address, City,State) */

select PropertyAddress
from NashvilleHousing

;

select SUBSTRING(propertyaddress,1, CHARINDEX(',', propertyaddress)-1) as Address
----,CHARINDEX(',', PropertyAddress) ----lenght of characters
,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+ 1, LEN(propertyaddress)) as City

from NashvilleHousing
;

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255)
;
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress,1, CHARINDEX(',', propertyaddress)-1)
;

alter table NashvilleHousing
add  Nvarchar(255)
;
update NashvilleHousing
set PropertyAddressCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+ 1, LEN(propertyaddress))
;
----let's query it

select *
from NashvilleHousing
where [UniqueID ] = 54390
;

select propertyaddress
,CHARINDEX (',', PropertyAddress)
,LegalReference
,SUBSTRING(LegalReference,1,CHARINDEX('-', LegalReference)-1)  AS SplitLegalReference
---,SUBSTRING(LegalReference,CHARINDEX('-', LegalReference)+1, len(legalReference))  as Split2positionLegalReference
,SUBSTRING(PropertyAddress,19,28)  AS SplitLegalReference
from NashvilleHousing
where [UniqueID ] = 54390

;

---Let split the OwnerAddress use keyword 'parsename'
select ParcelID 
,owneraddress
from NashvilleHousing
where owneraddress is not null
;

select 
parsename(replace(owneraddress, ',', '.'),3)  as Address
,parsename(replace(owneraddress, ',', '.'),2) as City
,parsename(replace(owneraddress, ',', '.'),1)  as State
from NashvilleHousing
where owneraddress is not null

----let's update Owner Address

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',', '.'),3)
;

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(owneraddress, ',', '.'),2)
;

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(owneraddress, ',', '.'),1)
;

---let's run it
select *
from NashvilleHousing
where ParcelID = '156 00 0 014.02'
;

---Change Y to N to Yes and No in 'Sold as Vacant' field

select distinct (soldasvacant)
,count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2
;

select SoldAsVacant
,Case when soldasvacant = 'Y' THEN 'Yes'
	 when soldasvacant = 'N' THEN 'No'
	 else soldasvacant
	 end
from NashvilleHousing
;

update NashvilleHousing
set SoldAsVacant = Case 
	 when soldasvacant = 'Y' THEN 'Yes'
	 when soldasvacant = 'N' THEN 'No'
	 else soldasvacant
	 end
;
----------------------------------------------------------------------
---- Let's look for duplicates

With RowNumCTE as (
select *
,ROW_NUMBER() Over (partition by parcelid
				                   ,propertyaddress
								   ,saleprice
								   ,saledate
								   ,[LegalReference]
								   Order by [UniqueID ]) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

;
/*To Remove duplicates.  The duplicates records is display as 2 in row_num column and we will delete them by using below codes.
best practice, we shoudl not remove duplicates since we're not the owner of the data.  this is just an example codes 
*/

With RowNumCTE as (
select *
,ROW_NUMBER() Over (partition by parcelid
				                   ,propertyaddress
								   ,saleprice
								   ,saledate
								   ,[LegalReference]
								   Order by [UniqueID ]) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1
;

------------------------------------------------------------------------------------------------------------------------
---Delete Unused Columns.  Best practice we should not delete Unused columns. 
select *
from NashvilleHousing

alter table NashvilleHousing
drop column birthday
,taxdistrict
,saledate
;

---the fast the way to empty data in the table is use truncate.  
--truncate table NashvilleHousing
--------------------------------------
select *
,max(saleprice) over (partition by taxdistrict) as Maxprice
from [dbo].[NashvilleHousing]