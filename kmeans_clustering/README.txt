Cluster Access

REMOTE_USER=kschool06
ssh -p 22010 ${REMOTE_USER}@cms.hadoop.flossystems.net
# Pass abcd

REMOTE_FOLDER="data_science"
LOCAL_FILE="sales_segments.csv.gz"
REMOTE_ADDRESS="cms.hadoop.flossystems.net"
scp -P 22010 ${LOCAL_FILE} ${REMOTE_USER}@${REMOTE_ADDRESS}:${REMOTE_FOLDER}/

hdfs dfs -ls
hdfs dfs -ls /user
hdfs dfs -mkdir data
hdfs dfs -put sales_segments.csv.gz data/

# Guardamos el notebook como archivo de python
# Añadimos
from pyspark import SparkContext
sc = SparkContext(appName = 'outliers_jose')

# Lo subimos al cluster