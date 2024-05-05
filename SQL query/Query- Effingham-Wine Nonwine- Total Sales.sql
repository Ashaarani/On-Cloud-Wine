-- Remove specified words and trailing semicolons from the 'ProductGroup' column
UPDATE salesmaster_jan_feb_effingham
SET ProductGroup = REPLACE(REPLACE(ProductGroup, 'Favorites;', ''), 'Farmstore;', ''),
    ProductGroup = TRIM(TRAILING ';' FROM ProductGroup);
 
 
-- Add the SubCategory column to the sales_master_jan_feb_pearmund table
ALTER TABLE salesmaster_jan_feb_effingham ADD COLUMN SubCategory VARCHAR(50);
 
-- Now you can run the UPDATE statement to populate the SubCategory column
UPDATE salesmaster_jan_feb_effingham
SET SubCategory = CASE 
                        WHEN ProductTitle LIKE '%Wine Club $75%' THEN 'NonWine'
                        WHEN ProductType = 'wine' THEN 'Wine'
                        WHEN ProductType = 'PHYSICAL' AND ProductGroup LIKE '%Glass/Tasting%' THEN 'Wine'
                        WHEN ProductType = 'PHYSICAL' THEN 'NonWine'
                        ELSE 'Other'
                    END;
ALTER TABLE shopkeep.effingham_transaction_items_oneyeardata
CHANGE COLUMN `Time` `OrderDate` TIMESTAMP,
CHANGE COLUMN `Line Item` `ProductTitle` VARCHAR(100),
CHANGE COLUMN `SubCategory` `SubCategory` VARCHAR(100),
CHANGE COLUMN `Quantity` `ProductQty` DECIMAL(10,0),
CHANGE COLUMN `Subtotal` `ProductExtPrice` DECIMAL(10,0),
CHANGE COLUMN `Discounts` `ProductDiscount` DECIMAL(10,0);
 
ALTER TABLE shopkeep.effingham_transaction_items_oneyeardata
MODIFY COLUMN `OrderDate` TIMESTAMP,
MODIFY COLUMN `ProductTitle` VARCHAR(100),
MODIFY COLUMN `SubCategory` VARCHAR(100),
MODIFY COLUMN `ProductQty` DECIMAL(10,0),
MODIFY COLUMN `ProductExtPrice` DECIMAL(10,0),
MODIFY COLUMN `ProductDiscount` DECIMAL(10,0);
 
UPDATE shopkeep.effingham_transaction_items_oneyeardata
SET SubCategory = CASE 
                        WHEN SubCategory LIKE '%NonWine%'THEN 'NonWine'
                        WHEN SubCategory LIKE '%Wine%'THEN 'Wine'
                    END;
 
 
-- Combine data from both tables into a new table
CREATE TABLE combined_data_Effingham AS
SELECT OrderDate, ProductTitle, SubCategory, ProductQty, ProductExtPrice, ProductDiscount
FROM (
    SELECT OrderDate, ProductTitle, SubCategory, ProductQty, ProductExtPrice, ProductDiscount
    FROM orderport.salesmaster_jan_feb_effingham
    UNION ALL
    SELECT OrderDate, ProductTitle, SubCategory, ProductQty, ProductExtPrice, ProductDiscount
    FROM shopkeep.effingham_transaction_items_oneyeardata
) AS combined;
 
UPDATE combined_data_Effingham
SET ProductDiscount = ABS(ProductDiscount);
 