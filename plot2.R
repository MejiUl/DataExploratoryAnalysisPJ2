#We load the library so we can reshape the Data
library(reshape2) 

#We load the filos into R
NEI <- readRDS("../summarySCC_PM25.rds")
SCC <- readRDS("../Source_Classification_Code.rds")

#We cast the year and SCC to factors
NEI$year <- as.factor(NEI$year)
NEI$SCC <- as.factor(NEI$SCC)

#We melt the data by year and SCC and subset to only grab Baltimore City (fips=24510)
meltData <- melt(NEI[NEI$fips=="24510",], id.vars=c("year","SCC"), measure.vars=c("Emissions"))

#We reshape the data by year adding all the values for each year.
TidySet <- dcast(meltData, year  ~ variable, sum)

#We make the plot and save it to a file
png(file="plot2.png", width=960, height=960)
with(TidySet, barplot(Emissions, main=expression('Total Emission of PM'[2.5]*' by Year of Baltimore City'),xlab="Year", ylab=expression("Total amount of PM"[2.5]*" Produced"), names.arg=TidySet$year, col="steelblue"))
dev.off()