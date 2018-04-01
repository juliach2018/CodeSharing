ods html close;
ods html;

PROC IMPORT OUT= WORK.month_12 
            DATAFILE= "M:\Documents\Smokingcessationproject\12 Month War
ehouse.Final.SAV" 
            DBMS=SPSS REPLACE;
			RUN;

PROC IMPORT OUT= WORK.MONTH_3 
            DATAFILE= "M:\Documents\Smokingcessationproject\month_3.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
			RUN;

PROC IMPORT OUT= WORK.MONTH_7 
            DATAFILE= "M:\Documents\Smokingcessationproject\month_7.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
			RUN;
PROC IMPORT OUT= WORK.BASELINE3 
            DATAFILE= "M:\Documents\Smokingcessationproject\baselinecut.
xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
			RUN;

proc print data=month_12 (obs=15);
	run;
proc print data=month_3 (obs=15);
	run;
proc print data=month_7 (obs=15);
	run;
proc print data=baseline3 (obs=15);
	run;


*merging baseline and month 3 and month 7 - to see progression of quit attempts over 6 month intervention;
*to do this the variables would need to be named differently...;

data baseline_formerge;
	set baseline3;
	gender=C1;
	ethnicity=C14;
	howlongliving_publichousing=C13;
	education=C19;
	working=C20;
	income=C22;
	healthplancoverage=C23;
	agefirstsmoke=D1;
	smokeeveryday=D2;
	smokedaystypicalweek=D3;
	Intervention2=Q3_B;
	cigperday_baseline= input(D4,3.); 

	cigondayssmoke=D5;
	Smokinghouserule_bslne=D18;
	triedquittimes_life=E1;
	timestoquit=E2_1;
	mostrecentquitattempt=E3_1;
	lengthmostrecentquit_bsln=E4_1;
	timesquitlast12months=E5;
	if SITE=2 OR SITE=3 OR SITE=4 OR SITE=5 OR SITE=7 OR SITE=8 OR SITE=11 OR SITE=13 OR SITE=17 OR SITE=18 OR SITE=21 OR SITE=22 OR SITE=23 then intervention=0;
	else if SITE=1 OR SITE=6 OR SITE=9 OR SITE=10 OR SITE=12 OR SITE=14 OR SITE=15 
	OR SITE=16 OR SITE=19 OR SITE=20 then intervention=1;
	else if SITE=. then intervention=.;
	run;
proc print data=baseline_formerge (obs=30);
	var studyid intervention intervention2;
	run;

data month_3_formerge;
	set month_3;
	triedtoquitsincebaseline_3=B3;
	quittimes_baseline_3=B4;
	if B5_2='1' then longestquitdaysbsln_3= B5_1*365;
	else if B5_2='2' then longestquitdaysbsln_3= B5_1*30;
	else if B5_2='3' then longestquitdaysbsln_3= B5_1*7;
	else if B5_2='4' then longestquitdaysbsln_3= B5_1;
	else longestquitdaysbsln_3=.;
	lengthmostrecentquit_3=B6_1;
	Cigperday_3=D3;
	Smokemorelessfrombaseline_3=D5;
	Smokinghouserule_3=D9;
	run;
proc print data=month_3_formerge (obs=30);
	run;

data month_7_formerge;
	set month_7;
	anycigsince3month=B2_1;
	triedtoquitsince3_7=B3;
	quittimes_3_7=B4;
	if B5_2='1' then longestquitdaysbsln_7= B5_1*365;
	else if B5_2='2' then longestquitdaysbsln_7= B5_1*30;
	else if B5_2='3' then longestquitdaysbsln_7= B5_1*7;
	else if B5_2='4' then longestquitdaysbsln_7= B5_1;
	else longestquitdaysbsln_7=.;
	lengthmostrecentquit_7=B6_1;
	Cigperday_7=D3;
	Smokemorelessfrombaseline_7=D5;
	Smokinghouserule_7=D9;
	run;
proc print data=month_7_formerge (obs=30);
	run;

proc sort data=month_7_formerge;
	by studyid;
	run;
proc sort data=month_3_formerge;
	by studyid;
	run;
proc sort data=baseline_formerge;
	by studyid;
	run;

proc format ;
	value genderf 1='female' 2='male';
	value interventionf 0='control' 1='intervention';
	value educationf 1='less than 8th gr' 2='grades 9-11' 3='high school grad' 4='GED' 5='Technical school' 6='Some college' 7='college grad' 8='grad school';
	value ethnicityf 1='hispanic' 2='non-hispanic';
	value workingf 0='no' 1='yes';
	value incomef 1='less than 5k' 2='5-10k' 3='10-20k' 4='20-30k' 5='30-50k' 6='50-70k' 7='70-90k';
	value Smokemorelessfrombaseline_7f  1='more' 2='less' 3='same';
	run;

