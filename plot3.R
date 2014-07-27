#We load the library so we can reshape the Data
library(reshape2) 
library(ggplot2)

#We load the filos into R
NEI <- readRDS("../summarySCC_PM25.rds")
SCC <- readRDS("../Source_Classification_Code.rds")

#We cast the year and SCC to factors
#NEI$year <- as.factor(NEI$year)
NEI$SCC <- as.factor(NEI$SCC)
NEI$type <- as.factor(NEI$type)

#We subset to Baltimore City Only
NEI <- NEI[NEI$fips=="24510",]

#We melt the data so we can summarise
meltData <- melt(NEI[NEI$fips=="24510",], id.vars=c("year","type"), measure.vars=c("Emissions"))

#We summarise the data getting the total amount of PM 2.5 Emissions produced.
TidyData <- dcast(meltData, year + type ~ variable, sum)

#We use the ggplot2 system to plot the graph, we make a facet and also color by type (Point, Non-Point, ...)
png(file="plot3.png", width=1050, height=960)
plot <- ggplot(TidyData, aes(year, Emissions, color=type)) + geom_point()
plot <- plot + facet_grid(.~type) + geom_smooth(method="lm")
plot <- plot + labs(title=expression("Emissions of PM"[2.5]*" By Year by Type for Baltimore City"), x=expression("Type of PM"[2.5]*"Partice - Years"), y=expression("Total Emission of PM"[2.5]*" per Year"))
plot
dev.off()