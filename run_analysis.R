#Creates a tidy dataset by merging the training and test data
#and averages over the subject, activities
#Author: Aaron Levine

library(reshape)

#read in data
subject_test <- read.table("test/subject_test.txt");
X_test <- read.table("test/X_test.txt",sep="");
y_test <- read.table("test/y_test.txt");
subject_train <- read.table("train/subject_train.txt");
X_train <- read.table("train/X_train.txt",sep="");
y_train <- read.table("train/y_train.txt");

df_test <-cbind(subject_test,y_test,X_test); #creates 2947x563 data frame
df_train <-cbind(subject_train,y_train,X_train); #creates 7352x563 data frame

df <- rbind(df_test,df_train); #creates 10299x563 data frame

#get a vector of column headers
col_names <- c("Subject");
col_names <- append(col_names,"Activity");
feature_names <- scan("features.txt",what="",sep="\n");
feature_names <- strsplit(feature_names," ");
secondElement <- function(x){x[2]};
feature_names <- sapply(feature_names,secondElement);
col_names <- append(col_names,feature_names);
#apply names to df
names(df) <- col_names;

#vector of column names to keep
namesKeep <- col_names[1]; #first column is Subject
namesKeep <- append(namesKeep,col_names[2]); #next column is activity
for (i in 3:563){
    if(grepl("-mean()",col_names[i],fixed=TRUE) | grepl("-std()",col_names[i],fixed=TRUE)){
        namesKeep <- append(namesKeep,col_names[i]);
    }
}
#only keep mean and sd of each measurement
df_MeanSd <- df[namesKeep]; #creates 10299x101 data frame

#replace names of activities
activity_names <- scan("activity_labels.txt",what="",sep="\n");
activity_names <- strsplit(activity_names," ");
activity_names <- sapply(activity_names,secondElement);
activities <- as.character(df_MeanSd$Activity);
#replace numbers in activities with names in activity labels
for (i in 1:6){
    activities <- sapply(activities,function(x){gsub(as.character(i),activity_names[i],x)});
}
df_MeanSd$Activity <- activities;

#At this point, biggest problem is that some of the names
#have "-" or "()" which makes it hard to get the features
#using "$". Also, Body is repeated twice in some of the names
#for no apparent reason.
#In my opinion, the descriptions in the codebook
#are sufficient and the column names do not need to be cleaned
#further after this operation

#replace "-" with "_"
namesKeep <- sapply(namesKeep,function(x){chartr("-","_",x)});
#replace "()" with ""
namesKeep <- sapply(namesKeep,function(x){gsub("\\(\\)","",x)});
#replace BodyBody with Body
namesKeep <- sapply(namesKeep,function(x){gsub("BodyBody","Body",x)});
names(df_MeanSd) <- namesKeep;

#Now, make dataset tidy by averaging values for each activity and each subject

#Melt data with Hadley Wickham's R package
df_MeanSdMelted <-melt(df_MeanSd,id=c("Subject","Activity"));
#Average data for each subject, activity
df_MeanSdMelted <- cast(df_MeanSdMelted,Subject+Activity~variable,mean);
#Write tidy data frame
write.table(df_MeanSdMelted,file="tidyData.txt",row.names=FALSE);
