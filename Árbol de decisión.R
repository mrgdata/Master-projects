
# EJEMPLO TITANIC

library(ROCR)
library(stats)
library(rms)
library(SimDesign)
library(rpart)
library(rpart.plot)
library(rattle)
library(titanic)
library(tidyverse)
data("titanic_train")
View(titanic_train)

is.numeric(titanic_train$Pclass)
titanic_train$Pclass <- as.character(titanic_train$Pclass)
arbol <- rpart(formula = Survived ~ Pclass + Age + Sex, data =titanic_train, method="class")
fancyRpartPlot(arbol)

pred_arbol <- predict(arbol, type="class")
titanic_pred <- cbind(pred_arbol, titanic_train)
View(titanic_pred)
a <- titanic_pred$pred_arbol
b <-titanic_pred$Survived
a <- as.numeric(a)
bias(b, a)

# Se predice ligeramente mas de lo que en realidad sobrevivieron (-0.97) y la correlacion es moderada (0.60)

# Si queremos saber si un pasajero determinado usamos predict(). Por ejemplo, una niÃ±a de 5 aÃ±os de clase alta:
typeof(titanic_pred$Pclass)
predict(object= arbol,
        df <- data.frame(Age=5, Sex="female", Pclass="3"),
        type="class")

# Comparamos con un modelo logit

md1 <- lrm(Survived ~ Pclass + Age + Sex, data =titanic_train)
md1
pred_md1 <- predict(md1, titanic_train, type="lp")
titanic_pred0 <- cbind(pred_md1, titanic_pred)

# Vamos a comparar las curvas ROC para visualizarlo mejor
titanic_pred0 <- na.omit(titanic_pred0)
titanic_pred0$pred_arbol <- as.numeric(titanic_pred0$pred_arbol)
pred1 <- prediction(titanic_pred0$pred_md1, titanic_pred0$Survived)
pred2 <- prediction(titanic_pred0$pred_arbol, titanic_pred0$Survived)

perf1 <- performance(pred1, measure = "tpr", x.measure= "fpr")
plot(perf1)
perf2 <- performance(pred2, measure = "tpr", x.measure= "fpr")
plot(perf2)

# confirmamos lo anterior observando las ROCs
plot(perf1, col= "blue", main="Azul: árbol de decisión, Verde: logit")
par(new=TRUE)
plot(perf2, col = "forestgreen")

