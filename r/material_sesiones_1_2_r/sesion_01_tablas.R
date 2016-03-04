#############################################################################
# Ciencia de datos - R - Parte 01: un paseo por R (+ tablas)
# cgb@datanalytics.com, 2015-06-05
#
# El objetivo de esta sesión es recorrer algunas de las principales aplicaciones
# de R: manipulación de datos, gráficos y estadística. Además, aprenderemos 
# a realizar operaciones habituales y conocidas que hacemos regularmente con Excel 
# sobre tablas usando R.
#############################################################################

setwd("~/Documents/GitHub/Master-in-Data-Science/r/material_sesiones_1_2_r")

#----------------------------------------------------------------------------
# Tablas (dataframes)
#----------------------------------------------------------------------------

## Inspección de un dataframe

# Primera tarea: inspeccionar los contenidos de una tabla 

# El conjunto de datos iris viene de serie en R. Tiene 150 filas que recogen datos de 
#   150 iris (una flor: http://es.wikipedia.org/wiki/Iris_%28planta%29) indicando algunas
#   características de ellas. Este conjunto de datos permite crear un modelo estadístico
#   para distinguir subespecies de iris en función de características métricas de la flor.

iris

# o bien

print(iris, digits = 2, quote = T, right = F)

# otras funciones útiles para inspeccionar data.frames

plot(iris)       # lo representa gráficamente
summary(iris, digits = 2)    # resumen estadístico de las columnas
str(iris)        # "representación textual" del objeto

# ver parte de una tabla: 

head(iris)    # primeras seis filas
tail(iris)    # últimas seis filas

# ayuda en R
?summary

# Ejercicio: Consulta la ayuda de la función head y averigua
# cómo mostrar las diez primeras filas de iris en lugar de las
# seis que aparecen por defecto.

head(iris, 10)

# tamaño de una tabla:
dim(iris)[2]  
nrow(iris) 
ncol(iris)

# nombre de las columnas de una tabla
colnames(iris)  


## Selección de filas y columnas

# con corchetes
iris[,]
iris[1:10,] 
iris[,3:4] 
iris[1:10,3:4]

# Importante: para un dataframe, los corchetes siempre tienen dos partes separadas por una coma:
#   - lo que va antes de la coma se refiere a las filas
#   - lo que va tras la coma, a las columnas

# con corchetes usando el nombre de las columnas
iris[, "Species"] 

class(iris[, "Species"] )
levels(iris[, "Species"] )

# otros operadores: dobles corchetes y dólar
iris[[5]]
iris[["Species"]] 
iris$Species

levels(iris[["Species"]])
barplot(iris$Species,  data=iris)

# Nota: una de las mayores diferencias entre [] y [[]]/$ es que [] permite seleccionar
#   varios elementos, mientras que [[]] y $ solo dejan seleccionar uno.

# con la función subset
subset(iris, Species == "setosa") 
subset(iris, select = Species) 
subset(iris, select = -Species)

# con condiciones lógicas
iris[iris$Species == "setosa",]

# Nota: los ejemplos anteriores dan cuenta de la versatilidad del corchete. Dentro de él pueden 
#   indicarse:
#   - coordenadas (o rangos de coordenadas) de filas y columnas
#   - nombres de columnas
#   - condiciones lógicas para seleccionar filas que cumplan un criterio

iris[iris$Petal.Length < 4,]

plot(iris[,5])
plot(iris[,5],iris[,1])

# Es posible crear otras tablas a partir de una dada:

mi.iris <- iris  # mi.iris es una copia de iris
head(mi.iris)

# ¿qué hay en memoria?

ls()
rm(mi.iris)
ls()


## Ordenación

# por una columna

mi.iris <- iris[order(iris$Petal.Length),]
head(mi.iris)
tail(mi.iris)

# Nota: R no trae ninguna función "de serie" para ordenar por una columna (o varias columnas)
#   Más adelante veremos funciones en paquetes adicionales para hacerlo.
#   En R base "ordenar" es "seleccionar ordenadamente"

# Ejercicio: verificar que mi.iris <- iris[order(-iris$Petal.Length),] ordena decrecientemente

mi.iris <- iris[order(-iris$Petal.Length),]
head(mi.iris)
tail(mi.iris)



# Ejercicio: R permite ordenar por dos columnas porque order lo permite (ver ?order). Por ejemplo,
#   iris[order(iris$Petal.Length, iris$Sepal.Length),]
#   deshace los empates en Petal.Length de acuerdo con Sepal.Length.
#   Crea una versión de iris ordenando por especie y dentro de cada especie, por Petal.Length

mi.iris <- iris[order(iris$Petal.Length, iris$Sepal.Length),]

## Creación y eliminación de columnas

