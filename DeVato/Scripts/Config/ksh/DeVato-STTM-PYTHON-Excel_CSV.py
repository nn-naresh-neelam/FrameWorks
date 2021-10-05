#!/usr/local/bin/python3
# ----------------------------------------------------------------
# DeVato-STTM-PYTHON-Excel_CSV.py
# ----------------------------------------------------------------
# Current Version
# ----------------------------------------------------------------
# $Author: Naresh Neelam
# ----------------------------------------------------------------
#Converts XLSX File into Pipe Delimited File
import pandas as pd
import os
import sys
import csv


srcpath=sys.argv[1]
srcfilename=sys.argv[2]
sheetname=sys.argv[3]
collist=sys.argv[4]
headstart=int(sys.argv[5])
tgtpath=sys.argv[6]
tgtfilename=sys.argv[7]

srcfilenamepath=os.path.join(srcpath,srcfilename)
tgtfilenamepath=os.path.join(tgtpath,tgtfilename)

#df=pd.read_excel(srcfilenamepath,sheet_name=sheetname,header=headstart,engine='openpyxl',usecols=collist)
df=pd.read_excel(srcfilenamepath,sheet_name=sheetname,header=headstart,usecols=collist)
df=df.replace('\n','',regex=True)
df=df.replace('"','',regex=True)
df['FileName']=srcfilename
df.to_csv(tgtfilenamepath,sep='|',header=False,index=False,mode='a',quoting=csv.QUOTE_NONE)
