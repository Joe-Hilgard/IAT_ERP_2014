# reanalyzing behavioral data from IAT to satisfy reviewer 2 re: possible 
# effects of gender in IAT

# It may yet be necessary to log-transform the DVs or some shit
# until then the summary(m4) at line 54 is the good shit!

# begun Joe Hilgard 3/1/2014

dat = read.delim(file="IAT_behavioral_full_03012014.txt")
dat$Subject = as.factor(dat$Subject)
dat$logRT = log(dat$RT)

require(lme4)
require(reshape)
require(car)

# let's collapse trials w/in factor combinations w/in subjects...
dvList = c("Accuracy", "RT", "logRT", "ResponseCode", "cumTime")
ivList = colnames(dat)[!(colnames(dat) %in% dvList)]
molten = melt(dat, id.vars=ivList)
#datAll is based on all trials regardless of accuracy
datAll = cast(molten, Subject + Code + Congruency + 
               Task + Gender + Race + Valence + Switch ~ variable, 
             fun.aggregate=mean)
nameAll= datAll[datAll$Task == "Name",]
wordAll= datAll[datAll$Task == "Word",]

#datRT is based on only correct trials
datCorrect = dat[dat$Accuracy == 1,]
moltenRT = melt(datCorrect, id.vars=ivList)
datRT = cast(molten, Subject + Code + Congruency + 
               Task + Gender + Race + Valence + Switch ~ variable, 
             fun.aggregate=mean)
nameRT = datRT[datRT$Task == "Name",]
wordRT = datRT[datRT$Task == "Word",]

# gotta say I'm a little curious as to how many there are per cell...
datCount = cast(molten, Subject + Code + Congruency + 
                Task + Gender + Race + Valence + Switch ~ variable, 
              fun.aggregate=length)
# as few as 4 sometimes, usually about 8 or 10. ugh this fucking project.

# how about for just congruency x switch?
datCellCount = cast(molten, Subject + Congruency +  Switch ~ variable, 
                    fun.aggregate=length)
# about 51 and 69



# let's replicate our findings up to here:
m1 = lmer(Accuracy ~ Congruency*Switch + (1|Subject), data=datAll)
summary(m1); Anova(m1, type=3)
m2 = lmer(logRT ~ Congruency*Switch + (1|Subject), data=datRT)
summary(m2); Anova(m2, type=3)

# does gender influence either?
m3 = lmer(Accuracy ~ Congruency*Switch*Gender + (1|Subject), data=nameAll)
m4 = lmer(logRT ~ Congruency*Switch*Gender + (1|Subject), data=nameRT)
summary(m3); Anova(m3, type=3)
summary(m4); Anova(m4, type=3)

m8 = lmer(logRT ~ Gender*Race*Congruency + (1|Subject), data=nameRT)
summary(m8); Anova(m8, type=3)

maleRT = nameRT[nameRT$Gender == "Male",]
femaleRT = nameRT[nameRT$Gender == "Female",]
maleRT$Subject = as.factor(maleRT$Subject)
femaleRT$Subject = as.factor(femaleRT$Subject)


m10 = lmer(logRT ~ Congruency + (1|Subject), data=maleRT)
summary(m10); Anova(m10, type=3)
m11 = lmer(logRT ~ Congruency + (1|Subject), data=femaleRT)
summary(m11); Anova(m11, type=3)

require(ggplot2)
# ggplot(data=nameRT, aes(x=Race, fill=Congruency, y=logRT)) +
#   geom_bar(stat="identity", position="dodge")

blah = tapply(X=nameRT$logRT, INDEX=list(nameRT$Gender, nameRT$Race, nameRT$Congruency), FUN=mean)
blah = adply(blah, c(1,2,3))
colnames(blah) = c("Gender", "Race", "Congruency", "logRT")

ggplot(data=blah, aes(x=Congruency, y=logRT, fill=Gender)) +
  geom_bar(stat='identity', position='dodge') +
  scale_y_continuous(limits=c(0, 6))
