from pyspark.sql.functions import col, lit
from datetime import datetime
import pytz

tz = options["timeZone"]
tzinfo=pytz.timezone(tz)
curTime=datetime.now(tzinfo)
transformedDf = inputDf.withColumn("curationTime", lit(curTime))
setOutputDf(transformedDf)
