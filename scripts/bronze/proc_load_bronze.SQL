/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    - This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions
    - Truncates the bronze tables before loading data.
    - Uses the 'Bulk INSERT' command to load data from csv files to bronze tables

  Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

  Usage:
  EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_bronze DATETIME, @end_time_bronze DATETIME
	BEGIN TRY
		SET @start_time_bronze = GETDATE()
		PRINT '***************************************************************************'
		PRINT 'Loading Bronze Layer'
		PRINT '***************************************************************************'

		PRINT '***************************************************************************';
		PRINT 'Loading CRM Tables';
		PRINT '***************************************************************************';

		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Bulk Inserting the table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR) 


		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.crm_prod_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Bulk Inserting the table: bronze.crm_prod_info';
		BULK INSERT bronze.crm_prd_info
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR) 


		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Bulk Inserting the table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR) 

		PRINT '***************************************************************************';
		PRINT 'Loading ERP Tables';
		PRINT '***************************************************************************';

		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Bulk Inserting the table: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR)

		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.erp_loc_az101';
		TRUNCATE TABLE bronze.erp_loc_az101;
		PRINT '>> Bulk Inserting the table: bronze.erp_loc_az101'
		BULK INSERT bronze.erp_loc_az101
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR) 


		SET @start_time = GETDATE()
		PRINT '>> Truncating the table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Bulk Inserting the table: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM '(--File Location in the device)'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time,@end_time) as NVARCHAR) 

		SET @end_time_bronze = GETDATE()
		PRINT 'Load duration in seconds ' + Cast(Datediff(second,@start_time_bronze,@end_time_bronze) as NVARCHAR)
	END TRY
	BEGIN CATCH
		PRINT '-----------------------------------------';
		PRINT 'Error Occured in Loading Bronze Layer';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Code' + Cast(ERROR_NUMBER() as NVARCHAR);
		PRINT '-----------------------------------------';
	END CATCH
END
