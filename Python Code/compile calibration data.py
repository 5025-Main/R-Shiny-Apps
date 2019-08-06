# -*- coding: utf-8 -*-
"""
Created on Mon Aug 05 13:55:01 2019

@author: garrett.mcgurk
"""
import datetime as dt
import matplotlib as mpl
from matplotlib import pyplot as plt
import pandas as pd
import os
import numpy as np
import calendar
from pandas import ExcelWriter
from pandas import ExcelFile

from Excel_Plots import Excel_Plots    
from OvertoppingFlows import *
import string
import textwrap
#%%,
####  read in flow data

### UPDATE HERE #####
site_id = 'CAR-015' #end date of data

flowdir= "P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 01 - Baseflow Evaluation/Data/Processing for report/Flow data"

df = pd.read_csv(flowdir+'/'+site_id+'-flow.csv')


print("Column headings:")
print(df.columns)




#%%,
### create a blank df for flow calibrations



#%%,
#### read in 2015 data and append to blank df
dir2015="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2015 Data"

cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_id+'.xlsx')

#print(cal_df)
field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
field_meas_2015.rename(columns={"Flow (gpm)": "Flow_gpm_1"})



print(field_meas_2015)


#%%,
### read in 2016 data

dir2016="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2016 Data"



cal_df_2016= pd.read_excel(dir2016+'/'+'MS4-'+site_id+'_Draft_October2016_final'+'.xlsx',sheetname='Field Measurements')
print(cal_df_2016)

#print(cal_df)
#field_meas_2016 = cal_df_2016[np.isfinite(cal_df_2016['Manual Measurement (inches)'])]

#print(field_meas_2016)


#%%,
### read in 2017 data

dir2017="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2017 Data/Level"

Level_cal_df_2017= pd.read_excel(dir2017+'/'+site_id+'-calibration'+'.xlsx',sheetname='Level calibration')
Flow_cal_df_2017= pd.read_excel(dir2017+'/'+site_id+'-calibration'+'.xlsx',sheetname='Flow calibration')


print(Flow_cal_df_2017)



#%%,
### read in 2018 data

dir2018="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2018 Data/Level"

Level_cal_df_2018= pd.read_excel(dir2018+'/'+site_id+'-calibration'+'.xlsx',sheetname='Level calibration')
Flow_cal_df_2018= pd.read_excel(dir2018+'/'+site_id+'-calibration'+'.xlsx',sheetname='Flow calibration')


print(Flow_cal_df_2018)


#%%,
### compile field flow calibrations by site

frames = [field_meas_2015, cal_df_2016, Flow_cal_df_2017, Flow_cal_df_2018]

result = pd.concat(frames)

print(result)
