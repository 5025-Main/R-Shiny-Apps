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
import string
import textwrap

#%%,
####  read in flow data

### UPDATE HERE #####
site_id = 'CAR-015' 
site_name = 'CAR-015' 

tname='CAR-072O-Flow'
site_name0 = tname.split('-')[0] +"-"+ tname.split('-')[1]
print ('Site name: '+site_name0)
print ('')

dfccv = pd.DataFrame()   


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
#### read in 2015 data and append to blank df    Need to throw all these in a loop basically . note that flow is not flow measured so this needs to be fixed
dir2015="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2015 Data"

cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_id+'.xlsx')
#print(cal_df)
field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
field_meas_2015= field_meas_2015.rename(columns={"Flow (gpm)": "Flow_predicted (gpm)", "Date Time":"Datetime"})



print(field_meas_2015)


#%%,

#Thow it all in a loooop
flowdir="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/Compiled Level Flow Data 2015-2018"
dir2015="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2015 Data"
dir2016="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2016 Data"
dir2017="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2017 Data/Level"
dir2018="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/2018 Data/Level"

files = [f for f in os.listdir(flowdir) if f.endswith('.csv') == True]# and site_id == site_id]  

if len(files) == 0:
    print 
    print 'No data file found in folder!'
for f in files: 
    print ('')
    print ('Filename: '+f)
    try: 
        site_name = f.split('-')[0] +"-"+ f.split('-')[1]
        print ('Site name: '+site_name)
        print ('')
    #read in predicted flow data
        flow_predic_df = pd.read_csv(flowdir+'/'+site_name+'-flow.csv')
        flow_predic_df=flow_predic_df.rename(columns={"Unnamed: 0":"Datetime"})
        flow_predic_df['Datetime'] = pd.DatetimeIndex(flow_predic_df['Datetime'])
        flow_predic_df['Datetime'] = pd.to_datetime(flow_predic_df['Datetime'])
        flow_predic_df = flow_predic_df.set_index('Datetime')

        
        ## Read in 2015 manual measurement data. We only have level for these
        try:
            cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_name+'.xlsx')  
            field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
            field_meas_2015= field_meas_2015.rename(columns={"Flow (gpm)": "Flow_predicted (gpm)", "Date Time":"Datetime"})
        except:
                print(' Aint no 2015 data foo')
                #create a blank df so it doesn't insert any other data into next run of loop 
                field_meas_2015=pd.DataFrame()   
        
        ## Read in 2016 manual measurement data. Only have manual  flow measurements
        try:
            cal_df_2016= pd.read_excel(dir2016+'/'+'MS4-'+site_name+'_Draft_October2016_final'+'.xlsx',sheetname='Field Measurements')
            cal_df_2016=cal_df_2016.rename(columns={"Date Time":"Datetime","Field Meas GPM":"Flow_gpm_1"})
        except:
                print(' Aint no 2016 data foo')
                #create a blank df so it doesn't insert any other data into next run of loop 
                cal_df_2016=pd.DataFrame() 
                
        ## Read in 2017 manual measurement data
        try:
            Level_cal_df_2017= pd.read_excel(dir2017+'/'+site_name+'-calibration'+'.xlsx',sheetname='Level calibration')
            Level_cal_df_2017=Level_cal_df_2017.rename(columns={"Site ID":"SITE ID","Height above V notch (in)":"Level_above_V_in_Before","offset":"calculated offset","Stage_in":"Manual Level_in"})
            Flow_cal_df_2017= pd.read_excel(dir2017+'/'+site_name+'-calibration'+'.xlsx',sheetname='Flow calibration')
            Flow_cal_df_2017=Flow_cal_df_2017.rename(columns={"Field Measured Flow (gpm)":"Flow_gpm_1","Site ID":"SITE ID"})
        except:
                print(' Aint no 2017 data foo')
                #create a blank df so it doesn't insert any other data into next run of loop 
                Flow_cal_df_2017=pd.DataFrame() 
        ## Read in 2018 manual measurement data
        try: 
            Level_cal_df_2018= pd.read_excel(dir2018+'/'+site_name+'-calibration'+'.xlsx',sheetname='Level calibration')
            Level_cal_df_2018=Level_cal_df_2018.rename(columns={"Level_in":"Manual Level_in"})
            Flow_cal_df_2018= pd.read_excel(dir2018+'/'+site_name+'-calibration'+'.xlsx',sheetname='Flow calibration')
        except:
                print(' Aint no 2018 data foo')
                #create a blank df so it doesn't insert any other data into next run of loop 
                Flow_cal_df_2018=pd.DataFrame() 
                
        ### compile manual flow calibrations by site
        field_meas_frames = [field_meas_2015, cal_df_2016, Flow_cal_df_2017,Level_cal_df_2017, Flow_cal_df_2018,Level_cal_df_2018]
        field_meas_df = pd.concat(field_meas_frames)
        field_meas_df['Datetime'] = pd.DatetimeIndex(field_meas_df['Datetime'])
        field_meas_df['Datetime'] = pd.to_datetime(field_meas_df['Datetime'])
     #round manual measurements to nearest 5 min to line up with predicted flow
        field_meas_df['Datetime'] = field_meas_df['Datetime'].apply(lambda x: dt.datetime(x.year, x.month, x.day, x.hour,5*(x.minute // 5)))
        field_meas_df = field_meas_df.set_index('Datetime')
        
        #merge manual measurements with predicted flow where they line up
        frame_to_merge= [flow_predic_df,field_meas_df]
        #show duplicates
        field_meas_df[field_meas_df.index.duplicated()]
        merged_data= field_meas_df.join(flow_predic_df)
        
        #filter to where there are records
        merged_data = merged_data[np.isfinite(merged_data['Flow_gpm_1'])] # or  add in an or for level calibrations 
        
        #export to csv
        export_dir="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/Manual Field Measurements-Compiled/"
        export_csv = merged_data.to_csv (export_dir+site_name+'-compiled.csv',  header=True)
        
    except:
        try:
            print('HST01 messed everything up. Initiating special loop for you HST01...')
            site_name = f.split('-')[0] 
            print ('Site name: '+site_name)
            print ('')
                 #read in predicted flow data
            flow_predic_df = pd.read_csv(flowdir+'/'+site_name+'-flow.csv')
            flow_predic_df=flow_predic_df.rename(columns={"Unnamed: 0":"Datetime"})
            flow_predic_df['Datetime'] = pd.DatetimeIndex(flow_predic_df['Datetime'])
            flow_predic_df['Datetime'] = pd.to_datetime(flow_predic_df['Datetime'])
            flow_predic_df = flow_predic_df.set_index('Datetime')
    
            
            ## Read in 2015 manual measurement data. We only have level for these
            try:
                cal_df_2015= pd.read_excel(dir2015+'/'+'MS4-'+site_name+'.xlsx')  
                field_meas_2015 = cal_df_2015[np.isfinite(cal_df_2015['Manual Measurement (inches)'])]
                field_meas_2015= field_meas_2015.rename(columns={"Flow (gpm)": "Flow_predicted (gpm)", "Date Time":"Datetime"})
            except:
                    print(' Aint no 2015 data foo')
                    #create a blank df so it doesn't insert any other data into next run of loop 
                    field_meas_2015=pd.DataFrame()   
            
            ## Read in 2016 manual measurement data. Only have manual  flow measurements
            try:
                cal_df_2016= pd.read_excel(dir2016+'/'+'MS4-'+site_name+'_Draft_October2016_final'+'.xlsx',sheetname='Field Measurements')
                cal_df_2016=cal_df_2016.rename(columns={"Date Time":"Datetime","Field Meas GPM":"Flow_gpm_1"})
            except:
                    print(' Aint no 2016 data foo')
                    #create a blank df so it doesn't insert any other data into next run of loop 
                    cal_df_2016=pd.DataFrame() 
                    
            ## Read in 2017 manual measurement data
            try:
                Level_cal_df_2017= pd.read_excel(dir2017+'/'+site_name+'-calibration'+'.xlsx',sheetname='Level calibration')
                Level_cal_df_2017=Level_cal_df_2017.rename(columns={"Site ID":"SITE ID","Height above V notch (in)":"Level_above_V_in_Before","offset":"calculated offset","Stage_in":"Manual Level_in"})
                Flow_cal_df_2017= pd.read_excel(dir2017+'/'+site_name+'-calibration'+'.xlsx',sheetname='Flow calibration')
                Flow_cal_df_2017=Flow_cal_df_2017.rename(columns={"Field Measured Flow (gpm)":"Flow_gpm_1","Site ID":"SITE ID"})
            except:
                    print(' Aint no 2017 data foo')
                    #create a blank df so it doesn't insert any other data into next run of loop 
                    Flow_cal_df_2017=pd.DataFrame() 
            ## Read in 2018 manual measurement data
            try: 
                Level_cal_df_2018= pd.read_excel(dir2018+'/'+site_name+'-calibration'+'.xlsx',sheetname='Level calibration')
                Level_cal_df_2018=Level_cal_df_2018.rename(columns={"Level_in":"Manual Level_in"})
                Flow_cal_df_2018= pd.read_excel(dir2018+'/'+site_name+'-calibration'+'.xlsx',sheetname='Flow calibration')
            except:
                    print(' Aint no 2018 data foo')
                    #create a blank df so it doesn't insert any other data into next run of loop 
                    Flow_cal_df_2018=pd.DataFrame() 
                    
            ### compile manual flow calibrations by site
            field_meas_frames = [field_meas_2015, cal_df_2016, Flow_cal_df_2017,Level_cal_df_2017, Flow_cal_df_2018,Level_cal_df_2018]
            field_meas_df = pd.concat(field_meas_frames)
            field_meas_df['Datetime'] = pd.DatetimeIndex(field_meas_df['Datetime'])
            field_meas_df['Datetime'] = pd.to_datetime(field_meas_df['Datetime'])
         #round manual measurements to nearest 5 min to line up with predicted flow
            field_meas_df['Datetime'] = field_meas_df['Datetime'].apply(lambda x: dt.datetime(x.year, x.month, x.day, x.hour,5*(x.minute // 5)))
            field_meas_df = field_meas_df.set_index('Datetime')
            
            #merge manual measurements with predicted flow where they line up
            frame_to_merge= [flow_predic_df,field_meas_df]
            #show duplicates
            field_meas_df[field_meas_df.index.duplicated()]
            merged_data= field_meas_df.join(flow_predic_df)
            
            #filter to where there are records
            merged_data = merged_data[np.isfinite(merged_data['Flow_gpm_1'])] # or  add in an or for level calibrations 
            
            #export to csv
            export_dir="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/Manual Field Measurements-Compiled/"
            export_csv = merged_data.to_csv (export_dir+site_name+'-compiled.csv',  header=True)
            
        except:
            pass


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
frame_to_merge= [flow_predic_df,field_meas_df]

field_meas_df[field_meas_df.index.duplicated()]


field_meas_df['Datetime'] = field_meas_df['Datetime'].apply(lambda x: dt.datetime(x.year, x.month, x.day, x.hour,5*(x.minute // 5)))
field_meas_df['Index'] = field_meas_df['Index'].apply(lambda x: dt.datetime(x.year, x.month, x.day, x.hour,5*(x.minute // 5)))


merged_data= field_meas_df.join(flow_predic_df)

merged_data = merged_data[np.isfinite(merged_data['Flow_gpm_1'])]

print(merged_data)



#%%,
#write to csv

export_dir="P:/Projects-South/Environmental - Schaedler/5025-19-W004 CoSDWQ TO4 QA Baseflow SOP Development/Phase 02 - QA Assessment/Data/Compiled Data/"


export_csv = merged_data.to_csv (export_dir+site_id+'-compiled.csv',  header=True)



