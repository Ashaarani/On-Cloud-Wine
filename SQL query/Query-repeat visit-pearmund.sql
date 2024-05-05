CREATE TABLE filtered_sales_data_Pearmund AS
SELECT 
    BillLastName,
    BillFirstName,
    AccountCreationDate,
    OrderDate,
    CustomerNumber
FROM 
    sales_master_jan_feb_pearmund
WHERE 
    CustomerClass = 'PC Wine Club';


-- Update the sales table to remove duplicates
CREATE TABLE temp_sales AS
SELECT DISTINCT * FROM filtered_sales_data_Pearmund;
-- Drop the original sales table
DROP TABLE filtered_sales_data_Pearmund;
-- Rename the temporary table to sales
ALTER TABLE temp_sales RENAME TO filtered_sales_data_Pearmund;

DELETE FROM filtered_sales_data_Pearmund WHERE AccountCreationDate = '0';


-- Update the member table to remove duplicates
CREATE TABLE temp_member AS
SELECT DISTINCT * FROM pearmund_wineclubmember_startdates_actual;
-- Drop the original member table
DROP TABLE pearmund_wineclubmember_startdates_actual;
-- Rename the temporary table to member
ALTER TABLE temp_member RENAME TO pearmund_wineclubmember_startdates_actual;


UPDATE filtered_sales_data_Pearmund fsd
JOIN pearmund_wineclubmember_startdates_actual ws
ON fsd.BillLastName = ws.BillLastName AND fsd.BillFirstName = ws.BillFirstName
SET fsd.AccountCreationDate = ws.AccountCreationDate;


-- Remove the time part from the OrderDate column
UPDATE filtered_sales_data_Pearmund
SET OrderDate = DATE(OrderDate);

-- Remove duplicates from the filtered_sales_data table
CREATE TABLE filtered_sales_data_temp AS
SELECT DISTINCT * FROM filtered_sales_data_Pearmund;
-- Drop the original filtered_sales_data table
DROP TABLE filtered_sales_data_Pearmund;
-- Rename the temporary table to filtered_sales_data
ALTER TABLE filtered_sales_data_temp RENAME TO filtered_sales_data_Pearmund;

DELETE FROM filtered_sales_data_Pearmund
WHERE AccountCreationDate = OrderDate;


ALTER TABLE filtered_sales_data_Pearmund
ADD column OrderDateCount int,
ADD COLUMN AccountCreationDateCount INT,
ADD COLUMN NumberOfVisits INT;

UPDATE filtered_sales_data_Pearmund fsd
JOIN (
    SELECT 
        BillLastName, 
        BillFirstName, 
        COUNT(DISTINCT DATE(OrderDate)) AS OrderDateCount,
        COUNT(DISTINCT DATE(AccountCreationDate)) AS AccountCreationDateCount,
        COUNT(DISTINCT DATE(OrderDate)) + COUNT(DISTINCT DATE(AccountCreationDate)) AS NumberOfVisits
    FROM 
        filtered_sales_data_Pearmund
    GROUP BY 
        BillLastName, BillFirstName
) a ON fsd.BillLastName = a.BillLastName AND fsd.BillFirstName = a.BillFirstName
SET fsd.OrderDateCount = a.OrderDateCount,
    fsd.AccountCreationDateCount = a.AccountCreationDateCount,
    fsd.NumberOfVisits = a.NumberOfVisits;







