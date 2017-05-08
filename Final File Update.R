###########
###Setup###
###########
install.packages("randomForest")
install.packages("dplyr")
install.packages("caret")
library(randomForest)
library(dplyr)
library(caret)

setwd("D:/Google Drive/Data Science Project")

#load data
rm(list=ls(all=TRUE))
load("clean_dataset.Rda")
df <- dataset

###############
###Functions###
##############
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

#Simple predict function 
pred.check <- function(x,y) { 
  #"x" is the partition for validation and "y" is the model 
  #so I only need to modify one model when checking 
  pred <- predict(y, x, type="class")
  z <- meanf1(x$IsTerminated, pred) 
  print(z)
}

###################
###Data Cleaning###
###################
#count missing
colSums(is.na(df))
str(df)

#remove missing from outcome variables
df <- df[!is.na(df$pChangeOrderUnmodifiedBaseAndAll),]
df <- df[!is.na(df$IsTerminated),]

#subset relevant variables (drop irrelevant, date-based, and more than 1mm missing)
drop <- names(df) %in% c("CSIScontractID", "StartFiscal_Year", "MinOfSignedDate", 
                         "MinOfEffectiveDate", "unmodifiedSystemequipmentcode",
                         "UnmodifiedUltimateCompletionDate", "UnmodifiedLastDateToOrder",
                         "Unmodifiedmultipleorsingleawardidc", "UnmodifiedLastDateToOrder",
                         "UnmodifiedIsOnlyOneSource", "UnmodifiedIsFollowonToCompetedAction",
                        "UnmodifiedIsCombination", "Unmodifiedaddmultipleorsingawardidc",
                        "UnmodifiedCustomer","UnmodifiedIsFullAndOpen", "UnmodifiedIsSomeCompetition",
                        "UnmodifiedNumberOfOffersReceived",
      #UnmodifiedPlaceCountryISO3 has too many levels. How do fix??
                        "UnmodifiedPlaceCountryISO3", "pChangeOrderUnmodifiedBaseAndAll")
df <- df[!drop]

#change class
df$UnmodifiedDays <- as.numeric(df$UnmodifiedDays)
df$UnmodifiedCurrentCompletionDate <- months(df$UnmodifiedCurrentCompletionDate)
df$UnmodifiedAwardOrIDVcontractactiontype <- as.character(df$UnmodifiedAwardOrIDVcontractactiontype)
df$UnmodifiedSubCustomer <- as.character(df$UnmodifiedSubCustomer)

#recode NA to dummy for those with >100k NA
#Removed vars: #df$UnmodifiedIsFullAndOpen[is.na(df$UnmodifiedIsFullAndOpen)] <- 3
#df$UnmodifiedIsSomeCompetition[is.na(df$UnmodifiedIsSomeCompetition)] <- 2
#df$UnmodifiedNumberOfOffersReceived[is.na(df$UnmodifiedNumberOfOffersReceived)] <- 1000
df$UnmodifiedAwardOrIDVcontractactiontype[is.na(df$UnmodifiedAwardOrIDVcontractactiontype)] <- "Unknown"
df$UnmodifiedSubCustomer[is.na(df$UnmodifiedSubCustomer)] <- "Unknown"

#recode outcome IsTerminated with characters
df$IsTerminated <- ifelse(df$IsTerminated == 0, "Terminated", "Not Terminated")

#turn all char into factor
for(i in colnames(df)) {
  x <- class(df[,i])
  if(x == 'character') {
    df[,i] <- as.factor(df[,i])
  }  
}

#turn all int into num
for(i in colnames(df)) {
  x <- class(df[,i])
  if(x != 'factor') {
    df[,i] <- as.numeric(df[,i])
  }  
}


#too lazy to type out all variables in quotations. Doing it quickly here
cat(colnames(df))#copy and paste this into text line

