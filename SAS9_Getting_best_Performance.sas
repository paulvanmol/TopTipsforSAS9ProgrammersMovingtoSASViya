**************************************************************;
* Demo 6.07: Getting the Best Performance                    *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Create and preview the large table *;
%include "&path/data/create_large_table.sas";

* Turn on metrics for actions *;
proc cas;
    setSessOpt / metrics="TRUE";
quit;



**********************************************;
* SOLUTION 1 - PROC SQL on a CAS Table       *;
**********************************************;
* PROC SQL does not run in CAS. The entire table is sent back to compute *;
proc sql;
select Product, 
       sum(Quantity) as Total format=16.,
       min(Quantity) as Min,
       mean(Quantity) as Mean,
       max(Quantity) as Max
    from casuser.largetable
    group by Product;
quit;
*******************************************************************;
* ERROR: The maximum allowed bytes (104857600) of data have been  *;
*        fetched from Cloud Analytic Services. Use the DATALIMIT  *;
*        option to increase the maximum value.                    *;
*******************************************************************;



**********************************************;
* SOLUTION 2 - FedSQL                        *;
**********************************************;
proc cas;
    source sql;
        select Product,
               sum(Quantity) as Total,
               min(Quantity) as Min,
               mean(Quantity) as Mean,
               max(Quantity) as Max
        from casuser.largetable
        group by Product;
    endsource;

* Run SQL *;
    fedsql.execDirect / query=sql;
quit;
***************************************;
*     real time    28.635889 seconds  *;
*     cpu time     102.180631 seconds *;
***************************************;



**********************************************;
* SOLUTION 3 - PROC MEANS                    *;
**********************************************;
* The MEANS procedure is converted to the aggregate action behind the scenes *;
proc means data=casuser.largetable nonobs sum min mean max maxdec=5;
    var Quantity;
    class Product;
quit;
*************************************;
*     real time    29.95 seconds    *;
*     cpu time     multiple actions *;
*************************************;



**********************************************;
* SOLUTION 4 - PROC MDSUMMARY                *;
**********************************************;
*************************************************************************************;
* The MDSUMMARY procedure computes basic descriptive statistics for variables       *;
* across all observations or within groups of observations in parallel for data     *;
* tables stored in SAS Cloud Analytic Services (CAS). The MDSUMMARY procedure uses  *; 
* CAS tables and capabilities, ensuring full use of parallel processing.            *;
*************************************************************************************;
proc mdsummary data=casuser.largeTable;
    var Quantity;
    groupBy Product;
    output out=casuser.test;
run;

proc print data=casuser.test noobs;
    var Product _MIN_ _MAX_ _MEAN_ _SUM_; 
run;
***************************************;
*     real time    2.01 seconds       *;
*     cpu time     multiple actions   *;
***************************************;



**********************************************;
* SOLUTION 5 - simple.summary CAS Action     *;
**********************************************;
proc cas;
    outTbl={name="action",caslib="casuser"};

* Summary action *;
    simple.summary /
      table={caslib="casuser"
            ,name="largetable"
            ,groupBy={"Product"}},
      inputs={"Quantity"},
      subSet={"SUM", "MIN", "MEAN", "MAX"},
      casOut=outTbl || {replace=TRUE};

* Preview the table *;
    table.fetch / 
       table=outTbl,
       fetchVars={"Product","_Min_","_Mean_","_Max_","_Sum_"},
       index=false;
quit;
**************************************;
*     real time    1.793447 seconds  *;
*     cpu time     13.778714 seconds *;
**************************************;



**********;
* Step 2 *;
**********;
* Turn off metrics *;
proc cas;
    setSessOpt / metrics="FALSE";
quit;