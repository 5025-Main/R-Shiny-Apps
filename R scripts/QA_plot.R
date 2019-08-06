library(readxl)

library(ggplot2)
install.packages("plotly")
library(plotly) 

#read in flow data
CAR_070_working_draft <- read_excel("P:/Projects-South/Environmental - Schaedler/5025-19-W006 CoSDWQ TO6 Low Flow Monitoring/DATA/Data Deliverables/Monthly Flow Data Deliverable/May/CAR-070-working draft.xlsx", 
                                    sheet = "CAR-070-flow")
flow.data=CAR_070_working_draft
flow.data=as.data.frame(flow.data)
names(flow.data)[1]<-"Datetime"
head(flow.data)

#read in calibration data
CAR_070_calibration <- read_excel("P:/Projects-South/Environmental - Schaedler/5025-19-W006 CoSDWQ TO6 Low Flow Monitoring/DATA/Data Processing/4 - Level calibration files and figures/Data Output 05_31_2019/CAR-070-calibration.xlsx", 
                                  sheet = "Flow calibration")
cal.data=CAR_070_calibration
cal.data=as.data.frame(cal.data)


SDG.085_compiled <- read.csv("~/GitHub/R-Shiny-Apps/Applications/QA_plot/Data/Compiled Calibrations/SDG-085_compiled.csv")



#plot hydrograph
plot(data$...1,data$`Flow compound weir stormflow clipped (gpm)`,type="l")
lines(data$...1,data$`Flow compound weir (gpm)`,lty=2)


plot(SDG.085_compiled$Flow..gpm..no.stormflow,SDG.085_compiled$Flow_gpm_1)
lines(SDG.085_compiled$Flow..gpm..no.stormflow,SDG.085_compiled$Flow_gpm_2)
abline(0,1)



p <- ggplot(SDG.085_compiled, aes(Flow..gpm..no.stormflow, Flow_gpm_1)) + geom_point()
ggplotly(p)
