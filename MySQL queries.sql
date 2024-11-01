#1. Top 5 Brands by Receipts Scanned Among Users 21 and Over
#Assumption:Receipts scanned corresponds to unique RECEIPT_ID entries in the Transactions table
SELECT p.BRAND, COUNT(DISTINCT t.RECEIPT_ID) AS receipt_count
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE u.AGE >= 21
GROUP BY p.BRAND
ORDER BY receipt_count DESC
LIMIT 5;



#2. Top 5 Brands by Sales Among Users with Accounts for at Least Six Months
#Assumption: The “account duration” is based on the difference between the CREATED_DATE in Users and today's date.
SELECT p.BRAND, SUM(t.FINAL_SALE) AS total_sales
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE DATEDIFF(CURDATE(), u.CREATED_DATE) >= 180  -- Accounts active for at least six months
GROUP BY p.BRAND
ORDER BY total_sales DESC
LIMIT 5;

#3. What is the percentage of sales in the Health & Wellness category by generation?
SELECT 
       CASE 
           WHEN AGE BETWEEN 9 AND 24 THEN 'Gen Z'
           WHEN AGE BETWEEN 25 AND 40 THEN 'Millennials'
           WHEN AGE BETWEEN 41 AND 56 THEN 'Gen X'
           WHEN AGE BETWEEN 57 AND 75 THEN 'Baby Boomers'
           WHEN AGE > 75 THEN 'Silent Generation'
       END AS generation,
       SUM(CASE WHEN p.CATEGORY_1 = 'Health & Wellness' THEN t.FINAL_SALE ELSE 0 END) / SUM(t.FINAL_SALE) * 100 AS health_wellness_percentage
FROM Users u
JOIN Transactions t ON u.ID = t.USER_ID
JOIN Products p ON t.BARCODE = p.BARCODE
GROUP BY generation;

#-------------------------------------------------------------------------------------------------------------
#1. Who are Fetch’s Power Users
#Assumption: Power users are defined as those who scan receipts most frequently or have the highest total FINAL_SALE
SELECT u.ID, COUNT(DISTINCT t.RECEIPT_ID) AS receipt_count, SUM(t.FINAL_SALE) AS total_sales
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
GROUP BY u.ID
HAVING receipt_count > (SELECT AVG(receipt_count) FROM (SELECT USER_ID, COUNT(DISTINCT RECEIPT_ID) AS receipt_count FROM Transactions GROUP BY USER_ID) AS avg_receipts)
   OR total_sales > (SELECT AVG(total_sales) FROM (SELECT USER_ID, SUM(FINAL_SALE) AS total_sales FROM Transactions GROUP BY USER_ID) AS avg_sales)
ORDER BY total_sales DESC, receipt_count DESC;

#2. Which is the leading brand in the Dips & Salsa category?
#Assumption: The leading brand is defined by the highest number of receipts scanned or highest sales in the Dips & Salsa category.
SELECT p.BRAND, SUM(t.FINAL_SALE) AS total_sales
FROM Transactions t
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE p.CATEGORY_2 = 'Dips & Salsa'
GROUP BY p.BRAND
ORDER BY total_sales DESC
LIMIT 1;

