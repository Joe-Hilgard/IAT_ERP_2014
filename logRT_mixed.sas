PROC IMPORT OUT= WORK.datFixme 
            DATAFILE= "C:\IAT Study\Revision_2\R analysis 02282014\datRT
_for_SAS.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data dat;
set datFixme;
logRT = logRT + 1.386294;
RT = RT * 4;
run;
quit;

proc mixed data=datb;
where Task="Name";
class gender race congruency Subject;
model logRT = congruency|gender|race;
random int/ sub=Subject;
lsmeans congruency|gender;
run;
quit;

proc univariate data=dat;
var RT logRT; histogram;
run;
