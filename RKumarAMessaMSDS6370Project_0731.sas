/*IMPORTING DATASET*/

/*In University SAS studio we use FILENAME REFFILE "/folders/myfolders/the name of the file" */
FILENAME REFFILE "/folders/myfolders/total-patent-applications-total-count-by-applicants-origin-1980_2015.csv";
PROC IMPORT DATAFILE=REFFILE 
dbms=csv
out= PatentApplication;
getnames= yes;
run; 

proc print data=PatentApplication;
run;

/* 1) SIMPLE RANDOM SAMPLING FOR SAMPLE SIZE =200 */

/* Creating sample size =200 using SRS method*/
title 'Simple Random Sampling';
proc surveyselect data=PatentApplication
   method=srs n=200 out=SampleSRS seed=91118;
run;

proc print data=SampleSRS;
run;

/* Creating sample data caled SRS that includes the Sample weight*/
data SRS;
set SampleSRS;
SamplingWeight=4270/200;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS mean clm sum clsum total=4270;
title 'Simple Random Sampling Method for n=200';
var Patent_Applications;
weight SamplingWeight;
run;

/*
*SYSTEMATIC RANDOM SAMPLING FOR SAMPLE SIZE =200*;

* Creating sample size =200 using SYS method*;
title 'Systematic Random Sampling';
Proc SurveySelect
data = PatentApplication
method = sys
n =200
out = SampleSystematic
seed = 91118
;
Run;
proc print data=SampleSystematic;
run;

* Creating sample data caled SYS that includes the Sample weight*;
data SYS;
set SampleSystematic;
SamplingWeight=4270/200;
run;

*Calculating the population mean, total and convidence intervals*;
proc surveymeans data=SYS mean clm sum clsum total=4270;
title 'SYstematic Random Sampling Method';
var Patent_Applications;
weight SamplingWeight;
run;
*/


/* 2) STRATIFIED METHOD*/

/* 2.1) STRATIFIED METHOD USING STRATUM POPULATION AND SAMPLE SIZE AUTO CALCULATION */

/*Sorting data by Year*/
proc sort data=PatentApplication
  out=Patent;
by Year;
run;
/*printing the sorted dataset*/
proc print data =Patent; 
run;
/* A) Stratified Proportional Allocation For Sample Size =200 */

title 'Patent Application by Year';
proc surveyselect data=Patent
   n=200 out=propTable; *propTable includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=prop nosample;
run;
proc print data=propTable;
run;


/*Slicing Year and Proportional Total Strata Population Sizes out of propTable*/
data propStratumPop(keep= Year Total rename= (Total=_total_));
 set propTable; 
 proc print data=propStratumPop;
 run;
 
/*Slicing Year and Stratum Proportional SampleSizes out of propTable */
data StratumProporSampSizes(keep= Year SampleSize);
 set propTable; 
 proc print data=StratumProporSampSizes;
 run;

/* Allocating sample sizes of Proportional Allocation Method*/
proc surveyselect data=Patent method = srs out = StratumProportionalSample1
sampsize= StratumProporSampSizes seed=91118;
strata Year;
title "Proportional Allocation";
run;
proc print data=StratumProportionalSample1;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = StratumProportionalSample1 mean clm sum clsum total = propStratumPop;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Proportional Allocation Method for n=200";
run;


/* B) Stratified Neyman Allocation For Sample Size =200 */
/*SAMMARY*/
title 'Data Summary';
proc summary data=Patent;
 class Year;
 var Patent_Applications;
 output out=patent_strata_stats1
 sum=pop_sum n=pop_n mean=pop_mean std=pop_std var=pop_var
 min=pop_min max=pop_max; 
run;

proc print data=patent_strata_stats1;
run;

title 'Neyman Allocation';
proc surveyselect data=Patent
   n=200 out=NeymanTable; *NeymanTable includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize(keep= Year Total rename=(Total=_total_));
 set NeymanTable; 
 
proc print data=NeymanStratumPopSize;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes (keep= Year SampleSize);
 set NeymanTable;
 
proc print data=NeymanStratumSampleSizes;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes1
sampsize= NeymanStratumSampleSizes seed=91118;
strata Year;
title "Neyman Allocation";
run;
proc print data=NeymanStratumSampleSizes1;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes1 mean clm sum clsum total = NeymanStratumPopSize;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method1";
run;


/* 3.2) STRATIFIED METHOD USING STRATUM POPULATION AND SAMPLE SIZE INPUTED FROM EXCELL CALCULATION */
/* A) STRATIFIED PROPORTIONAL ALLOCATION FOR SAMPLIE SIZE = 200*/
/* allocating sample sizes of Proportional method*/
proc surveyselect data=Patent method = srs out = StratumProportionalSample
sampsize= (4 4 4 4 4 4 3 3 3 4 4 4 4 5 4 5 5 5 6 6 6 6 7 7 7 7 7 7 7 7 7 8 8 8 8 8) seed=91118;
strata Year;
title "Proportional Allocation";
run;
proc print data=StratumProportionalSample;
run;

/*Estimating population mean, Population mean confidence interval, standard error, 
Total population, standard deviation, population total confidence interval from Sample Proportion Method*/
data strsizes;
input Year _total_ ;
datalines;
1980 82
1981 76
1982 77
1983 81
1984 79
1985 75
1986 73
1987 70
1988 73
1989 75
1990 75
1991 82
1992 87
1993 99
1994 95
1995 107
1996 107
1997 110
1998 129
1999 119
2000 124
2001 131
2002 144
2003 157
2004 156
2005 156
2006 145
2007 157
2008 154
2009 159
2010 160
2011 172
2012 173
2013 170
2014 170
2015 171
;
run;

proc print data=strsizes;
run;

proc surveymeans data = StratumProportionalSample mean clm sum clsum total = strsizes;
var Patent_Applications;
strata Year;
weight SamplingWeight;
title "Proportional Allocation Method2";
run;


/*STRATIFIED NEYMAN ALLOCATION*/

/* allocating sample sizes of Neyman method*/
proc surveyselect data=Patent method = srs out = NeymanSample
sampsize= (2 1 1 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 5 5 6 6 6 7 7 8 8 8 8 8 8 9 11 12 13 15) seed=91118;
strata Year;
title "Neyman Allocation";
run;

/* Estimating population mean, Population mean confidence interval, standard error, 
Total population, standard deviation, population total confidence interval from Neyman Method */
data strsizes;
input Year _total_ ;
datalines;
1980 82
1981 76
1982 77
1983 81
1984 79
1985 75
1986 73
1987 70
1988 73
1989 75
1990 75
1991 82
1992 87
1993 99
1994 95
1995 107
1996 107
1997 110
1998 129
1999 119
2000 124
2001 131
2002 144
2003 157
2004 156
2005 156
2006 145
2007 157
2008 154
2009 159
2010 160
2011 172
2012 173
2013 170
2014 170
2015 171
;
run;


proc surveymeans data = NeymanSample mean clm sum clsum total = strsizes;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method2";
run;


/*Here Stratified random sampling with Neyman allocation is the most efficient (has smallest 
variance) of proportional allocation and simple random sampling. And Stratified random sampling 
with proportional allocation is found to be always more efficient than simple random sampling.
 
Now we will conduct stratified random sampling with Neyman allocation, and simple random 
 sampling for five different sizes(n=100,200,400,500,aand 1000) and compare the results */


/* I) SIMPLE RANDOM SAMPLING (SRS)*/

/*SRS n=100)*/

title 'Simple Random Sampling n =100';
proc surveyselect data=PatentApplication
method=srs n=100 out=SampleSRS_100 seed=9117;
run;

proc print data=SampleSRS_100;
run;

/* Creating sample data caled SRS that includes the Sample weight*/
data SRS_100;
set SampleSRS_100;
SamplingWeight_100 = 4270/100;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS_100 mean clm sum clsum total=4270;
title 'Simple Random Sampling Method n=100';
var Patent_Applications;
weight SamplingWeight_100;
run;


/*SRS n=200)*/
/* Creating sample size =200 using SRS method*/
title 'Simple Random Sampling n=200';
proc surveyselect data=PatentApplication
   method=srs n=200 out=SampleSRS_200 seed=91118;
run;

proc print data=SampleSRS_200;
run;

/* Creating sample data caled SRS_200 that includes the Sample weight*/
data SRS_200;
set SampleSRS_200;
SamplingWeight_200 = 4270/200;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS_200 mean clm sum clsum total=4270;
title 'Simple Random Sampling Method n=200';
var Patent_Applications;
weight SamplingWeight_200;
run;

/*SRS n=400)*/
/* Creating sample size =400 using SRS method*/
title 'Simple Random Sampling n=400';
proc surveyselect data=PatentApplication
   method=srs n=400 out=SampleSRS_400 seed=91119;
run;

proc print data=SampleSRS_400;
run;

/* Creating sample data caled SRS_400 that includes the Sample weight*/
data SRS_400;
set SampleSRS_400;
SamplingWeight_400=4270/400;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS_400 mean clm sum clsum total=4270;
title 'Simple Random Sampling Method n=400';
var Patent_Applications;
weight SamplingWeight_400;
run;

/*SRS n=500)*/
/* Creating sample size =500 using SRS method*/
title 'Simple Random Sampling n=500';
proc surveyselect data=PatentApplication
   method=srs n=500 out=SampleSRS_500 seed=911110;
run;

proc print data=SampleSRS_500;
run;

/* Creating sample data caled SRS_500 that includes the Sample weight*/
data SRS_500;
set SampleSRS_500;
SamplingWeight_500=4270/500;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS_500 mean clm sum clsum total=4270;
title 'Simple Random Sampling Method n=500';
var Patent_Applications;
weight SamplingWeight_500;
run;

/*SRS n=1000)*/
/* Creating sample size =1000 using SRS method*/
title 'Simple Random Sampling n=1000';
proc surveyselect data=PatentApplication
   method=srs n=1000 out=SampleSRS_1000 seed=911111;
run;

proc print data=SampleSRS_1000;
run;

/* Creating sample data caled SRS that includes the Sample weight*/
data SRS_1000;
set SampleSRS_1000;
SamplingWeight_1000=4270/1000;
run;

/*Calculating the population mean, total and confidence intervals*/
proc surveymeans data=SRS_1000 mean clm sum clsum total=4270;
title 'Simple Random Sampling Method n=1000';
var Patent_Applications;
weight SamplingWeight_1000;
run;




/* II) STRATIFIED SIMPLE RANDOM SAMPLING WITH NEYMAN ALLOCATION (NEYMAN)*/

/*Sorting data by Year*/
title 'Sorted Data by Year';
proc sort data=PatentApplication
  out=Patent;
by Year;
run;

/*printing the sorted dataset*/
proc print data =Patent; 
run;

/*Calculating and Printing Sammary of dataset*/
title 'Data Summary';
proc summary data=Patent;
 class Year;
 var Patent_Applications;
 output out=patent_strata_stats1
 sum=pop_sum n=pop_n mean=pop_mean std=pop_std var=pop_var
 min=pop_min max=pop_max; 
run;
proc print data=patent_strata_stats1;
run;




/*NEYMAN n=100)*/

title 'Neyman Allocation n=100';
proc surveyselect data=Patent
   n=100 out=NeymanTable_100; *NeymanTable_100 includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable_100;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize_100(keep= Year Total rename=(Total=_total_));
 set NeymanTable_100; 
 
proc print data=NeymanStratumPopSize_100;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes_100 (keep= Year SampleSize);
 set NeymanTable_100;
 
proc print data=NeymanStratumSampleSizes_100;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes_100_
sampsize= NeymanStratumSampleSizes_100 seed=91117;
strata Year;
title "Neyman Allocation n=100";
run;
proc print data=NeymanStratumSampleSizes_100_;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes_100_ mean clm sum clsum total = NeymanStratumPopSize_100;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method n=100";
run;


