***********************************************;
* Macro to create a table of a specified size *;
***********************************************;
%macro makeData(dsn,numrows,nthreads);
%local size;
%if &numrows <=1000 %then %let size=Tiny; 
  %else %if &numrows <=500000 %then %let size=Small; 
  %else %let size=Large; 

data casuser.&size&dsn(label="&size data for testing");
    call streaminit(12345);
    do i=1 to &numrows*&nthreads;  
        x=rand('uniform');
        if x<.10 then Product="A";
            else if x<.30 then Product="B";
            else if x<.60 then Product="C";
            else Product="D"; 
        Quantity=abs(round(rand('normal',100,20)));
        output;
    end;
    drop x i;
run;
%mend;

***********************************************;
* End macro                                   *;
***********************************************;

%makeData(Table,6000000,16);

proc cas;
    tbl={name="largetable", caslib="casuser"};
    table.tableInfo / caslib=tbl.caslib, name=tbl.name;
    table.fetch / 
       table=tbl,
       index=FALSE;
quit;