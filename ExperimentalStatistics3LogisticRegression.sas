PROC IMPORT DATAFILE= "/folders/myfolders/Data/Wikipedia4HE.csv"
OUT= wikipedia
DBMS=csv
REPLACE;
GETNAMES=YES;
RUN;

/* descriptive statistics for the continuous variables */
proc means data=wikipedia n min mean median max std;
var AGE YEARSEXP;
Run;

/* descriptive statistics for the catagorical variables and crosstabulation with the response */
proc freq data=wikipedia;
tables GENDER DOMAIN PhD UNIVERSITY USERWIKI PU1_IND*GENDER 
PU1_IND*DOMAIN PU1_IND*PhD PU1_IND*UNIVERSITY PU1_IND*USERWIKI;
run;

/* Scatter Plot */
proc sgscatter data=wikipedia;
matrix AGE GENDER DOMAIN PhD YEARSEXP UNIVERSITY USERWIKI PU1_IND  / diagonal=(histogram);
run;

/* Square Root Transformation of Years of Experience */
data wikipedia1;
set wikipedia;
sqrtYEARSEXP = sqrt(YEARSEXP);
Run;

/* Scatter Plot */
proc sgscatter data=wikipedia1;
matrix AGE GENDER DOMAIN PhD sqrtYEARSEXP UNIVERSITY USERWIKI PU1_IND / diagonal=(histogram);
run;

/* Checking correlation for continous*/
proc corr data = wikipedia1;
var  AGE sqrtYEARSEXP;
run;

/* Checking correlation for catagory*/
proc freq data = wikipedia1;
  tables (GENDER DOMAIN PhD UNIVERSITY USERWIKI PU1_IND  )*(GENDER DOMAIN PhD UNIVERSITY USERWIKI PU1_IND) /plcorr;
  ods output measures=mycatcorr (where=(statistic="Tetrachoric Correlation"
                                     or statistic="Polychoric Correlation")
                              keep = statistic table value);
run;

proc print data=mycatcorr;
run;

data mycatcorrt;
  set mycatcorr ;
  group = floor((_n_ - 1)/6);
  x = scan(table, 2, " *");
  y = scan(table, 3, " *");
   keep group value table x y;
run;

proc print data = mycatcorrt;
run;

proc transpose data = mycatcorrt out=mymatrix (drop = _name_ group)   ;
   id x;
   by group;
   var value ;
run;

proc print data = mymatrix;
run;


/*Logistic Regression */
proc logistic data=wikipedia1 descending; 
class GENDER DOMAIN PhD UNIVERSITY USERWIKI /param=ref; 
model PU1_IND  = AGE GENDER DOMAIN PhD sqrtYEARSEXP UNIVERSITY USERWIKI/risklimits;
Run;

/*Automatic Selection Process */
proc logistic data=wikipedia1 plots=ALL descending ; 
class GENDER DOMAIN PhD UNIVERSITY USERWIKI/param=ref; 
model PU1_IND = AGE GENDER DOMAIN PhD sqrtYEARSEXP UNIVERSITY USERWIKI/CLODDS=pl selection=stepwise sle=0.05 sls=0.05;
run;

/*Logitsic Regression of selected variables only */
proc logistic data=wikipedia1 descending; 
class GENDER  USERWIKI DOMAIN /param=ref; 
model PU1_IND =  GENDER  USERWIKI DOMAIN/risklimits;
Run;

/*Logitic Regression for Interaction of selected variables */
proc logistic data=wikipedia1 descending; 
class GENDER USERWIKI DOMAIN /param=ref; 
model PU1_IND =  GENDER|USERWIKI|DOMAIN/risklimits;
Run;

/*Checking colineartiy(VIF) for selected variables from logistic reg */
proc reg data=wikipedia1;
model PU1_IND= GENDER  USERWIKI DOMAIN / vif; 
run;