****merging datasets, and creating outcome variable by subtracting cigarettes smoked 
	per day at month 3 by cigarettes smoked per day at baseline;
data bslne37_merge;
	merge baseline_formerge month_3_formerge month_7_formerge;

	*quit times outcome - not investigated in this analysis, but a different analysis;
	if quittimes_baseline_3=. and quittimes_3_7=. then totalquittimes_baseline7=.;
	else if quittimes_baseline_3=. and quittimes_3_7 ne . then quittimes_baseline_3=0;
	else if quittimes_baseline_3 ne . and quittimes_3_7 = . then quittimes_3_7=0;

	totalquittimes_baseline7=(quittimes_baseline_3 +quittimes_3_7);
	
	*calculating difference in cigarettes smoked per day from different points in the study;
	cigperdaydiff_base3=(cigperday_baseline-cigperday_3);
	cigperdaydiff_base7=(cigperday_baseline-cigperday_7);
	cigperdaydiff_37=(cigperday_7-cigperday_3);

	*categorizing difference in cigarettes per day for logistic analyses using 50% percentile;
		if cigperdaydiff_base3>4 then cigfrombase3_outcome='1';
	else if cigperdaydiff_base3<=4 then cigfrombase3_outcome='0';
	if cigperdaydiff_base3= .  then cigfrombase3_outcome=.;

	
	cigperdaydiff_base3opp=(cigperday_3-cigperday_baseline);
	cigperdaydiff_base7opp=(cigperday_7-cigperday_baseline);
	cigperdaydiff_37opp=(cigperday_3-cigperday_7);

	format gender genderf. intervention interventionf. education educationf. ethnicity ethnicityf. working workingf. 
	income incomef. Smokemorelessfrombaseline_7 Smokemorelessfrombaseline_7f.;
	by studyID;
	run;

	*determining cut-offs for the outcomes;
proc univariate data=bslne37_merge;
	var cigperdaydiff_base3  ;
	run;

proc means data=bslne37_merge;
	var studyid;
	run;

proc print data=bslne37_merge (obs=100);
	var STUDYID quittimes_baseline_3 intervention cigfrombase3 cigfrombase7 cigfrombase3_outcome cigfrombase7_outcome
	cigperdaydiff_base3 cigperdaydiff_base7 cigperdaydiff_37  cigfrombase3 cigfrombase7 cigperday_baseline cigperday_3 cigperday_7 
	totalquittimes_baseline7 quittimes_baseline_3 quittimes_3_7 ;
	run;
proc freq data=bslne37_merge ;
	tables intervention gender education working income ;
	run;


*histogram of cigarettes per day difference by intervetion group;
proc sort data=bslne37_merge;
	by intervention2;
	run;

proc univariate data=bslne37_merge;
   var cigperdaydiff_base3opp ;
	by intervention2 ;
   histogram /endpoints=-52 -44 -36 -28 -20 -12 -4 4 12 20 vscale=percent vaxis=0 10 20 30 40 50 60 ;
   run;

   *demographics;
proc freq data=bslne37_merge;
   tables CESD_basecat QuitDesire agecat health incomecat race2 stress 
enrolltime working educat curanxiety ;
   by intervention2;
   run;
proc means data=bslne37_merge;
   var cigperday_baseline stress;
   by intervention2;
   run;

*TTest testing intervention and outcomes wihtout accounting for clustering;
proc ttest data=bslne37_merge;
	var cigperdaydiff_base3;
	class intervention2 ;
	run;
*p-value=0.2165;
proc ttest data=bslne37_merge;
	var cigperdaydiff_base7 ;
	class intervention2 ;
	run;
*p-value=0.51;

*********************************************************
  *linear regression - cig per day after month 3;
data bslne37_merge3;
	set bslne37_merge;
	if cigperdaydiff_base3=. then delete;
	run;
  proc genmod data=bslne37_merge3;
   	class site intervention (ref='control')/ param=ref ;
   	model cigperdaydiff_base3 =intervention ;
   	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	run;
*simple and multi linear-testing intervention and variables ;
%macro linearreg2(var);
proc genmod data=bslne37_merge3;
   	class site intervention (ref='control')/ param=ref ;
   	model cigperdaydiff_base3 =intervention &var;
   	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
  	run;
	%mend linearreg2;
	%linearreg2(race2);
	%linearreg2(agecat);
	%linearreg2(gender);
	%linearreg2(educat);
	%linearreg2(incomecat);
	%linearreg2(enrolltime);
	%linearreg2(health);
	%linearreg2(CESD_basecat);
	%linearreg2(working);
	%linearreg2(QuitDesire);
	%linearreg2(curanxiety);
	%linearreg2(FAGERcat);
	run;
	quit;

