proc template;
  define style styles.mystyle;
  parent=styles.default;
    style GraphData1 from GraphData1 /
          contrastcolor=green linestyle=1;
    style GraphData2 from GraphData2 /
          contrastcolor=red linestyle=1;
	style GraphData3 from GraphData1 /
          contrastcolor=green linestyle=2;
    style GraphData4 from GraphData2 /
          contrastcolor=red linestyle=2;
   end;
run;

ods listing close;
ods html file='test.html' path='.' style=styles.mystyle; 

PROC IMPORT OUT= WORK.IAT_ALL
            DATAFILE= "\\bengal.missouri.edu\\jbhkd6\\IAT\\ultimate_09192013\\tupac_HLM_lvl2.txt"
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

DATA WORK.IAT;
	SET WORK.IAT_ALL;
	IF CORONAL = 2 THEN DELETE;
	IF CORONAL = 3 THEN DELETE;
	IF CORONAL = 4 THEN DELETE;
	RUN;

PROC MEANS data=Work.IAT nway noprint;
class sub switch incongruency;
var early_mean late_mean SC_RT CE_RT old_IAT IAT_2003;
OUTPUT out=IAT_REG mean= ;
run;

DATA work.iat_no2;
	set work.iat_cor;
	if sub = 6 then delete;
	run;

	/*
DATA WORK.IAT_RM;
	SET WORK.IAT;
	IF sub = 6 THEN DELETE;
	RUN;

DATA WORK.IAT_WINSOR;
	SET WORK.IAT;
	IF IAT = 0.1207557 THEN IAT = 0.4104777;
	RUN;
	*/

/*
*graphing settings;
axis1 order = (-1 to 5 by .5) minor = none;
axis2 order = (0 to 1.5 by .25) minor = none;
*/

*switch|incongruency;
proc mixed covtest data=IAT; /*early mean as function of condition*/
class sub channel incongruency switch;
title 'early mean, switch & incongruency';
model early_mean = incongruency|switch; * /solution OUTPRED = n2_red;
lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

proc mixed covtest data=IAT; /*late mean as function of condition*/
class sub channel incongruency switch;
title 'late mean, switch & incongruency';
model late_mean = incongruency|switch; * /solution OUTPRED = n2_red;
lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

*now with old_IAT in the model;

proc mixed covtest data=IAT; /*early mean as function of condition*/
class sub channel incongruency switch;
title 'early mean, switch & incongruency';
model early_mean = incongruency|switch|old_IAT; * /solution OUTPRED = n2_red;
*lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

proc mixed covtest data=IAT; /*late mean as function of condition*/
class sub channel incongruency switch;
title 'late mean, switch & incongruency';
model late_mean = incongruency|switch; * /solution OUTPRED = n2_red;
*lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

*and again with the new IAT;

proc mixed covtest data=IAT; /*early mean as function of condition*/
class sub channel incongruency switch;
title 'early mean, switch & incongruency';
model early_mean = incongruency|switch|IAT_2003; * /solution OUTPRED = n2_red;
*lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

proc mixed covtest data=IAT; /*late mean as function of condition*/
class sub channel incongruency switch;
title 'late mean, switch & incongruency';
model late_mean = incongruency|switch|IAT_2003; * /solution OUTPRED = n2_red;
*lsmeans incongruency|switch;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

*correlation matrix;
title 'correlation matrix';
proc corr data=iat_cor outp=cor_table;
var congruency_early_diff switching_early_diff congruency_late_diff switching_late_diff SC_RT CE_RT old_IAT IAT_2003;
run;



proc reg data=iat_cor;
title 'old_IAT as function of switch-cost & congruency-cost';
model old_IAT = SC_RT CE_RT;
title 'IAT_2003 as function of switch-cost & congruency-cost';
model IAT_2003 = SC_RT CE_RT;
model IAT_2003 = SC_RT;
model IAT_2003 = CE_RT;
model old_IAT = SC_RT;
model old_IAT = CE_RT;
run;