var <- "LabeledMDAP UnmodifiedIsInternational UnmodifiedContractObligatedAmount UnmodifiedContractBaseAndExercisedOptionsValue UnmodifiedContractBaseAndAllOptionsValue UnmodifiedCurrentCompletionDate IsTerminated UnmodifiedDays UnmodifiedPlatformPortfolio UnmodifiedProductOrServiceArea UnmodifiedSimpleArea UnmodifiedAwardOrIDVcontractactiontype UnmodifiedSubCustomer UnmodifiedTypeOfContractPricing UnmodifiedIsFixedPrice UnmodifiedIsCostBased UnmodifiedIsIncentive UnmodifiedIsAwardFee UnmodifiedIsFFPorNoFee UnmodifiedIsFixedFee UnmodifiedIsOtherFee"
gsub(" ", " + ", var)#copy and paste this into formula
cat(gsub("(\\w+)", '"\\1"', var))

#can only use complete cases
df_comp <- df[complete.cases(df),]

#fix balance
table(df_comp$IsTerminated)

df_term <- df_comp[df_comp$IsTerminated == "Terminated",]
df_non <- df_comp[df_comp$IsTerminated == "Not Terminated",]

set.seed(3)
downsample <- df_term[sample(nrow(df_term),57724),]

df_balanced <- rbind(df_non,downsample)

#####################################
###Partition: test, validate, test###
#####################################
{
  set.seed(100)
  sample_train <- floor(.7*nrow(df_balanced))
  sample_valid <- floor(.15*nrow(df_balanced))
  
  index_train <- sort(sample(seq_len(nrow(df_balanced)), size=sample_train))
  index_not.train <- setdiff(seq_len(nrow(df_balanced)), index_train)
  index_valid  <- sort(sample(index_not.train, size=sample_valid))
  index_test  <- setdiff(index_not.train, index_valid)
  
  df_train  <- df_balanced[index_train, ]
  df_valid <- df_balanced[index_valid, ]
  df_test <- df_balanced[index_test, ]
}

###################
###Decision Tree###
###################

###random forest classification
set.seed(123)
rf <- randomForest(IsTerminated ~ 
                     UnmodifiedIsInternational + 
                     UnmodifiedCurrentCompletionDate + 
                     UnmodifiedDays + 
                     UnmodifiedPlatformPortfolio + 
                     UnmodifiedProductOrServiceArea + 
                     UnmodifiedSimpleArea + 
                     UnmodifiedAwardOrIDVcontractactiontype + 
                     UnmodifiedSubCustomer + 
                     UnmodifiedTypeOfContractPricing, 
                   #REMEMBER TO CHANGE DATASET TO THE ONE YOU WANT
                   data=df_train, 
                   mtry = 2, ntree = 100, 
                   #omit missing values
                   na.action = na.omit, importance = T, 
                   #change to "regression" for continuous 
                   type = "classification")

#check importance of each variable
imp <- as.data.frame(sort(importance(rf)[,1],decreasing = TRUE),optional = T)
names(imp) <- "% Inc MSE"
imp

varImpPlot(rf)

#find optimal mtry 
tuneRF(df_train[,
                #put in all predictors in final RF model
                c("IsTerminated","UnmodifiedIsInternational","UnmodifiedCurrentCompletionDate",
                  "UnmodifiedDays","UnmodifiedPlatformPortfolio",
                  "UnmodifiedProductOrServiceArea","UnmodifiedSimpleArea",
                  "UnmodifiedAwardOrIDVcontractactiontype","UnmodifiedSubCustomer",
                  "UnmodifiedTypeOfContractPricing")], 
       #put in outcome
       df_train$IsTerminated, 
       ntreeTry = 400, na.action = na.omit, 
       mtryStart = 1, stepFactor = 2, 
       improve = 0.001, trace = TRUE, plot = F)

################
###predicting###
################
pred.check(df_train, rf)
pred.check(df_valid, rf)
pred.check(df_test, rf)

###################
###Visualization###
###################

