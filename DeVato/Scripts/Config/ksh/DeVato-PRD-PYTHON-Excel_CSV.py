#!/usr/local/bin/python3
# ----------------------------------------------------------------
# DeVato-PRD-PYTHON-Excel_CSV.py
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
tgtpath=sys.argv[3]
tgtfilename=sys.argv[4]

srcfilenamepath=os.path.join(srcpath,srcfilename)
tgtfilenamepath=os.path.join(tgtpath,tgtfilename)

#df=pd.read_excel(srcfilenamepath,engine='openpyxl')
df=pd.read_excel(srcfilenamepath)
df.to_csv(tgtfilenamepath,sep='|',header=False,index=False,quoting=csv.QUOTE_NONE)
