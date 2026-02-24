/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================
Description:
    This script creates the schema for the Silver layer (cleansed/standardized).
    It defines the tables for CRM and ERP source systems.
===============================================================================
*/

USE Datawarehouse;

-- Create Schema if it doesn't exist (MySQL/SQL Server syntax vary)
-- CREATE SCHEMA IF NOT EXISTS silver;
-- ----------------------------------------------------------------------------
-- 1. CRM Tables
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date NVARCHAR(50),
    dwh_create_date  DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	Cat_ID NVARCHAR(50),
    prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost DECIMAL(10, 2),
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
    );


DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	 sls_ord_num NVARCHAR(50),
	 sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales DECIMAL(10,2),
	sls_quantity INT,
	sls_price DECIMAL(10,2),
	dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 1. ERP Tables
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS silver.erp_CUST_AZ12;
CREATE TABLE silver.erp_CUST_AZ12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver.erp_LOC_A101;
CREATE TABLE silver.erp_LOC_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(100),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS silver.erp_px_CAT_G1V2;
CREATE TABLE silver.erp_px_CAT_G1V2(
	ID nvarchar(50),
    CAT nvarchar(100),
    SUBCAT nvarchar(100),	
    MAINTENANCE nvarchar(5),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
