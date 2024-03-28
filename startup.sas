**************************************;
* CASL Course Autoexec Setup File    *;
**************************************;
* Set the path to the main course CASL folder. Works for Viya for Learners and Lab *;
%let homedir=%sysget(HOME);
%let path=/gelcontent/refactorcode;
/*%include "&path/data/setup.sas";*/


* Create a connection to the CAS server *;
cas conn sessopts=(caslib="casuser" 
                   timeout=14400 
                   messagelevel="DEFAULT"/*"ALL"*/ 
                   metrics=FALSE);

* Check to see if the cs caslib exists. If not, create the cs caslib *;
proc cas;
   table.queryCaslib result=r / caslib="cs";
   if r.cs=FALSE then do;
      table.addCaslib /
         caslib="cs"
         path="&path/data/cas"
      ;
   end;
   sessionProp.setSessOpt / caslib="casuser";
quit;



* Set a libref to reference the casuser and cs caslibs *;
libname cs cas caslib="cs" sessref="conn";
libname casuser cas caslib="casuser" sessref="conn";
