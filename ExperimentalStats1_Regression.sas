OPTION SPOOL;
/*Step-1 Importing the data set*/
proc import datafile="/folders/myfolders/Data/Project1Data.csv" 
out=PROJECT1
DBMS=csv
REPLACE;
GETNAMES=YES;
RUN;

proc print noobs data=Project1;
run;
/*Step-2 a closer look on the variable scatterplots*/
proc sgscatter data = Project1;
matrix POPULATION MEDIANAGE POPGROWTH BIRTHRATE MTRNLDTH HEATHEXPENDITURE GDP TAXREVENUE UNEMPRATE INFANTMORTALITYRATE OBESITY TOTALFERTILITYRATE/diagonal=(histogram kernel) ellipse=(type=mean);
run;

/*Step-3 scatterplot as compared the explanatory variables with the response(y)*/ 
proc sgscatter data=Project1;
plot INFANTMORTALITYRATE*POPULATION INFANTMORTALITYRATE*MEDIANAGE INFANTMORTALITYRATE*POPGROWTH INFANTMORTALITYRATE*BIRTHRATE INFANTMORTALITYRATE*MTRNLDTH INFANTMORTALITYRATE*HEATHEXPENDITURE INFANTMORTALITYRATE*GDP INFANTMORTALITYRATE*TAXREVENUE INFANTMORTALITYRATE*UNEMPRATE INFANTMORTALITYRATE*OBESITY INFANTMORTALITYRATE*TOTALFERTILITYRATE;
run;
/*Step-4 Looking the variables using univariate*/
proc univariate data=Project1;
histogram;
run;
/*Step-5 Looking the regression before transformation*/
Proc Reg Data=Project1  corr plots(label)=(rstudentleverage cooksd); *plots(unpack label);
model INFANTMORTALITYRATE =  POPULATION MEDIANAGE POPGROWTH BIRTHRATE MTRNLDTH HEATHEXPENDITURE OBESITY GDP TAXREVENUE UNEMPRATE TOTALFERTILITYRATE / partial VIF ;
run;

/*Step-6 Transformation of the response and PERCAPITA=GDP/POPULATION*/
data Project2;
set Project1;
logINFANTMORTALITYRATE=log(INFANTMORTALITYRATE);
loggdp=log(GDP);
run;
proc print data=Project2;
run;

/*Step-7. Model Building - To Exclude Highlighly Correlated Variables from the Model*/
Proc Reg Data=Project2 corr plots(label)=(rstudentleverage cooksd); *plots(unpack label);
model logINFANTMORTALITYRATE = POPULATION MEDIANAGE POPGROWTH BIRTHRATE MTRNLDTH HEATHEXPENDITURE OBESITY loggdp TAXREVENUE UNEMPRATE TOTALFERTILITYRATE / partial VIF ;
run;

/*Step -8 Model Building - Excluding Highlighly Correlated Variables from the Model*/
Proc Reg Data=Project2 corr plots(label)=(rstudentleverage cooksd);
model logINFANTMORTALITYRATE = POPULATION MEDIANAGE HEATHEXPENDITURE OBESITY loggdp TAXREVENUE UNEMPRATE /*BIRTHRATE POPGROWTH MTRNLDTH TOTALFERTILITYRATE*/ / partial VIF;
run;

/*Step -9 Model Building - Variable Selection Process Using LARS Algorithm*/
Proc GLMSELECT data=Project2;
model logINFANTMORTALITYRATE = POPULATION MEDIANAGE HEATHEXPENDITURE OBESITY loggdp TAXREVENUE UNEMPRATE  / selection=LARS(choose = cv stop = aic) cvmethod = random(5) stats = (adjrsq cp bic sbc sl);
run;

/*Step -10 Model Building - Fit Linear Regression Model*/
Proc Reg Data=Project2  corr plots(label)=(rstudentleverage cooksd); *plots(unpack label);
model logINFANTMORTALITYRATE =  MEDIANAGE OBESITY loggdp/partial VIF R ;
run;


/*Step -11 Model Building - LACK of FIT Test*/
Proc Reg Data=Project2  corr plots(label)=(rstudentleverage cooksd);
model logINFANTMORTALITYRATE = MEDIANAGE OBESITY loggdp /lackfit VIF;
run;