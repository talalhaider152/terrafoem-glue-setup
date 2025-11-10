import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql import functions as F
args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)
data = [
    ("John", "HR", 4500),
    ("Sara", "Finance", 5200),
    ("Mike", "IT", 6000),
    ("Emma", "Finance", 5800),
    ("David", "IT", 4900),
]
columns = ["employee_name", "department", "salary"]
df = spark.createDataFrame(data, columns)
df = df.withColumn("bonus", F.col("salary") * 0.10)
df = df.withColumn("department", F.upper(F.col("department")))
df_filtered = df.filter(F.col("salary") > 5000)
output_path = "s3://dev-glue-script-bucket-11022/output/"
df_filtered.write.mode("overwrite").parquet(output_path)
job.commit()