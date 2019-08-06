library(readxl)


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



#plot hydrograph
plot(data$...1,data$`Flow compound weir stormflow clipped (gpm)`,type="l")
lines(data$...1,data$`Flow compound weir (gpm)`,lty=2)


#combine cal data with flow data
new.df=merge(flow.data,cal.data, by.x = "Datetime")

plot(new.df$`Flow compound weir stormflow clipped (gpm)`,new.df$Flow_gpm_1, xlim = c(0,5) ,ylim = c(0,5),xlab = "Predicted Flow clipped, (gpm)",ylab = "Measured flow, (gpm)")
points(new.df$`Flow compound weir stormflow clipped (gpm)`,new.df$Flow_gpm_2)
points(new.df$`Flow compound weir stormflow clipped (gpm)`,new.df$Flow_gpm_3)
abline(0, 1) 


