# Proyectos del Máster en Big Data y Data Science UCM

## 1. Juego_números

### Se trata de adivinar un número al azar o un número puesto por el jugador, del 1 al 100, con tres niveles de dificultad (5, 12 y 20 intentos) y pistas adicionales. Se muestra música si se gana o se pierde y es posible ver las estadísiticas de cada jugador. El juego es resistente a fallos (introducir decimales, strings, etc.)

## 2. Renta per cápita y Esperanza de vida

### Con el csv *Info_pais* se cogen datos de estos indicadores para casi todos los países del mundo y se muestra cómo podemos graficarlos en matplotlib y crear un gif. Además, se explica cómo realizar una regresión lineal ponderada con statsmodels.

## 3. SQL_Modeling_Consult

### Se crea un BBDD relacional en MySQL con varios triggers para conectar los campos de las distintas tablas entre sí. Posteriormente se insertan datos en la BBDD y se realizan consultas sobre ella, así como se crean nuevas tablas. Por último, se escribe un procedure y un event para guardar periódicamente la información de ciertas tablas en un nuevo dataset.

## 4. acvil_query

### Se realizan varias querys complejas en MongoDB para convertir un dataset a un formato embedido y realizar consultas, joins y cálculos sobre este. Los datos que se han utilizado son también de Animal Crossing, en los ficheros *csvjson* y *housewares*.

## 5. Tarea Estadística

### Se realiza estadística descriptiva y varios contrastes de hipótesis paramétricos y no paramétricos para evaluar información acerca de un experimento sobre el nivel de glucosa en pacientes jóvenes y adultos. Las librerías utilizadas son principalmentes pandas, numpy, seaborn, matplotlib, scipy y statsmodels.

## 6. Tarea Minería de datos

### En el ejercicio 1 se realiza un análisis descriptivo exhaustivo de datos sociodemográficos que pueden determinar el volumen respiratorio en una población joven. Posteriormente se realiza una selección de variables y de diferentes modelos de regresión lineal múltiple mediante validación cruzada y se escoge el más preciso.
### En el ejercicio 3 se toman datos históricos de muertes en españa, seleccionando aquellas no causadas por tumores, una de las causas mayoritarias de muerte no natural. Se realizan varias descomposiciones estacionales y varios modelos de suavizado y SARIMA para analizar la serie -todos son univariantes ya que no hemos tomado datos adicionales-. Para su comparación se tienen en cuenta el RMSE y el test de Ljung-Box tomando diferentes períodos de tiempo para el test.
### En el Ejercicio 4 se toman datos sobre variables relacionadas con el cáncer de mama y se realiza una agrupación mediante ACP de las variables, tomando 3 componentes que alcanzan superan el 70% de la varianza y se intentan interpretar. Posteriormente se evalúa un modelo de regresión logística pro cross-validación con statsmodels y con sklearn con estos tres componentes para predecir la probabilidad de no tener cáncer, el cual logra una precisión del 96% muy bien balanceada.
### En el Ejercicio 5 se toman datos económicos, políticos y sociodemográficos de municipios españoles, se agrupan por CCAA y se crea una función que encuentra las mejores variables para minimizar la silueta del algoritmo KMeans, especificando el número de variables que se quieren (10, en este caso) y un rango de de clusters a buscar. Además, también se exploran modelos de clustering jerárquico. Por último se observa la relación de los clusters con las variables seleccionadas y la dirección que toman en la explicación de los clusters y se interpretan los resultados.

## 7. Tarea ML

### Propuesta para el concurso Pump It Up! (https://www.drivendata.org/competitions/7/pump-it-up-data-mining-the-water-table/page/25/), Score: 0.7780. Se lidia con el problema de missings, outliers y cardinalidad principalmente con la información geográfica del dataset

## 8. Tarea text mining

### Ejercicio de preprocessing, exploración, vectorización y modelización de datos de tweets del challenge *ProfNER-ST: Identification of professions & occupations in Health-related Social Media*

## 9. Visualization

### Ejercicio de data cleaning y visualización y análisis de cómo ha afectado la pandemia a la evolución de las series temporales de contratación via ETTs en varios sectores económicos

## 10. Spark_Example

### Ejercicio sencillo de análisis de datos como introducción a PySpark

## 11. Tarea Deep Learning

### Ejercicio introductorio de Redes Neuronales para investigar como 1) técnicas de regularización y optimización pueden mejorar la predicción 2) Cómo la convolución, el pooling y el data augmentation son herramientas fundamentales para la clasificación de imágenes y 3) las diferencias entre diversos tipos de RNN, especialmente GRU y LSTM.