***adding health status at baseline;
proc genmod data=bslne37_merge3;
	class site intervention (ref='control')/ param=ref ;
	model cigperdaydiff_base3 =intervention health;
	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
  	run;
* multi-variate testing intervention and health;
%macro forward11(var);
proc genmod data=bslne37_merge3;
   	class site intervention (ref='control')/ param=ref ;
   	model cigperdaydiff_base3 =intervention health &var;
   	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
  	run;
	%mend forward11;
	%forward11(race2);
	%forward11(agecat);
	%forward11(gender);
	%forward11(educat);
	%forward11(incomecat);
	%forward11(enrolltime);
	%forward11(CESD_basecat);
	%forward11(working);
	%forward11(QuitDesire);
	%forward11(curanxiety);
	%forward11(FAGERcat);
	run;
	quit;

***adding enrollmenttime;
proc genmod data=bslne37_merge3;
   class site intervention (ref='control')/ param=ref ;
   model cigperdaydiff_base3 =intervention health enrolltime;
   repeated sub=site/type=cs;
   estimate 'intervention' intervention 1 -1/exp;
   run;

  *multi-variate testing intervention, health and enrollment time ;
%macro forward12(var);
	proc genmod data=bslne37_merge3;
	   class site intervention (ref='control')/ param=ref ;
	   model cigperdaydiff_base3 =intervention health enrolltime &var;
	   repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	  run;
	%mend forward12;
	%forward12(race2);
	%forward12(agecat);
	%forward12(gender);
	%forward12(educat);
	%forward12(incomecat);
	%forward12(CESD_basecat);
	%forward12(working);
	%forward12(QuitDesire);
	%forward12(curanxiety);
	%forward12(FAGERcat);
	run;
	quit;

****adding race;
proc genmod data=bslne37_merge3;
   	class site intervention (ref='control')/ param=ref ;
   	model cigperdaydiff_base3 =intervention health enrolltime race2;
   	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
 	 run;
*multi-variate testing intervention, health, enrollment time and race ;
%macro forward13(var);
	proc genmod data=bslne37_merge3;
	   class site intervention (ref='control')/ param=ref ;
	   model cigperdaydiff_base3 =intervention health enrolltime race2 &var;
	   repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	  run;
	%mend forward13;
	%forward13(agecat);
	%forward13(gender);
	%forward13(educat);
	%forward13(incomecat);
	%forward13(CESD_basecat);
	%forward13(working);
	%forward13(QuitDesire);
	%forward13(curanxiety);
	%forward13(FAGERcat);
	run;
	quit;

***that was the final model - nothing else confounded the estimate by more than 10%;
*FINAL MODEL;
proc genmod data=bslne37_merge3;
	   class site intervention (ref='control')/ param=ref ;
	   model cigperdaydiff_base3 =intervention health enrolltime race2;
	   repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	  run;


**************************************8
*logistic regression outcomes;
data bslne37_merge3;
	set bslne37_merge;
	if cigfrombase3_outcome=. then delete;
	run;
proc means data=bslne37_merge3;
	var studyid;
	run;

proc genmod data=bslne37_merge3 descending;
	class site intervention (ref='control')/param=ref ;	
	model cigfrombase3_outcome= intervention  / dist=bin link=logit;
	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	run;

%macro withintervention3macro(var);
proc genmod data=bslne37_merge3 descending;
	class site gender (ref='female') intervention (ref='control') working (ref='no')  / param=ref ;
	model cigfrombase3_outcome= intervention &var / dist=bin link=logit;
	repeated sub=site/type=cs;
	estimate 'intervention' intervention 1 -1/exp;
	run;
	%mend withintervention3macro;

	%withintervention3macro(race2);
	%withintervention3macro(agecat);
	%withintervention3macro(gender);
	%withintervention3macro(educat);
	%withintervention3macro(incomecat); 
	%withintervention3macro(e5cat); 
	%withintervention3macro(enrolltime);
	%withintervention3macro(health);
	%withintervention3macro(CESD_basecat);
	%withintervention3macro(working);
	%withintervention3macro(QuitDesire);
	%withintervention3macro(stress);
	%withintervention3macro(curdiabetes);
	%withintervention3macro(curanxiety);
	%withintervention3macro (FAGERcat);
	run;
	quit;

