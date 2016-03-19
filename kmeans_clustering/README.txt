Cluster Access

REMOTE_USER=kschool06
ssh -p 22010 ${REMOTE_USER}@cms.hadoop.flossystems.net
# Pass 

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

PYSPARK_PYTHON=/opt/cloudera/parcels/Anaconda/bin/python spark-submit script.py


hadoop fs -ls
hdfs dfs -rm -R -skipTrash test

sc.textFile('data/shakespeare.txt').first()

Para bajarnos un archivo del cluster a local:
scp -P 22010 kschool06@cms.hadoop.flossystems.net:~/data_science/shakespeare.txt shakespeare.txt.2

En el cluster local:
sc.textFile('data/shakespeare.txt').first()

Desde Spark, ver directorio local

import os
od.getcwd()

paragraphs = sc.newAPIHadoopFile('data/shakespeare.txt', "org.apache.hadoop.mapreduce.lib.input.TextInputFormat",
    "org.apache.hadoop.io.LongWritable", "org.apache.hadoop.io.Text",
    conf={"textinputformat.record.delimiter": '\n\n'}).map(lambda l:l[1])

# Leemos los párrafos
paragraphs.take(10)

paragraphs.count()

import re


#limpiamos todo lo que no sean letrar o numeros
cleanParagraphs = paragraphs.map(lambda paragraph: re.sub('[^a-zA-Z0-9 ]','',paragraph.lower().strip())).map(lambda paragraph: re.sub('[ ]+',' ',paragraph)).filter(lambda l: l!='')

cleanParagraphs.take()

#Guardamos en cache
>>> cleanParagraphs.cache()
PythonRDD[8] at RDD at PythonRDD.scala:43
Vemos que ahora está listo para cachear en la prróxima instrucción (es lazy)
>>> cleanParagraphs.getStorageLevel()
StorageLevel(False, True, False, False, 1)

#para borrar la cache
>>> cleanParagraphs.unpersist()

#numero de palabras de cada parrafo
cleanParagraphs.map(lambda i: len(i.split(' '))).take(3)

#histograma
cleanParagraph = cleanParagraphs.map(lambda i: len(i.split(' ')))
cleanParagraph = cleanParagraph.map(lambda x: (x,1)).reduceByKey(lambda n1,n2: n1+n2)

cleanParagraph.take(20)
(1, 60), (2, 763), (3, 435), (4, 526), (5, 359), (6, 366), (7, 253), (8, 186), (9, 139), (10, 86), (11, 88), (12, 67), (13, 41), (14, 33), (15, 36), (16, 33), (17, 23), (18, 25), (19, 23), (20, 25)]
Hay 60 documentos de 1 palabra
Hay 763 documentos de 2 palabras

Qué palabras son más frecuentes dentro de cada doc

Repetimos de nuevo ya que hemos sobreescrito la variable:

cleanParagraphs = paragraphs.map(lambda paragraph: re.sub('[^a-zA-Z0-9 ]','',paragraph.lower().strip())).map(lambda paragraph: re.sub('[ ]+',' ',paragraph)).filter(lambda l: l!='')
cleanParagraphs.map(lambda i: i.split(' ')).take(5)

import pandas as pd
import numpy as np
cleanParagraphs.map(lambda i: [i.split(' '), len(i.split())]).take(3)

import pandas
from collections import Counter
cleanParagraphs.map(lambda i: i.split(' ')).map(lambda x: Counter(x)).take(5)

cleanParagraphs.map(lambda i: i.split(' ')).map(lambda x: Counter(x).most_common()).take(5)

#### JMANUEL

# otra Para estudiar y MIRAR
# term frecency -> en Internet.
# También buscar TF y IDF. Para temas de stopwords.

# Usamos Spark para ello. http://spark.apache.org/docs/latest/mllib-feature-extraction.html
# LDA (Topic Modelling: detectar dentro de artículos, temáticas). Dentro de Clustering.

from pyspark.mllib.feature import 
# Hace hashing de las palabras en números (hash) con un máximo de 2^20
# Usamos flatMap que separa las palabras dentro de las listas en listas con cada palabra.
wordInDoc = cleanParagraphs.flatMap(lambda p: p.split(' '))
wordInDoc = wordInDoc.distinct() #elimino las repetidas.
wordInDoc = wordInDoc.count()

hashingTF = HashingTF(wordInDoc)
# Calculamos TF
tf = hashingTF.transform(cleanParagraphs)
tf.take(10)
hashingTF.indexOf('year') # daría el valor del número. Es decir qué palabra es.


###SEGUIMOS
from pyspark.mllib.feature import HashingTF
hashingTF = HashingTF(wordInDoc)
wordInDoc = cleanParagraphs.flatMap(lambda p: p.split(' ')).distinct().cache()
hashingTF = HashingTF(wordInDoc.count())
#sacamos las frecuencias por documentos
#Tf me devuelve el sparse matrix. El número es la palabra y el valor la frecuencia
tf = hashingTF.transform(cleanParagraphs)
tf.cache()

#Si queremos ver un índice a que palabra hace referencia
hashingTF.indexOf('the')

#Inverse document matrix: si una palabra aparece mucho en todos los documentos entonces no es signficativa
from pyspark.mllib.feature import IDF
idf = IDF(minDocFreq=2).fit(tf)

#Vamos a multilplicar una matriz por otro
tfidf = idf.transform(tf)
# 
tfidf.take(5) 
# SparseVector(29134, {7489: 4.9538, 8425: 
# 29134 número de palabras en el corpues
# 7489 índice de la palabra
# 4.9538 es el peso de la palabra en el documento

#La asigna un número al RDD, es decir a cada párrafo un índice
# Teengo una tupla con el sparse vector y el índice
tfidf = tfidf.zipWithIndex()
tfidf.first()

#Vamos a poner primero el indice y luego el documento
tfidf = tfidf.map(lambda (doc_tfidf, index): (index, doc_tfidf)).cache()
# le hemos dado la vuelta al vector: (0, SparseVector(29134, {7489: 4.9538, 8425: 4.7174, 22210: 3.4926, 23458: 4.8286}))

#Una función que mire un palabra y vea en que documento está
def change_SparseVector(vec):
    llaves = vec.indices
    valores = vec.values
    llave_valor = zip(llaves, valores)
    return dict(llave_valor)

tfidf = tfidf.map(lambda (indice, sparsevector): (indice, change_SparseVector(sparsevector)) )
tfidf.take(5)

query = [1245, 10978]

def devuelveme_query(query,dic):
    summ = 0
    for q in query:
        if q in dic:
            sum += dic[q] #le suma el peso de esa palabra en el doc
    return summ
        
tfidf.map(lambda (id_doc, diccionario_doc): (id_doc, devuelveme_query(query,diccionario_doc )))

#5 primeros resultados de la búsqueda
tfidf.map(lambda (id_doc, diccionario_doc): (id_doc, devuelveme_query(query,diccionario_doc ))).take(5)