mi.iris$Petal.Area <- mi.iris$Petal.Length * mi.iris$Petal.Width
mi.iris$Petal.Area <- NULL

# Nota: agregar una columna que no existe la crea
#   agregar una columna que existe ¡la reemplaza!
#   asignar NULL a una columna existente la elimina

# la función transform también es útil para crear nuevas columnas
mi.iris <- transform(mi.iris, Petal.Area = Petal.Length * Petal.Width, Sepal.Area = Sepal.Length * Sepal.Width)


# Ejercicio: estudia el conjunto de datos "airquality" (información meteorológica de 
#   cierto año en Nueva York) aplicando las funciones anteriores. En particular, responde a:
#   - ¿Cuál es la temperatura media de esos días?
mean(airquality$Temp)
#   - ¿Cuál es la tempreatura media en mayo?
summary(subset(airquality, Month = 5))
#   - ¿Cuál fue el día más ventoso? ... en mayo
subset(airquality, airquality$Wind == max(airquality[airquality$Month == 5,]$Wind))
max(sort(airquality[airquality$Month == 5, ]$Wind, decreasing = T))
head(max(sort(airquality[airquality$Month == 5, ]$Wind, decreasing = T)), 1)

filtro <- max(airquality[airquality$Month == 5, ]$Wind )
airquality[airquality$Wind == filtro, ]

airquality[airquality$Wind == max(airquality[airquality$Month == 5, ]$Wind ), ]

# Ejercicio: crea una tabla adicional seleccionando todas las columnas menos mes y día; luego
#   haz un plot de ella y trata de encontrar relaciones (cualitativas) entre la temperatura y el viento
#   o el ozono,...

mi.airquality <- airquality[,1:4]
plot(mi.airquality)

#----------------------------------------------------------------------------
# Lectura de datos externos (.csv y similares)
#----------------------------------------------------------------------------

getwd()
setwd("..")       # "sube" al directorio anterior
dir()             # contenidos del directorio "de trabajo"

# La mejor manera de especificar el directorio de trabajo en RStudio es usando
#   los menús (Files > More > Set as working directory)

# Ejercicio: lee el fichero paro.csv usando la función read.table. Comprueba que
#   está correctamente leído usando head, tail, nrow, summary, etc.
#   Pista: ?read.table
#   Pista: los parámetros más importantes son header y dec; a veces, dec y quote.

paro <- read.table('data/paro.csv', header = T, sep = '\t')
head(paro)
str(paro)

#----------------------------------------------------------------------------
# Gráficos básicos
#----------------------------------------------------------------------------

# Gráficos de dispersión

plot(cars$speed, cars$dist)

# Ejercicio: representa gráficamente la anchura del sépalo contra su longitud (en iris)

plot(x=iris$Sepal.Length, y=iris$Sepal.Width)

# Ejercicio: usa main, xlab e ylab para añadir etiquetas (ver ?plot)
# más:

plot(cars$dist, main = "Distancias de...", ylab = "distancia en millas", type = 'b')
lines(cars$dist)
grid()


# Casi todos los aspectos de un gráfico son parametrizables

# Ejercicio: Consulta la ayuda de abline y úsala para añadir
#   líneas a alguno de los gráficos anteriores

abline(h=mean(cars$dist), col = 'red' , lty = 3)


# Ejercicio: usa ??lty para encontrar una página de ayuda en R que muestra
#   gran cantidad de parámetros gráficos. Investiga y usa col, lty y lwd.


## Gráficos de barras

barplot(VADeaths[,2], xlab = "tramos de edad", ylab = "tasa de mortalidad", 
        main = "Tasa de mortalidad en Virginia\nmujer/rural", las = 2, col = c('tomato1','tomato2','tomato3', 'tomato4'))

colors()

# Ejercicio: mejora el gráfico anterior con el parámetro col (de color).

# Una alternativa:

dotchart(t(VADeaths),  main = "Death Rates in Virginia - 1940")
dotchart(VADeaths,  main = "Death Rates in Virginia - 1940")

## Histogramas

hist(iris$Sepal.Width)

# Ejercicio: estudia la distribución de las temperaturas en Nueva York (durante los días en cuestión)

hist(airquality$Temp)

# Ejercicio: usa "col" para mejorar el aspecto del gráfico.

hist(airquality$Temp, col = '#ededed' )
# Ejercicio: usa abline para dibujar una línea vertical roja en la media de la distribución.

abline(v= median(airquality$Temp), col = "#CC0000", lwd=4, lty = 3)

## Diagramas de caja (boxplots)

boxplot(iris$Sepal.Width ~ iris$Species, col = "gray",
        main = "Especies de iris\nsegún la anchura del sépalo")