/*NEYMAN n=200)*/

title 'Neyman Allocation n=200';
proc surveyselect data=Patent
   n=200 out=NeymanTable_200; *NeymanTable_200 includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable_200;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize_200(keep= Year Total rename=(Total=_total_));
 set NeymanTable_200; 
 
proc print data=NeymanStratumPopSize_200;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes_200 (keep= Year SampleSize);
 set NeymanTable_200;
 
proc print data=NeymanStratumSampleSizes_200;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes_200_
sampsize= NeymanStratumSampleSizes_200 seed=91118;
strata Year;
title "Neyman Allocation n=200";
run;
proc print data=NeymanStratumSampleSizes_200_;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes_200_ mean clm sum clsum total = NeymanStratumPopSize_200;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method n=200";
run;



/*NEYMAN n=400)*/

title 'Neyman Allocation n=400';
proc surveyselect data=Patent
   n=400 out=NeymanTable_400; *NeymanTable_400 includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable_400;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize_400(keep= Year Total rename=(Total=_total_));
 set NeymanTable_400; 
 
proc print data=NeymanStratumPopSize_400;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes_400 (keep= Year SampleSize);
 set NeymanTable_400;
 
proc print data=NeymanStratumSampleSizes_400;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes_400_
sampsize= NeymanStratumSampleSizes_400 seed=91119;
strata Year;
title "Neyman Allocation n=400";
run;
proc print data=NeymanStratumSampleSizes_400_;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes_400_ mean clm sum clsum total = NeymanStratumPopSize_400;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method n=400";
run;



/*NEYMAN n=500)*/

title 'Neyman Allocation n=500';
proc surveyselect data=Patent
   n=500 out=NeymanTable_500; *NeymanTable_500 includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable_500;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize_500(keep= Year Total rename=(Total=_total_));
 set NeymanTable_500; 
 
proc print data=NeymanStratumPopSize_500;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes_500 (keep= Year SampleSize);
 set NeymanTable_500;
 
proc print data=NeymanStratumSampleSizes_500;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes_500_
sampsize= NeymanStratumSampleSizes_500 seed=911110;
strata Year;
title "Neyman Allocation n=500";
run;
proc print data=NeymanStratumSampleSizes_500_;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes_500_ mean clm sum clsum total = NeymanStratumPopSize_500;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method n=500";
run;



/*NEYMAN n=1000)*/

title 'Neyman Allocation n=1000';
proc surveyselect data=Patent
   n=1000 out=NeymanTable_1000; *NeymanTable_100 includes everything i.e strata population size,and sample size etc *;
   strata Year / alloc=neyman var=patent_strata_stats1 (where=(_type_ ne 0) rename=(pop_var=_var_))  nosample ;
run;
proc print data=NeymanTable_1000;
run;

/*Slicing Year and Neyman Stratum Population Sizes*/
data NeymanStratumPopSize_1000(keep= Year Total rename=(Total=_total_));
 set NeymanTable_1000; 
 
proc print data=NeymanStratumPopSize_1000;
run;

/* Slicing Year and Neyman Stratum Sample sizes*/
data NeymanStratumSampleSizes_1000 (keep= Year SampleSize);
 set NeymanTable_1000;
 
proc print data=NeymanStratumSampleSizes_1000;
run; 

proc surveyselect data=Patent method = srs out = NeymanStratumSampleSizes_1000_
sampsize= NeymanStratumSampleSizes_1000 seed=911111;
strata Year;
title "Neyman Allocation n=1000";
run;
proc print data=NeymanStratumSampleSizes_1000_;
run;

/*Calculating the population mean, total and convidence intervals*/
proc surveymeans data = NeymanStratumSampleSizes_1000_ mean clm sum clsum total = NeymanStratumPopSize_1000;
var Patent_Applications;
weight SamplingWeight;
strata Year;
title "Neyman Allocation Method n=1000";
run;


 




