/*
===============================================================================
Data Warehouse Transformation Script: Gold Layer (Star Schema)
===============================================================================
Description:
    This script performs the final transformation of data from the 'Silver' 
    (cleansed) layer into the 'Gold' layer (business-ready). It creates views for the gold layer in the data warehouse.  
    
    The script implements a Star Schema design:
    - Dimensions: gold.dim_customers, gold.dim_products
    - Facts: gold.fact_sales

Data Model: Star Schema
*/
-- =============================================================================
-- 1. DATA QUALITY CHECKS (Audit Phase)
-- =============================================================================

-- Identify duplicate customer records across multiple source systems
-- to ensure unique granularity in the Customer Dimension.
SELECT COUNT(*) AS FLAG FROM 
	(SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.BDATE,
		ca.GEN,
		la.CNTRY
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON		  ci.cst_key = ca.CID
	LEFT JOIN silver.erp_loc_a101 la
	ON		  ci.cst_key = la.CID
) AS SUBQUERY 
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Data integration test: Harmonizing Gender column across sources
-- Consolidates 'n/a' values from CRM with ERP data.
SELECT distinct
	ci.cst_gndr,
	ca.GEN,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE coalesce(ca.GEN, 'n/a')
    END AS New_Gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.CID;

-- =============================================================================
-- 2. DIMENSION TABLES (Gold Layer)
-- =============================================================================
-- Create Customer Dimension: Joins CRM, ERP, and Location data.

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER( ORDER BY ci.cst_id) AS Customer_key, -- Generating the surrogate key for the Star Schema
	ci.cst_id AS Customer_ID,
	ci.cst_key AS Customer_Number,
	ci.cst_firstname AS First_Name,
	ci.cst_lastname AS Last_Name,
    la.CNTRY AS Country,
	ci.cst_marital_status AS Marital_Status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE coalesce(ca.GEN, 'n/a')
    END AS Gender,
	ca.BDATE AS Birth_date,
    ci.cst_create_date AS Create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.CID;

-- Create Product Dimension: Joins Product info with Category/Subcategory hierarchy.

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER( ORDER BY pn.prd_start_dt, pn.prd_key) AS Product_key, -- Surrogate key for joining with Fact tables
	pn.prd_id AS Product_ID,
	pn.prd_key AS Product_Number,
	pn.prd_nm AS Product_Name,
    pn.Cat_ID AS Category_ID,
	pc.CAT AS Category, 
	pc.SUBCAT AS Sub_category,
	pc.MAINTENANCE AS Maintenance,
	pn.prd_cost AS Cost,
	pn.prd_line AS Product_Line,
	pn.prd_start_dt AS Start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 PC
ON 		   pn.Cat_ID = pc.ID;
-- =============================================================================
-- 3. FACT TABLES (Gold Layer)
-- =============================================================================

-- Create Sales Fact: Integrates sales details with surrogate keys from dimensions.
CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS Order_number, 
    pr.Product_key AS Product_key,
	cu.Customer_key AS Customer_Key,  
	sd.sls_order_dt AS Order_date, 
	sd.sls_ship_dt AS Shipment_date, 
	sd.sls_due_dt AS Due_date, 
	sd.sls_quantity AS Quantity, 
	sd.sls_price AS Price,
    sd.sls_sales AS Sales
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON 		  sd.sls_prd_key = pr.Product_Number
LEFT JOIN gold.dim_customers cu
ON 		   cu.Customer_ID = sd.sls_cust_id;
