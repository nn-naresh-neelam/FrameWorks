#!/usr/local/bin/python3
# ----------------------------------------------------------------
# DeVato-Configuration-PYTHON-Excel_CSV.py
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Author: Naresh Neelam
# ----------------------------------------------------------------
#Converts XLSX File into Pipe Delimited File
import pandas as pd
import os
import sys


srcpath=sys.argv[1]
sttmname=sys.argv[2]
tgtpath=sys.argv[3]
configFileName=os.path.join(srcpath,sttmname)

ddlconfigtab='DDL_Configuration'
sttmconfigtab='STTM_Configuration'
outputconfigtab='OUTPUT_Configuration'
tablelist='Table_List'
procfile='Process'

ddltgtname=ddlconfigtab+'.csv'
sttmtgtname=sttmconfigtab+'.csv'
oupputtgtname=outputconfigtab+'.csv'
tablelisttgtname=tablelist+'.csv'
processtgtname=procfile+'.Flow'

ddltgt=os.path.join(tgtpath,ddltgtname)
sttmtgt=os.path.join(tgtpath,sttmtgtname)
ouputtgt=os.path.join(tgtpath,oupputtgtname)
tablelisttgt=os.path.join(tgtpath,tablelisttgtname)
proctgt=os.path.join(tgtpath,processtgtname)

#DDL_Configuration
#ddldf=pd.read_excel(configFileName,sheet_name=ddlconfigtab,engine='openpyxl')
ddldf=pd.read_excel(configFileName,sheet_name=ddlconfigtab)
ddldf_obj=ddldf.select_dtypes(['object'])
ddldf[ddldf_obj.columns]=ddldf_obj.apply(lambda x: x.str.strip())
ddldf=ddldf.replace(' ','_',regex=True)
ddldf.to_csv(ddltgt,sep='|',header=False,index=False)

#STTM_Configuration
#sttmdf=pd.read_excel(configFileName,sheet_name=sttmconfigtab,engine='openpyxl')
sttmdf=pd.read_excel(configFileName,sheet_name=sttmconfigtab)
sttmdf_obj=sttmdf.select_dtypes(['object'])
sttmdf[sttmdf_obj.columns]=sttmdf_obj.apply(lambda x: x.str.strip())
sttmdf.to_csv(sttmtgt,sep='|',header=False,index=False)

#OUTPUT_Configuration
#outputdf=pd.read_excel(configFileName,sheet_name=outputconfigtab,engine='openpyxl')
outputdf=pd.read_excel(configFileName,sheet_name=outputconfigtab)
outputdf_obj=outputdf.select_dtypes(['object'])
outputdf[outputdf_obj.columns]=outputdf_obj.apply(lambda x: x.str.strip())
manmodedf=outputdf[(outputdf["Mode"] == "Manual-Tablelist") & (outputdf["Required"] == "Yes")]
automodedf=outputdf[(outputdf["Mode"] == "Automatic") & (outputdf["Required"] == "Yes")]
i=manmodedf.shape[0]
if i>0:
        manmodedf.to_csv(proctgt,sep='|',header=False,index=False)
else:
        automodedf.to_csv(proctgt,sep='|',header=False,index=False)
outputdf.to_csv(ouputtgt,sep='|',header=False,index=False)

#Table_List
#tlistdf=pd.read_excel(configFileName,sheet_name=tablelist,engine='openpyxl')
tlistdf=pd.read_excel(configFileName,sheet_name=tablelist)
tlistdf_obj=tlistdf.select_dtypes(['object'])
tlistdf[tlistdf_obj.columns]=tlistdf_obj.apply(lambda x: x.str.strip())
tlistdf.to_csv(tablelisttgt,sep='|',header=False,index=False)
