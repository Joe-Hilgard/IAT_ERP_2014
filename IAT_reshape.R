# Set working directory
setwd("~/GitHub/Sherman_IAT_data-request")
# load reshape2 package
# install.packages("reshape2")
require(reshape2)

# Load data
dat = read.delim(file="IAT_HLM_lvl2.txt")

# Data are already into four cells: 2 Switching x 2 Incongruency
write.table(dat, file="Hilgard_IAT_4cells.txt", sep="\t", row.names=F)

# Collapse across congruency:
molten1 = melt(dat, measure.vars="voltage")
molten1 = molten1[,-2] # "cell" column no longer instructive
switchingDat = dcast(molten1, sub + coronal + sagittal + channel + switch + incongruency 
                     + SC_RT + MC_RT + old_IAT + IAT_2003 ~ variable, fun.aggregate=mean)
switchingDat$cell = "switch"
switchingDat$cell[switchingDat$switch == 0] = "No-switch"
# write it
write.table(switchingDat, file="Hilgard_IAT_switching.txt", sep="\t", row.names=F)

# Collapse across switching:
molten2 = melt(dat, measure.vars="voltage")
molten2 = molten2[,-2] # "cell" column no longer instructive
congruencyDat = dcast(molten2, sub + coronal + sagittal + channel + switch + incongruency 
                     + SC_RT + MC_RT + old_IAT + IAT_2003 ~ variable, fun.aggregate=mean)
congruencyDat$cell = "incongruent"
congruencyDat$cell[congruencyDat$incongruency == 0] = "congruent"
# write it
write.table(congruencyDat, file="Hilgard_IAT_congruency.txt", sep="\t", row.names=F)