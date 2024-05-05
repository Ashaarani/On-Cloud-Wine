-- Remove specified words and trailing semicolons from the 'ProductGroup' column
UPDATE sales_master_jan_feb_pearmund
SET ProductGroup = REPLACE(REPLACE(ProductGroup, 'Favorites;', ''), 'Farmstore;', ''),
    ProductGroup = TRIM(TRAILING ';' FROM ProductGroup);
 
 
-- Add the SubCategory column to the sales_master_jan_feb_pearmund table
ALTER TABLE sales_master_jan_feb_pearmund ADD COLUMN SubCategory VARCHAR(50);
 
-- Now you can run the UPDATE statement to populate the SubCategory column
UPDATE sales_master_jan_feb_pearmund
SET SubCategory = CASE 
                        WHEN ProductTitle LIKE '%Wine Club $75%' THEN 'NonWine'
                        WHEN ProductType = 'wine' THEN 'Wine'
                        WHEN ProductType = 'PHYSICAL' AND ProductGroup LIKE '%Glass/Tasting%' THEN 'Wine'
                        WHEN ProductType = 'PHYSICAL' THEN 'NonWine'
                        ELSE 'Other'
                    END;
ALTER TABLE shopkeep.pearmundcellars_transaction_items_oneyeardata
CHANGE COLUMN `Time` `OrderDate` TIMESTAMP,
CHANGE COLUMN `Line Item` `ProductTitle` VARCHAR(100),
CHANGE COLUMN `SubCategory` `SubCategory` VARCHAR(100),
CHANGE COLUMN `Quantity` `ProductQty` DECIMAL(10,0),
CHANGE COLUMN `Subtotal` `ProductExtPrice` DECIMAL(10,0),
CHANGE COLUMN `Discounts` `ProductDiscount` DECIMAL(10,0);
 
ALTER TABLE shopkeep.pearmundcellars_transaction_items_oneyeardata
MODIFY COLUMN `OrderDate` TIMESTAMP,
MODIFY COLUMN `ProductTitle` VARCHAR(100),
MODIFY COLUMN `SubCategory` VARCHAR(100),
MODIFY COLUMN `ProductQty` DECIMAL(10,0),
MODIFY COLUMN `ProductExtPrice` DECIMAL(10,0),
MODIFY COLUMN `ProductDiscount` DECIMAL(10,0);
 
UPDATE shopkeep.pearmundcellars_transaction_items_oneyeardata
SET SubCategory = CASE 
                        WHEN SubCategory LIKE '%NonWine%'THEN 'NonWine'
                        WHEN SubCategory LIKE '%Wine%'THEN 'Wine'
                    END;
 
-- Combine data from both tables into a new table
CREATE TABLE IF NOT EXISTS combined_data_Pearmund AS
SELECT OrderDate, ProductTitle,SubCategory,ProductQty, ProductExtPrice, ProductDiscount
FROM (
    SELECT OrderDate, ProductTitle, SubCategory, ProductQty, ProductExtPrice, ProductDiscount
    FROM orderport.sales_master_jan_feb_pearmund
    UNION ALL
    SELECT OrderDate, ProductTitle, SubCategory, ProductQty, ProductExtPrice, ProductDiscount
    FROM shopkeep.pearmundcellars_transaction_items_oneyeardata
) AS combined;
 
UPDATE combined_data_Pearmund
SET ProductDiscount = ABS(ProductDiscount);