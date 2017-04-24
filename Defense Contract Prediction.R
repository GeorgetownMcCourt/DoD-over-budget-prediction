rm(list=ls(all=TRUE))
library(randomForest)
library(dplyr)

setwd("C:/Users/bruis/OneDrive/Documents/Schoolwork/Intro to Data Science/Final Project")

full.data <- read.csv("https://raw.githubusercontent.com/lipseylc/DoD-over-budget-prediction/master/data_for_test.csv")

#Out of curiousity, what are we looking at here?
#full.data as loaded is 100,000 observations, but that includes a lot of contracts that are still in progress
#These lines estimate how many meet key conditions for our analysis
nrow(full.data[full.data$IsClosed == "Closed",]) # 2341 contracts are closed out
nrow(full.data[full.data$Term == "Terminated",]) # 853 of them were terminated
nrow(full.data[full.data$Term == "Terminated" & full.data$IsClosed == "Closed",]) # Al 853 terminated were marekd as closed (phew)

#filter full data down to only those contracts that have been completed/closed
full.data <- full.data[full.data$IsClosed == "Closed",]


####
#### Methods ####
####


#Mean
meanf1 <- function(actual, predicted){
  #Mean F1 score function
  #actual = a vector of actual labels
  #predicted = predicted labels
  
  classes <- unique(actual)
  results <- data.frame()
  for(k in classes){
    results <- rbind(results, 
                     data.frame(class.name = k,
                                weight = sum(actual == k)/length(actual),
                                precision = sum(predicted == k & actual == k)/sum(predicted == k), 
                                recall = sum(predicted == k & actual == k)/sum(actual == k)))
  }
  results$score <- results$weight * 2 * (results$precision * results$recall) / (results$precision + results$recall) 
  return(sum(results$score))
}

#Function to shuffle data and cut into folds
#Copied from version emailed out to class after Homework 2
kfolds.index <- function(n, k, random = TRUE){
  # Returns a vector of labels for each of k-folds. 
  # Useful for setting up k-folds cross validation
  #
  # Args:
  #       n: data size
  #       k: k-folds
  #       random: whether folds should be sequential or randomized (default)
  #
  # Returns:
  #       Vector of numeric labels
  
  #create row index
  row.id <- 1:n
  
  #Decide splits
  break.id <- cut(row.id, breaks = k, labels = FALSE)
  
  #Randomize
  if(random == TRUE){
    row.id <- row.id[sample(row.id, replace = FALSE)]
  }
  
  #Package up
  out <- data.frame(row.id = row.id, folds = break.id)
  out <- out[order(out$row.id), ]
  return(out[,2])
}  



####
#### Preliminary Analysis section ####
####


#Recode Contract ID as a factor
full.data$CSIScontractID <- as.factor(full.data$CSIScontractID)

#prelimnary linear model to see general contributory impact of other variables
# Note that at the moment
summary(lm(Term ~ Who + What + Intl + PSR + FxCb + Fee + Dur + SingleOffer + Soft +
     UCA + CRai + Veh + UnmodifiedNumberOfOffersReceived, data = full.data))


####
#### Model Training Section ####
####




#set number of folds to be used in k-folds analysis
j <- 10

#Partition training data into 10 folds to train the model for
full.data$folds <- kfolds.index(nrow(full.data), j)

#Run kfolds, cycling through each k has the holdout
for(k in unique(full.data$folds)){
  
  #Cut train/test: k is the holdhout
  this.train <- full.data[full.data$folds != k, ]
  this.test <- full.data[full.data$folds == k, ]
  
  #estimate model, using a random forest with 200 trees (no notable benefit from 500), and mtry = 3
  #...as previous determined from the tuneRF function (commented out here)
  #tuneRF(x = this.train[,c(4,8:18)], y = this.train$Term, step = 1.5, trace = TRUE)
  this.rf <- randomForest(Term ~  Who + What + Intl + PSR + FxCb + Fee + Dur + SingleOffer + Soft +
                            UCA + CRai + Veh + UnmodifiedNumberOfOffersReceived, data = this.train,
                          mtry = 3, ntree = 200,
                          #importance = TRUE, #uncomment this line to determine variable importance
                          type = "classification")
  
  #Commented out here: report out the relative importance of each variable
  #Useful to determine which variables can be dropped (as all of the point estimates were here)
  #round(importance(full.rf), 2)
  
  
  #Use model estimate to predict the holdout values for this k
  this.pred <- predict(this.rf, this.test, type = "class")
  
  #Print the meanf1 accuracy measure for this iteration of the model
  print(paste0("meanF1 (holdout group ", k,") = ", meanf1(this.pred, this.test)))
  
}




######Outside of loop test

this.rf <- randomForest(Term ~  Who + What + Intl + PSR + FxCb + Fee + Dur + Soft +
                          UCA + CRai + Veh + UnmodifiedNumberOfOffersReceived, data = full.data,
                        mtry = 3, ntree = 200,
                        #importance = TRUE, #uncomment this line to determine variable importance
                        type = "classification")


#Gets error: "Error in na.fail.default(list(Term = c(2L, 2L, 2L, 2L, 2L, 2L, 2L, 2L,  : 
#             missing values in object"