# La virgínica presenta la distribución más normal
hist(iris[iris$Species == 'virginica',2])



# Nota: la notación y ~ x es muy común en R y significa que vas a hacer algo con y en función de x; en 
#   este caso, "algo" es un diagrama de caja.

# Ejercicio: muestra la distribución de las temperaturas en Nueva York en función del mes.

boxplot(airquality$Temp ~ airquality$Month, col = "gray",
        main = "Temperaturas por mes")

#----------------------------------------------------------------------------
# Ejercicios
#----------------------------------------------------------------------------

# Carga el fichero dat/Olive.txt y ferifica que está correctamente cargado
olive <- read.table('data/Olive.txt', header = T, sep = '\t')

# Selecciona los registros de una región determinada
olive[olive$Region == 'South', ]
hist(olive[olive$Region == 'South', 'eicosenoic'])
hist(olive[olive$Region == 'Sardinia', 'eicosenoic'])
hist(olive[olive$Region == 'North', 'eicosenoic'])

# Haz un boxplot de "eicosenoic" en función de la región
boxplot(olive$eicosenoic ~ olive$Region, main = 'eicosenoic por región') 

# Encuentra un "punto de corte"
# Selecciona solo los registros por debajo de ese punto de corte
no.sur <- olive[olive$eicosenoic < 10, ]
boxplot(eicosenoic ~ Region, data = olive[olive$eicosenoic < 10, ], main = 'eicosenoic por región') 


boxplot(no.sur$linoleic ~ no.sur$Region, main = 'xxx por región')

# library(party)
olive$Area <- olive$Test.Training <- NULL  
head(olive)
plot(ctree(Region~., data=olive))



#----------------------------------------------------------------------------
# Estadística
#----------------------------------------------------------------------------

# Test de Student

summary(sleep)
dim(sleep)
hist(sleep$extra)
boxplot(sleep$extra ~ sleep$group, col = "gray", 
        main = "Diferencias por grupo")

t.test(sleep$extra ~ sleep$group)

# Ejercicio: usar una alternativa no paramétrica: wilcox.test

wilcox.test(sleep$extra ~ sleep$group)
#por encima de 0.5 se rechaza la hipótesis nula 

#doble de sujetos
tmp <- rbind(sleep, sleep)
t.test(tmp$extra ~ tmp$group) 
#ahora es significativo

# Ejercicio: Antes de aplicar el test de Student uno quiere verificar
#   si se cumple la hipótesis de igualdad de las varianzas. Identifica
#   el test necesario (usa, p.e., un buscador de internet) y aplícaselo
#   a sleep


# Regresión lineal
plot(cars$speed, cars$dist)

lm.dist.speed <- lm(cars$dist ~ cars$speed)
lm.dist.speed
abline(lm.dist.speed, col = "red")

summary(lm.dist.speed)

op <- par(no.readonly = TRUE)
par(mfrow = c(2, 2), oma = c(0, 0, 2, 0))
plot(lm.dist.speed)
par(op)


# Ejercicio: Representar gráficamente cars$speed y cars$dist
#   mediante un gráfico de dispersión y añadir luego la recta de regresión
#   usando la función abline. (Pista: hay ejemplos de algo parecido en 
#   ?abline).

# Ejercicio: Hacer una regresión del nivel de ozono sobre la temperatura en Nueva York. 

plot(airquality)

lm.temp.oz <- lm(Temp ~ Ozone, data=airquality)  
summary(lm.temp.oz)
plot(airquality$Ozone, airquality$Temp)
abline(lm.temp.oz, col = "red")

plot(airquality$Solar.R, airquality$Temp)
lm.temp.sol <- lm(Temp ~ Solar.R, data=airquality) 
abline(lm.temp.sol, col = "red")
summary(lm.temp.sol)


## Regresión logística

datos <- as.data.frame(UCBAdmissions)
datos$Admit <- datos$Admit == "Admitted"

str(datos)

modelo.sin.dept <- glm(Admit ~ Gender, data = datos, weights = Freq, family = binomial())
summary(modelo.sin.dept)

modelo.con.dept <- glm(Admit ~ Gender + Dept, data = datos, weights = Freq, family = binomial())
summary(modelo.con.dept)

# Conforme disminuye la pendiente más difícil entrar en cierto departamento. 
# GenderFemale  0.09987    0.08085   1.235    0.217
# DeptB        -0.04340    0.10984  -0.395    0.693    
# DeptC        -1.26260    0.10663 -11.841   <2e-16 ***
# DeptD        -1.29461    0.10582 -12.234   <2e-16 ***
# DeptE        -1.73931    0.12611 -13.792   <2e-16 ***
# DeptF        -3.30648  

plot(ctree(Admit ~ ., data = datos))


plot(ctree(Region~., data=olive))