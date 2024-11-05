--cleaning data in file

select * from PortfolioProject..NashvilleHousing

--standardize date column
SELECT *, convert(date, SaleDate) as ConvertedSaleDate from PortfolioProject..NashvilleHousing;

Alter Table NashvilleHousing
Add SaleDateNew Date;

update NashvilleHousing
set SaleDateNew=convert(date,SaleDate)

--populate property address data
select * from PortfolioProject..NashvilleHousing 
--where PropertyAddress is null
order by ParcelID

select * from 
PortfolioProject..NashvilleHousing a
join 
PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--updating adress to remove null
update a
set PropertyAddress = isnull(a.PropertyAddress, b.propertyAddress)
from PortfolioProject..NashvilleHousing a
join 
PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--seperating address into region,state, etc
select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing 
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select * from PortfolioProject..NashvilleHousing


--simple alternative
select 
PARSENAME(replace(OwnerAddress,',','.'),1) as state,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),2) as place
from PortfolioProject..NashvilleHousing


--change y and n to yes or no in 'sold as vacant' field
select DISTINCT SoldAsVacant from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = 
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	End

--remove duplicates using row_number

with rowNumCTE as (
select *,
ROW_NUMBER() over(
partition by 
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num 
from PortfolioProject..NashvilleHousing
)

select * from rowNumCTE where row_num>1;

--delete unused columns
select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing drop column Acreage;