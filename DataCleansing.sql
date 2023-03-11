/*
Cleaning Data with SQL Queries On NashvileHousing Table
*/
select * from PortfolioProject..NashvileHousing
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------

/* Standardize Date Format */
ALTER TABLE PortfolioProject..NashvileHousing
ALTER COLUMN SaleDate DATE;
GO

-----------------------------------------------------------------------------------------------------------
/* Populate PropertyAddress Data*/ 
UPDATE [dbo].[NashvileHousing]
SET PropertyAddress = OwnerAddress
WHERE OwnerAddress IS NOT NULL;
GO
-----------------------------------------------------------------------------------------------------------
-- Delete NonUseful Columns From Table
ALTER TABLE NashvileHousing
DROP COLUMN owneraddress;
GO
-----------------------------------------------------------------------------------------------------------
--Breaking out address into individual Columns(Address, City & State)
ALTER TABLE [dbo].[NashvileHousing]
ADD PropertyCity nvarchar(100);
GO
ALTER TABLE [dbo].[NashvileHousing]
ADD PropertyState nvarchar(100);
GO

UPDATE [dbo].[NashvileHousing]
	SET PropertyAddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)
UPDATE [dbo].[NashvileHousing]
	SET PropertyCity = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))
