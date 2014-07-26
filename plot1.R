library(reshape2)
NEI <- readRDS("../summarySCC_PM25.rds")
SCC <- readRDS("../Source_Classification_Code.rds")

NEI$year <- as.factor(NEI$year)
NEI$SCC <- as.factor(NEI$SCC)

#NEISCC <- merge(NEI, SCC, by.x="SCC", by.y="SCC")

meltData <- melt(NEI, id.vars=c("year","SCC"), measure.vars=c("Emissions"))
TidySet <- dcast(meltData, year ~ variable, sum)

with(TidySet, barplot(Emissions, main=expression('Total Emission of PM'[2.5]*' by Year'),xlab="Year", ylab=expression("Total amount of PM"[2.5]*" Produced"), names.arg=TidySet$year, col="steelblue"))
