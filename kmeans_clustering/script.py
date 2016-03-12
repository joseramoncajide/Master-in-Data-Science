from pyspark import SparkContext
# coding: utf-8

# In[1]:

sc = SparkContext(appName = 'outliers_jose')


# In[2]:

data = sc.textFile('data/sales_segments.csv.gz')


# In[3]:

data.take(1)


# In[4]:

#para eliminar la primera fila
header = data.first()


# In[5]:

lines = data.filter(lambda line: line != header)


# In[6]:

lines.take(1)


# In[7]:

lines.first().split('^')


# In[8]:

#variables con las que vamo a trabajar en el clustering
fields = ['bookings_seg', 'revenue_amount_seg', 'fuel_surcharge_amount_seg']


# In[9]:

header.split('^').index('bookings_seg')


# In[10]:

#iterar sobre fields para obtener los elementos correspondientes
[header.split('^').index(field) for field in fields]


# In[16]:

def average_fare_tax(line):
    e = line.split('^')
    bookings = float(e[49])
    rev = float(e[51])
    tax = float(e[53])
    
    av_rev = rev/bookings
    av_tax = tax/bookings
    
    return (av_rev, av_tax)


# In[17]:

average_fare_tax(lines.first())


# In[18]:

simple = lines.map(average_fare_tax)


# In[19]:

simple.take(3)


# In[21]:

from pyspark.mllib.clustering import KMeans, KMeansModel


# In[22]:

clusters = KMeans.train(simple, 10)


# In[23]:

clusters.k


# In[24]:

clusters.centers


# In[25]:

clusters.predict((33.56, 7.3))


# In[35]:

bycluster = simple.map(lambda point: (clusters.predict(point), point))


# In[30]:

# devolvemos como clave el cluster y luego los valores av_rev y av_tax
bycluster.take(3)


# In[ ]:

# versión no óptima debido al posible tamaño de cada grupo
# bycluster.groupByKey().take(3)


# In[31]:




# In[ ]:

def calc_avg_reduce()


# In[33]:

# means = bycluster.reduceByKey(calc_avg_reduce)


# In[ ]:




# In[34]:

bycluster_whithones = simple.map(lambda (x,y): (clusters.predict((x,y)), (x,y,1)))


# In[37]:

bycluster_whithones.cache()


# In[38]:

bycluster_whithones.take(3)


# In[45]:

def calc_avg_reduce(acc,p):
    (rev_p, tax_p, c) = p
    (rev_ac, tax_ac, c_ac) = acc
    result = (rev_p + rev_ac, tax_p + tax_ac, c + c_ac)
    return result


# In[46]:

bycluster_whithones.reduceByKey(calc_avg_reduce).take(3)


# In[47]:

avs = bycluster_whithones.reduceByKey(calc_avg_reduce)


# In[48]:

avs.take(3)


# In[51]:

def medias(clust):
    rev_t, tax_t, count = clust
    
    
    return(rev_t / count, tax_t/count, count)


# In[52]:

avs.mapValues(medias).take(3)


# In[53]:

averages = avs.mapValues(medias)


# In[54]:

# no funciona ya que los cluster (primera columna) se ha transformado a float y no encuentra la clave para hacer el join. En una tabbla tenermos enternos y en otras float para el número del cluster
simple.join(averages).take(3)


# In[55]:

# Tenemos los puntos con sus medias. Falta ahora las sd
bycluster_whithones.join(averages).take(3)


# In[60]:

def sq_diffs(p_with_cluster_mean):
    ((rev, tax, n), (av_rev, av_tax, n_cl)) = p_with_cluster_mean
    rev_sqdiff = (rev - av_rev)**2
    tax_sqdiff = (tax - av_tax)**2
    return (rev_sqdiff, tax_sqdiff, 1) #añadimos un 1 para reutilizar en el mapValues posterior  la función calc_avg_reduce definida previamente


# In[61]:

points_w_means_sqdiff = bycluster_whithones.join(averages).mapValues(sq_diffs)


# In[62]:

points_w_means_sqdiff.take(3)


# In[65]:

total_sqdiffs = points_w_means_sqdiff.reduceByKey(calc_avg_reduce)


# In[66]:

total_sqdiffs.take(3)


# In[70]:

from math import sqrt
def stdevs(sqdiffs_percluster):
    sqd_rev_total, sqd_tax_total, n_cl = sqdiffs_percluster
    std_rev = sqrt(sqd_rev_total / n_cl)
    std_tax = sqrt(sqd_tax_total / n_cl)
    return(std_rev, std_tax)


# In[71]:

total_sqdiffs.mapValues(stdevs).take(3)


# In[72]:

#stds de cada cluster
stds_cluster = total_sqdiffs.mapValues(stdevs)


# In[73]:

#
cluster_stats = averages.join(stds_cluster)


# In[75]:

#vemos que hay un cluster con media y desviación 0. Tiene que ver con los grados de libertad
cluster_stats.collect()


# In[77]:

cluster_stats.take(1)


# In[78]:

# Asignamos a cada fila del conjunto de datos los resultados de la table del cluster anterior
bycluster.join(cluster_stats).take(3)


# In[85]:

full = bycluster.join(cluster_stats).cache()


# In[100]:

def zscore(p_w_stats):
    
    p, stats = p_w_stats 
    # point = ((306.85, 159.77)
    #stats = ((431.19140489130996, 184.92581271841314, 353626), (161.81346836246698, 59.0112395191024))))
    rev, tax = p
    means, stdevs = stats
    rev_m, tax_m, _ =  means # Opcional: descarto n_cl, lo reemplazo por un _ ya que no lo necesito.
    rev_std, tax_std = stdevs
    
    if rev_std == 0:
        return rev, tax, 3000, True # en el caso de que una std sea 0 y para que un cluster de un sólo elemento sea considerado como outlier, le asigno un std de 3000

    zscore_rev = (rev - rev_m) / rev_std
    zscore_tax = (tax - rev_m) / tax_std
    
    zscore = sqrt(zscore_rev**2 + zscore_tax**2)
    outlier = zscore > 3
    
    
    
    return rev, tax, zscore, outlier


# In[101]:

zscore(full.first()[1])


# In[102]:

outliers = full.mapValues(zscore)


# In[103]:

outliers.take(3)


# In[104]:

outliers.saveAsTextFile('outliers')


# In[ ]:



