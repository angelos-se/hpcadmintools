import os, sys
from datetime import datetime

YYYYMM = int(sys.argv[1]) # too lazy to check it

for line in sys.stdin:
    dataline =line.strip()
    data = dataline.split(",")
    recordTS = datetime.fromtimestamp(int(data[5]))

    if YYYYMM == int(recordTS.strftime("%Y%m")):
        print dataline
