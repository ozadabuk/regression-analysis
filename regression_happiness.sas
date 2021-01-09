FILENAME REFFILE '/folders/myshortcuts/SASUniversityEdition/MATH 456 SAS/2019.csv';
PROC IMPORT DATAFILE=REFFILE
DBMS=CSV
OUT=WORK.IMPORT;
GETNAMES=YES;
RUN;
/*Run simple statistics for all variables*/
proc means data = work.import;
Run;
/*Get Histograms for all variables, mainly looked at Score since that will be our Y variables*/
proc univariate data =work.import normal;
var Score
GDP_per_capita
Social_support
Healthy_life_expectancy
Freedom_to_make_life_choices
Generosity
Perceptions_of_corruption;
histogram Score
GDP_per_capita
Social_support
Healthy_life_expectancy
Freedom_to_make_life_choices
Generosity
Perceptions_of_corruption;
Run;
/*ran a boxplot for score to check for outliers*/
proc sgplot data=work.import ;
vbox Score;
Run;
/*here is a correlation matrix for variables*/
proc corr data=work.import plots=matrix(histogram);
var Score
GDP_per_capita
Social_support
Healthy_life_expectancy
Freedom_to_make_life_choices
Generosity
Perceptions_of_corruption;
run;
/*Here is a full model that is constructed*/
proc reg data=work.import;
model Score = GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Generosity Perceptions_of_corruption/clb lackfit;
output out=a2 p=pred r=resid;
/*here is the stepwise regression selection*/
proc reg data=work.import;
model Score = GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Generosity Perceptions_of_corruption /
selection = stepwise;
Run;
/*here is the new model after the stepwise selection, includes VIF, Cooks D for diagnostics*/
proc reg data=work.import plots=COOKSD;
model Score = GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Perceptions_of_corruption / vif clb lackfit
influence tol r partial ;
/*Possible box cox in case we need to transform our Y variable*/
proc transreg;
model boxcox(Score) = identity(GDP_per_capita) identity(Social_support)
identity(Healthy_life_expectancy) identity(Freedom_to_make_life_choices)
identity(Perceptions_of_corruption) ;
run;
/* WLS*/
FILENAME happy '/home/u49763051/MAT456/happy.txt';
data a1;
infile happy;
input Score GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
ods graphics on;
proc reg data=a1;
model Score=GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Perceptions_of_corruption / clb;
output out=a2 r=resid;
run;
ods graphics off;
data a2;
set a2;
absr=abs(resid);
sqrr=resid*resid;
proc reg data = a2;
model absr = GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices
Perceptions_of_corruption;
output out=a3 p=shat;
data a3;
set a3;
wt=1/(shat*shat);
ods graphics on;
proc reg data = a3 plots=COOKSD;
model Score = GDP_per_capita Social_support Healthy_life_expectancy
Freedom_to_make_life_choices Perceptions_of_corruption /clb VIF;
weight wt;
output out = a4 r = resid1;
run;
ods graphics off;
/*create scatter plot matrix*/
proc sgscatter data = a1;
title "Scatter plot matrix";
matrix Score GDP_per_capita Social_support Healthy_life_expectancy Freedom_to_make_life_choices
Generosity Perceptions_of_corruption /diagonal=(histogram kernel) ;
run;
proc corr data = a1;run;