proc reg data=iat_cor;
title 'IAT scores predicted by difference waves, all 19';
model old_IAT = SC_RT congruency_early_diff switching_early_diff;
model IAT_2003 = SC_RT congruency_early_diff switching_early_diff;
model IAT_2003 = congruency_early_diff switching_early_diff;
model old_IAT = congruency_early_diff switching_early_diff;
run;

proc reg data=iat_no2;
title 'IAT scores predicted by difference waves, influential obs excluded';
model old_IAT = SC_RT congruency_early_diff switching_early_diff;
model IAT_2003 = SC_RT congruency_early_diff switching_early_diff;
model IAT_2003 = congruency_early_diff switching_early_diff;
model old_IAT = congruency_early_diff switching_early_diff;
run;
quit;

proc reg data=iat_cor;
model SC_RT = switching_early_diff;
model CE_RT = congruency_early_diff;
model SC_RT = switching_late_diff;
model CE_RT = congruency_late_diff;
run;
quit;


proc glm data=iat_reg;
class switch incongruency;
title 'raw early mean X switch X incon, old_IAT';
model old_IAT = early_mean|switch|incongruency;
run;

proc glm data=iat_reg;
class switch incongruency;
title 'raw late mean X switch X incon, old_IAT';
model old_IAT = late_mean|switch|incongruency;
run;

proc glm data=iat_reg;
class switch incongruency;
title 'raw early mean X switch X incon, IAT_2003';
model IAT_2003 = early_mean|switch|incongruency;
run;

proc glm data=iat_reg;
class switch incongruency;
title 'raw late mean X switch X incon, IAT_2003';
model IAT_2003 = late_mean|switch|incongruency;
run;
quit;

proc univariate data=iat_cor;
var CE_RT SC_RT;
histogram;
run;

proc univariate data=iat_diff;
var CE_RT SC_RT;
histogram;
run;

proc univariate data=iat_reg;
var CE_RT SC_RT;
histogram;
run;

proc univariate data=iat;
var CE_RT SC_RT;
histogram;
run;


/*
*regressions;
proc reg data=iat_cor;
*title 'raw early mean X switch X incon, old_IAT';
model old_IAT = congruency_early_diff;
model old_IAT = congruency_late_diff;
model old_IAT = switching_early_diff;
model old_IAT = switching_late_diff;
*title 'raw late mean X switch X incon, old_IAT';
model old_IAT = congruency_early_diff congruency_late_diff;
*title 'raw early mean X switch X incon, IAT_2003';
model IAT_2003 = early_mean switch incongruency;
*title 'raw late mean X switch X incon, IAT_2003';
model IAT_2003 = late_mean switch incongruency;
run; */

*here's all the plotting stuff by Lada;

*create a new dataset with values for IAT to plot;
data pad0;
set iat;
keep sub channel;
run;
proc sort data=pad0 out=pad1 nodupkeys;
by sub channel;
run;
data pad2;
set pad1;
index=1;
do switch=-1 to 1 by 2;
do incongruency=-1  to 1 by 2;
do i=1 to 13;
IAT_2003=i*0.1;
do j=1 to 6;
old_IAT=j*0.1;
output;
end;
end;
end;
end;
drop i;
drop j;
run;


*append raw data with plot data;
data forplot;
set iat pad2;
run;



*run your model, the results will be the same as for raw dataset but the predicted values will be computed for all records;

proc mixed covtest data=forplot ; /*early mean as function of condition*/
class sub channel;
title 'early mean, switch & incongruency';
model mean = incongruency|switch /solution OUTPRED = n2_red;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

proc mixed covtest data=forplot ; /*early mean as function of condition*/
class sub channel;
title 'early mean, switch & incongruency & oldIAT';
model mean = incongruency|switch|old_IAT /solution OUTPRED = n2_full_old;
random intercept /sub=sub;
random int/sub=channel(sub);
run;

