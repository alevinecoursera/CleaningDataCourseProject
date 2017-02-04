# Course Project for Getting and Cleaning data
**Usage** 

run_analysis.R tidies the datasets in the test and train directories
and outputs a file "tidyData.txt"

features.txt and activity_labels.txt are used by run_analysis.R to appropriately 
name and tidy the datasets in test/ and train/.

**To view tidy results in R:**

tidyData <- read.table("tidyData.txt")

View(tidyData)


