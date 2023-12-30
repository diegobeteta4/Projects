# Loading R packages that are needed for some calculations below
install.packages("ResourceSelection")
install.packages("pROC")
install.packages("rpart.plot")

# Loading credit card default data set
credit_default <- read.csv(file='credit_card_default.csv', header=TRUE, sep=",")

print("data set (first 5 observations)")
head(credit_default, 5)

print("Number of columns")
ncol(credit_default)
print("Number of rows")
nrow(credit_default)

# Converting appropriate variables to factors  
credit_default <- within(credit_default, {
   default <- factor(default)
   sex <- factor(sex)
   education <- factor(education)
   marriage <- factor(marriage)
   assets <- factor(assets)
   missed_payment <- factor(missed_payment)
})

head(credit_default, 5)

# Partition the data set into training and testing data
samp.size = floor(0.70*nrow(credit_default))

# Training set
print("Number of rows for the training set")
train_ind = sample(seq_len(nrow(credit_default)), size = samp.size)
train.data1 = credit_default[train_ind,]
nrow(train.data1)

# Testing set 
print("Number of rows for the validation set")
test.data1 = credit_default[-train_ind,]
nrow(test.data1)

# Create the complete model
model1 <- glm(default ~ credit_utilize + assets + missed_payment, data = credit_default, family = "binomial")

summary(model1)

# Predict default or no_default for the data set using the model
default_model_data <- credit_default[c('credit_utilize', 'assets', 'missed_payment')]
pred <- predict(model1, newdata=default_model_data, type='response')

# If the predicted probability of default is >=0.50 then predict credit default (default='1'), otherwise predict no credit 
# default (default='0') 
depvar_pred = as.factor(ifelse(pred >= 0.5, '1', '0'))

# confusion matrix
conf.matrix <- table(credit_default$default, depvar_pred)[c('0','1'),c('0','1')]
rownames(conf.matrix) <- paste("Actual", rownames(conf.matrix), sep = ": default=")
colnames(conf.matrix) <- paste("Prediction", colnames(conf.matrix), sep = ": default=")

# confusion matrix
print("Confusion Matrix")
format(conf.matrix,justify="centre",digit=2)

library(ResourceSelection)


print("Hosmer-Lemeshow Goodness of Fit Test")
hl = hoslem.test(model1$y, fitted(model1), g=50)
hl

print("The Hosmer-Lemeshow test results with a high p-value of 0.9945 suggest that the logistic regression model fits the data well")

library(pROC)

labels <- credit_default$default
predictions <- model1$fitted.values

roc <- roc(labels ~ predictions)

print("Area Under the Curve (AUC)")
round(auc(roc),4)

print("ROC Curve")
# True Positive Rate (Sensitivity) and False Positive Rate (1 - Specificity)
plot(roc, legacy.axes = TRUE)

print("An AUC of 0.9874 indicates excellent model performance. It means that the model has a 98.74% chance of correctly distinguishing between a positive case (default) and a negative case (no default). This high AUC value suggests that the model is highly accurate in making predictions")

print("Prediction: Credit utilization: 35%, owns a car, and has missed payments in the last 3 months")
newdata1 <- data.frame(credit_utilize=0.35, assets='1', missed_payment='1')
pred1 <- predict(model1, newdata1, type='response')*100
round(pred1, 1)

print("Prediction: Credit utilization: 30%, owns a car and a house, and has not missed a payment in the last 3 months")
newdata2 <- data.frame(credit_utilize=0.30, assets='3', missed_payment='0')
pred2 <- predict(model1, newdata2, type='response')*100
round(pred2, 1)

print("Prediction: Credit utilization: 60%, owns a car and a house, and has missed a payment in the last 3 months")
newdata3 <- data.frame(credit_utilize=0.60, assets='3', missed_payment='1')
pred3 <- predict(model1, newdata3, type='response')*100
round(pred3, 1)


