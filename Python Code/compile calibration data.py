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
site_id = 'SDG-085' #end date of data

flowdir= "P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 01 - Baseflow Evaluation/Data/Processing for report/Flow data"

flow_predic_df = pd.read_csv(flowdir+'/'+site_id+'-flow.csv')

flow_predic_df=flow_predic_df.rename(columns={"Unnamed: 0":"Datetime"})

flow_predic_df['Datetime'] = pd.DatetimeIndex(flow_predic_df['Datetime'])
flow_predic_df['Datetime'] = pd.to_datetime(flow_predic_df['Datetime'])
flow_predic_df = flow_predic_df.set_index('Datetime')


print(flow_predic_df)

#%%,
### create a blank df for flow calibrations


#%%,
#### read in 2015 data and append to blank df    Need to throw all these in a loop basically 
dir2015="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2015 Data"

cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_id+'.xlsx')
#print(cal_df)
field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
field_meas_2015= field_meas_2015.rename(columns={"Flow (gpm)": "Flow_gpm_1", "Date Time":"Datetime"})



print(field_meas_2015)


#%%,
#==============================================================================
# files = [f for f in os.listdir(dir2015) if f.endswith('.xlsx') == True and site_id == site_id]  
# 
# if len(files) == 0:
#     print 
#     print 'No data file found in folder!'
# for f in files: 
#     print ('')
#     print ('Filename: '+f)
#     ## Read in the data
#     cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_id+'.xlsx')  
#     field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
#     field_meas_2015= field_meas_2015.rename(columns={"Flow (gpm)": "Flow_gpm_1", "Date Time":"Datetime"})
# 
#     print ('Site name: '+site_id)
#     print ('')
# 
#==============================================================================
#%%,
### read in 2016 data

dir2016="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2016 Data"



cal_df_2016= pd.read_excel(dir2016+'/'+'MS4-'+site_id+'_Draft_October2016_final'+'.xlsx',sheetname='Field Measurements')

cal_df_2016=cal_df_2016.rename(columns={"Date Time":"Datetime","Field Meas GPM":"Flow_gpm_1"})

print(cal_df_2016)

#print(cal_df)
#field_meas_2016 = cal_df_2016[np.isfinite(cal_df_2016['Manual Measurement (inches)'])]

#print(field_meas_2016)


#%%,
### read in 2017 data

dir2017="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2017 Data/Level"

Level_cal_df_2017= pd.read_excel(dir2017+'/'+site_id+'-calibration'+'.xlsx',sheetname='Level calibration')
Flow_cal_df_2017= pd.read_excel(dir2017+'/'+site_id+'-calibration'+'.xlsx',sheetname='Flow calibration')


Flow_cal_df_2017=Flow_cal_df_2017.rename(columns={"Field Measured Flow (gpm)":"Flow_gpm_1","Site ID":"SITE ID"})

print(Flow_cal_df_2017)



#%%,
### read in 2018 data

dir2018="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2018 Data/Level"

Level_cal_df_2018= pd.read_excel(dir2018+'/'+site_id+'-calibration'+'.xlsx',sheetname='Level calibration')
Flow_cal_df_2018= pd.read_excel(dir2018+'/'+site_id+'-calibration'+'.xlsx',sheetname='Flow calibration')


print(Flow_cal_df_2018)


#%%,
### compile field flow calibrations by site

field_meas_frames = [field_meas_2015, cal_df_2016, Flow_cal_df_2017, Flow_cal_df_2018]

field_meas_df = pd.concat(field_meas_frames)

field_meas_df['Datetime'] = pd.DatetimeIndex(field_meas_df['Datetime'])
field_meas_df['Datetime'] = pd.to_datetime(field_meas_df['Datetime'])
field_meas_df = field_meas_df.set_index('Datetime')


print(field_meas_df)


#%%,
#merge predicted flow df with field calibrations 
start, end = dt.datetime(2015,5,1,0,0), dt.datetime(2018,10,31,23,59)

frame_to_merge= [flow_predic_df,field_meas_df]
flow_predic_df.inde=flow_predic_df.index
field_meas_df.index

field_meas_df[field_meas_df.index.duplicated()]


fds['Datetime'] = fds['Datetime'].apply(lambda x: dt.datetime(x.year, x.month, x.day, x.hour,5*(x.minute // 5)))

field_meas_df = field_meas_df.reindex(index=pd.date_range(start,end,freq='5Min')).interpolate(method='linear',limit=2)

 #   WL = WL.reindex(index=pd.date_range(start,end,freq='5Min')


#merged_data= pd.concat(frame_to_merge,axis=1)

merged_data= field_meas_df.join(flow_predic_df)

merged_data = merged_data[np.isfinite(merged_data['Flow_gpm_1'])]

print(merged_data)



#%%,
#write to csv

export_dir="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/Compiled Data/"


export_csv = merged_data.to_csv (export_dir+site_id+'-compiled.csv',  header=True)



