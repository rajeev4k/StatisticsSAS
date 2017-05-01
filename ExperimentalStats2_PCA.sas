PROC IMPORT DATAFILE= "/folders/myfolders/Data/Cleveland_heartdisease_data.csv"
OUT= heartdisease
DBMS=csv
REPLACE;
GETNAMES=YES;
RUN;

proc means data=heartdisease n mean min max std var;
run;

title 'histogram and scatter';
proc sgscatter data=heartdisease;
matrix age sex cp trestbps chol fbs restecg thalach exang oldpeak slope ca thal num / diagonal=(histogram) group=num;
run;


title 'full PCA with num';
proc princomp data=heartdisease out=heartdiseaseP2;
var age /*sex*/ cp trestbps chol fbs restecg thalach exang oldpeak slope ca thal;
run;

title 'PCR with cross num';
proc pls data=heartdisease method=PCR cv=one cvtest (stat=PRESS);
model num = age /*sex*/ cp trestbps chol fbs restecg thalach exang oldpeak slope ca thal;
run; 

title 'PCR with 8';
proc pls data=heartdisease method=PCR nfac=8;
model num = age /*sex*/ cp trestbps chol fbs restecg thalach exang oldpeak slope ca thal;
run;
 

title "Reg 8 Prin CI";
proc reg data=heartdiseaseP2;
model num = Prin1 Prin2 Prin3 Prin4 Prin5 Prin6 Prin7 Prin8/ CLB;
run;





