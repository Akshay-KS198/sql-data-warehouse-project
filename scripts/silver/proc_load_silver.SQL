/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    - This stored procedure loads data into the 'silver' schema from by performing ETL (Extract, Transform, Load) process 
      from 'bronze' layer.
    It performs the following actions
    - Truncates the silver tables before loading data.
    - Inserts transformed and cleansed data from Bronze into Silver Tables

  Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

  Usage:
  EXEC silver.load_silver;
===============================================================================
*/

CREATE or Alter Procedure silver.load_silver As
Begin
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_silver DATETIME, @end_time_silver DATETIME
	Begin Try
	SET @start_time_silver = GETDATE()
		PRINT '***************************************************************************'
		PRINT 'Loading Silver Layer'
		PRINT '***************************************************************************'

		PRINT '***************************************************************************';
		PRINT 'Loading CRM Tables';
		PRINT '***************************************************************************';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT '>> Inserting Data: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_maritial_status,
			cst_gndr,
			cst_create_date
		)

		Select
		cst_id,
		cst_key,
		Trim(cst_firstname) cst_firstname,
		Trim(cst_lastname) cst_lastname,
			Case
				When UPPER(TRIM(cst_maritial_status)) = 'S' Then 'Single'
				When UPPER(TRIM(cst_maritial_status)) = 'M' Then 'Married'
				ELSE 'n/a'
			END cst_maritial_status,
			Case
				When UPPER(TRIM(cst_gndr)) = 'M' Then 'Male'
				When UPPER(TRIM(cst_gndr)) = 'F' Then 'Female'
				ELSE 'n/a'
			END cst_gndr,
		cst_create_date
		from (
		Select
			*,
			ROW_Number() Over(Partition by cst_id Order by cst_create_date DESC) as Flag_Last
		FROM
			bronze.crm_cust_info
		) t
		where Flag_Last = 1
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info
		PRINT '>> Inserting Data: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
		)

		Select
			prd_id,
			Replace(Substring(prd_key, 1, 5), '-','_') as cat_id,
			Substring(prd_key, 7, LEN(prd_key)) as prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			Case UPPER(TRIM(prd_line))
				When 'M' Then 'Mountain'
				When 'R' Then 'Road'
				When 'S' Then 'Other Sales'
				When 'T' Then 'Touring'
				ELSE 'n/a'
			END prd_line,
			CAST(prd_start_dt AS DATE) as prd_start_date,
			CAST(LEAD(prd_start_dt) OVER(Partition By prd_key ORDER BY prd_start_dt) - 1 AS DATE) as prd_end_dt
		From
			bronze.crm_prd_info
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details
		PRINT '>> Inserting Data: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
  			sls_ord_num,          
  			sls_prd_key,         
  			sls_cust_id,         
  			sls_order_dt,        
  			sls_ship_dt,        
  			sls_due_dt,         
  			sls_sales,          
  			sls_quantity,         
  			sls_price
		)

		Select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
				CASE
					WHEN sls_order_dt <=0 OR Len(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS nvarchar) as DATE)
					END sls_order_dt,
				CASE
					WHEN sls_ship_dt <=0 OR Len(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS nvarchar) as DATE)
					END sls_ship_dt,
				CASE
					WHEN sls_due_dt <=0 OR Len(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS nvarchar) as DATE)
					END sls_due_dt,
				CASE
					WHEN sls_sales <=0 OR sls_sales is NULL OR sls_sales != sls_quantity * ABS(sls_price)
						THEN sls_quantity * ABS(sls_price)
					Else sls_sales
					END sls_sales,
					sls_quantity,
					CASE
					WHEN sls_price <=0 OR sls_price is NULL 
						THEN  ABS(sls_sales)/NULLIF(sls_quantity, 0)
					Else sls_price
					END sls_price
		From bronze.crm_sales_details
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT '>> Inserting Data: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)

		Select
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, Len(cid))
				Else cid
			END cid,
			CASE
				When bdate > GETDATE() THEN NULL
				ELSE bdate
				END bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('M', 'Male') Then 'Male'
				When UPPER(TRIM(gen)) IN ('F', 'Female') Then 'Female'
				Else 'n/a'
				End gen
		From bronze.erp_cust_az12
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_loc_az101';
		TRUNCATE TABLE silver.erp_loc_az101
		PRINT '>> Inserting Data: silver.erp_loc_az101';
		Insert Into silver.erp_loc_az101 (
				cid,
				cntry
		)
		Select
		Replace(cid, '-', '') as cid,
			CASE WHEN TRIM(cntry) = 'DE' Then 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') Then 'United States'
				 WHEN TRIM(cntry) = '' or cntry is NULL Then 'n/a'
			ELSE TRIM(cntry)
		End cntry
		from
		bronze.erp_loc_az101
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data: silver.erp_px_cat_g1v2';
		Insert Into silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)

		Select
			id,
			cat,
			subcat,
			maintenance
		From
			bronze.erp_px_cat_g1v2
			SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

			SET @end_time_silver = GETDATE()
		PRINT 'Load duration for silver layer in seconds ' + Cast(Datediff(second,@start_time_silver,@end_time_silver) as NVARCHAR)
	END TRY
	BEGIN CATCH
		PRINT '-----------------------------------------';
		PRINT 'Error Occured in Loading Silver Layer';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Code' + Cast(ERROR_NUMBER() as NVARCHAR);
		PRINT '-----------------------------------------';
	END CATCH
END

