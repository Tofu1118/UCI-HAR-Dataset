## This project is created with the working directory set
## to the "UCI HAR Dataset" folder. Read file commands in
## the script should accordingly be adjusted if the script 
## were to run in environments with different directory
## setups.

library(dplyr)

## Reading txt files from the directory
if (!exists("features")) {
  features <- read.table("features.txt", sep = " ")
}

if (!exists("X_train")) {
  X_train <- read.table("train/X_train.txt")
}

if (!exists("Y_train")) {
  Y_train <- read.table("train/y_train.txt")
}

if (!exists("X_test")) {
  X_test <- read.table("test/X_test.txt")
}

if (!exists("Y_test")) {
  Y_test <- read.table("test/y_test.txt")
}

if (!exists("subject_test")) {
  subject_test <- read.table("test/subject_test.txt")
}

if (!exists("subject_train")) {
  subject_train <- read.table("train/subject_train.txt")
}

## Combining X, Y, and subject data
X_combined <- rbind(X_test, X_train)
Y_combined <- rbind(Y_test, Y_train)
subject_combined <- rbind(subject_test, subject_train)

## Creating the rough data frame
rough_df <- data.frame(cbind(subject_combined, Y_combined, X_combined))
names(rough_df) <- c("Subject", "Activity", features[,2])

## Selecting mean and std data columns
pruned_df<-rough_df[c(1,2,grep("[ms][et][ad][n()]", names(rough_df)))]

## Arranging rows according to subject and activity
pruned_df <- arrange(pruned_df, Subject, Activity)

## Replacing activity numbers with descriptive activity terms
pruned_df$Activity[pruned_df$Activity == "1"] <- "Walking"
pruned_df$Activity[pruned_df$Activity == "2"] <- "Walking Upstairs"
pruned_df$Activity[pruned_df$Activity == "3"] <- "Walking Downstairs"
pruned_df$Activity[pruned_df$Activity == "4"] <- "Sitting"
pruned_df$Activity[pruned_df$Activity == "5"] <- "Standing"
pruned_df$Activity[pruned_df$Activity == "6"] <- "Laying"

## Creating descriptive variable names
names(pruned_df) <- sub("tBody", "Time Domain Body ", names(pruned_df))
names(pruned_df) <- sub("fBody", "Frequency Domain Body ", names(pruned_df))
names(pruned_df) <- sub("tGravity", "Time Domain Gravity ", names(pruned_df))
names(pruned_df) <- sub("fGravity", "Frequency Domain Gravity ", names(pruned_df))
names(pruned_df) <- sub("Acc", "Acceleration ", names(pruned_df))
names(pruned_df) <- sub("Jerk", "Jerk ", names(pruned_df))
names(pruned_df) <- sub("Gyro", "Gyroscope ", names(pruned_df))
names(pruned_df) <- sub("Mag", "Magnitude ", names(pruned_df))
names(pruned_df) <- sub("mean\\(\\)", "Signal Mean Value ", names(pruned_df))
names(pruned_df) <- sub("std\\(\\)", "Signal Standard Deviation ", names(pruned_df))
names(pruned_df) <- sub("meanFreq\\(\\)", "Signal Mean Frequency ", names(pruned_df))
names(pruned_df) <- gsub("-", "", names(pruned_df))


## Split by subject to large list
subject_split <- split(pruned_df, pruned_df$Subject)

## Create tidy data frame
tidy_df <- as.data.frame(matrix(ncol = 81))
names(tidy_df) <- names(pruned_df)

## Split large list by activity, find average value and
## add average values to tidy data frame
for (subject_data in subject_split) {
  activity_split <- split(subject_data, subject_data$Activity)
  for (activity_data in activity_split) {
    tidy_df <- rbind(tidy_df, cbind(activity_data[1,1:2], t(as.data.frame(colMeans(activity_data[1:length(activity_data[,1]), 3:length(activity_data[1,])])))))
  }
}

tidy_df <- tidy_df[2:length(tidy_df[,1]),]
rownames(tidy_df) <- c()

write.csv(tidy_df, file = "tidy_df.csv")