proc mixed covtest data=forplot ; /*early mean as function of condition*/
class sub channel;
title 'early mean, switch & incongruency & IAT d2';
model mean = incongruency|switch|IAT_2003 /solution OUTPRED = n2_full;
random intercept /sub=sub;
random int/sub=channel(sub);
run;
* create cell groups for a plot;

data forplot2;
set n2_full;
if index=1;
if incongruency=1 and switch=1 then cell='incongruent_switch';
if incongruency=-1 and switch=1 then cell='congruent_switch';
if incongruency=1 and switch=-1 then cell='incongruent_stay';
if incongruency=-1 and switch=-1 then cell='congruent_stay';
run;


* collapse data by incongruency,switch ,iat;
proc sql;
create table forplot3 as select*, mean(pred) as meanDV
from forplot2 group by incongruency,switch , IAT_2003;
quit;
proc sort data=forplot3 out=forplot4 nodupkeys;
by incongruency switch IAT_2003;
run;

* do it all again for old_IAT;

data forplot2_old;
set n2_full_old;
if index=1;
if incongruency=1 and switch=1 then cell='incongruent_switch';
if incongruency=-1 and switch=1 then cell='congruent_switch';
if incongruency=1 and switch=-1 then cell='incongruent_stay';
if incongruency=-1 and switch=-1 then cell='congruent_stay';
run;

* collapse data by incongruency,switch ,iat;
proc sql;
create table forplot3_old as select*, mean(pred) as meanDV
from forplot2_old group by incongruency,switch ,old_IAT;
quit;
proc sort data=forplot3_old out=forplot4_old nodupkeys;
by incongruency switch old_IAT;
run;

*plot regression lines;

proc sgplot data=forplot4_old;
title "Predicted early mean vs IAT by incongruency and switch groups";
yaxis MIN= -3 MAX = 2 LABEL = 'ERP amplitude (250-450ms)';
xaxis LABEL = "Conventional IAT score (1998 method)";
*scatter x=iat y = predicted/ group=cell;
series x=old_IAT y = meandv/ group=cell  ;
keylegend / location=inside across=1 position=bottomleft title='Groups';
run;

title;

*plot regression lines;

proc sgplot data=forplot4;
title "Predicted early mean vs IAT by incongruency and switch groups";
yaxis MIN= -3 MAX = 2 LABEL = 'ERP amplitude (250-450ms)';
xaxis LABEL = "IAT 'd-score' (2003 method)";
*scatter x=iat y = predicted/ group=cell;
series x=IAT_2003 y = meandv/ group=cell  ;
keylegend / location=inside across=1 position=bottomleft title='Groups';
run;

title;








/*
* one last time for n450 and old_IAT;

data forplot20_old;
set n450_full_old;
if index=1;
if incongruency=1 and switch=1 then cell='incongruent_switch';
if incongruency=-1 and switch=1 then cell='congruent_switch';
if incongruency=1 and switch=-1 then cell='incongruent_stay';
if incongruency=-1 and switch=-1 then cell='congruent_stay';
run;


* collapse data by incongruency,switch ,iat;
proc sql;
create table forplot30_old as select*, mean(pred) as meanDV
from forplot20_old group by incongruency,switch ,old_iat;
quit;
proc sort data=forplot30_old out=forplot40_old nodupkeys;
by incongruency switch old_iat;
run;




*plot regression lines;

proc sgplot data=forplot40_old;
title "Predicted late mean vs IAT by incongruency and switch groups";
yaxis MIN= -2 MAX = 4 LABEL = 'Late Mean';
xaxis LABEL = "C1 IAT (1998)";
*scatter x=iat y = predicted/ group=cell;
series x=old_iat y = meandv/ group=cell  ;
keylegend / location=inside across=1 position=bottomleft title='Groups';
run;

title;


proc options option=jreoptions; 
run;
*/
