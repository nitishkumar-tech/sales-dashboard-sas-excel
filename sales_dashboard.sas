
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
/* Set output folder path */
%let outpath = E:\PROJECTS\sales_data.csv;

/* Step 4: Dashboard Overview - Total Revenue by Region */
ods graphics / reset=all imagename="dashboard_overview" imagefmt=png;
ods listing gpath="&outpath";

proc sgplot data=sales_summary;
    title "Dashboard Overview: Total Revenue by Region";
    vbar Region / response=Total_Revenue datalabel datalabelpos=inside;
    yaxis label="Total Revenue" grid;
run;

/* Step 5: Bar Chart - Total Revenue by Product */
ods graphics / reset=all imagename="bar_chart" imagefmt=png;

proc sgplot data=sales_summary;
    title "Bar Chart: Total Revenue by Product";
    vbar Product / response=Total_Revenue datalabel datalabelpos=inside;
    yaxis label="Total Revenue" grid;
run;

/* Step: Pivot Table Heatmap (Region vs Product) */
proc sql;
    create table heatmap_data as
    select Region,
           Product,
           Total_Revenue,
           case
              when Region = 'North' then 1
              when Region = 'South' then 2
              when Region = 'East'  then 3
              when Region = 'West'  then 4
              else .
           end as Region_Num,
           case
              when Product = 'TV' then 1
              when Product = 'Mobile' then 2
              else .
           end as Product_Num
    from sales_summary;
quit;

/* Define a custom format for Region and Product */
proc format;
    value regionfmt
        1 = "North"
        2 = "South"
        3 = "East"
        4 = "West";
    value productfmt
        1 = "TV"
        2 = "Mobile";
run;

ods graphics / reset=all imagename="pivot_table_heatmap" imagefmt=png;
ods listing gpath="&outpath";

proc sgplot data=heatmap_data noautolegend;
    title "Pivot Table: Revenue Heatmap (Region vs Product)";
    heatmapparm x=Product_Num y=Region_Num colorresponse=Total_Revenue / 
        colormodel=twocolorramp outline;

    xaxis values=(1 2) display=(nolabel) valueattrs=(size=10) valueformat=productfmt.;
    yaxis values=(1 2 3 4) reverse display=(nolabel) valueattrs=(size=10) valueformat=regionfmt.;
run;

ods listing close;

