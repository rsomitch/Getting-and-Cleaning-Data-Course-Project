
##### Step 1 #####

rm(list = ls())

#1. Set directory and load packages and zipfiles
#2. Set lables and extract means and standard deviations
#3. Setup the Test Activity Data
#4. Setup the Training Activity data
#5. Merge the Test and the Training Data to setup the Tidydata

library(reshape2)

# Set your working directory to your 
setwd("C:/Users/rockw_000/Desktop/MyRScripts")

packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
directory <- getwd()

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, file.path(directory, "courseproject.zip"))
unzip(zipfile = "courseproject.zip")

##### Step 2 #####

activity_labels <- fread(file.path(directory, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("Number", "Activity"))

features <- fread(file.path(directory, "UCI HAR Dataset/features.txt")
                  , col.names = c("Number", "Feature Type"))


STD <- grep("(mean|std)\\(\\)", features[, `Feature Type`])

STD_Features <- gsub('[()]', '',features[STD, `Feature Type`])

##### Step 3 #####

Xtest <- fread(file.path(directory, "UCI HAR Dataset/test/X_test.txt"))[, STD, with = FALSE]

data.table::setnames(Xtest, colnames(Xtest), STD_Features)

Ytest <- fread(file.path(directory, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))

subjecttest <- fread(file.path(directory, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("Number"))

test <- cbind(subjecttest, Xtest, Ytest)

##### Step 4 #####

Xtrain <- fread(file.path(directory, "UCI HAR Dataset/train/X_train.txt"))[, STD, with = FALSE]

data.table::setnames(Xtrain, colnames(Xtrain), STD_Features)

Ytrain <- fread(file.path(directory, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))

Subjecttrain <- fread(file.path(directory, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("Number"))

train <- cbind(Subjecttrain, Ytrain, Xtrain)


##### Step 5 #####

Test_Train <- rbind(train, test)

Test_Train[["Activity"]] <- factor(Test_Train[, Activity], levels = activity_labels[["Number"]]
                                 , labels = activity_labels[["Activity"]])

Test_Train[["Number"]] <- as.factor(Test_Train[, Number])

Test_Train <- reshape2::melt(data = Test_Train, id = c("Number", "Activity"))

Test_Train <- reshape2::dcast(data = Test_Train, Number + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = Test_Train, file = "TidyData.csv", quote = FALSE)

Tidydata <- read.csv("TidyData.csv")

View(Tidydata)

write.table("TidyData.csv", row.names = FALSE)
