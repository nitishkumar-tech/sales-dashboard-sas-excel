
/* Step 1: Import the CSV data */
proc import datafile="E:\PROJECTS\sales_data.csv"
    out=sales_raw
    dbms=csv
    replace;
    getnames=yes;
run;

/* Step 2: Clean and compute Revenue */
data sales_clean;
    set sales_raw;
    Revenue = Units_Sold * Unit_Price;
    format Revenue dollar12.2;
run;

/* Step 3: Create summary by Region and Product */
proc sql;
    create table sales_summary as
    select Region, Product,
           sum(Units_Sold) as Total_Units,
           sum(Revenue) as Total_Revenue
    from sales_clean
    group by Region, Product;
quit;

/* Step 4: Export summary to Excel */
proc export data=sales_summary
    outfile="E:\PROJECTS\sales_summary.xlsx"
    dbms=xlsx
    replace;
run;
