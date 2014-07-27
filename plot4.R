#We load the library so we can reshape the Data
library(reshape2) 
library(ggplot2)

#We load the filos into R
NEI <- readRDS("../summarySCC_PM25.rds")
SCC <- readRDS("../Source_Classification_Code.rds")

#We cast the year and SCC to factors
NEI$year <- as.factor(NEI$year)
NEI$SCC <- as.factor(NEI$SCC)
NEI$type <- as.factor(NEI$type)

#We keep these columns in the dataset
keep <- c("SCC", "Emissions","year")
NEI <- NEI[, names(NEI) %in% keep]

#We keep these columns in this dataframe
del <- c("SCC","EI.Sector")
SCC <- SCC[, names(SCC) %in% del]

#We grep so we catch the Coal Combustion Related Emissions
coalVector <- grepl("[Cc]oal", SCC$EI.Sector)

coalRelatedSCC <- SCC[coalVector,]
#norRelatedCoalSCC <- SCC[!coalVector,]

coalRelatedNEI <- merge(NEI, coalRelatedSCC, by.x="SCC", by.y="SCC")
#noncoalRelatedNEI <- merge(NEI, norRelatedCoalSCC, by.x="SCC", by.y="SCC")

meltDataCoalRelated <- melt(coalRelatedNEI, id.vars=c("year"), measure.vars=c("Emissions"))
meltDataWhole <- melt(NEI, id.vars=c("year"), measure.vars=c("Emissions"))



coalEmissionsByYear <- dcast(meltDataCoalRelated, year ~ variable, sum)
totalEmissionsByYear <- dcast(meltDataWhole, year ~ variable, sum)

EmissionsByYear <- cbind(coalEmissionsByYear, (totalEmissionsByYear - coalEmissionsByYear)$Emissions)
names(EmissionsByYear) <- c("Year", "CoalEmissions", "NonCoalEmissions")

#mEmissionsByYear <- melt(EmissionsByYear, id.vars=c("Year"), measure.vars=c("CoalEmissions", "NonCoalEmissions"))


png(file="plot4.png", width=960, height=960)
#with(mEmissionsByYear[mEmissionsByYear$variable=="CoalEmissions",]   , plot(Year, value, type="n"))
plot <- ggplot(EmissionsByYear, aes(x=Year, y=CoalEmissions))
plot <- plot + geom_point(size=3, color="steelblue")
plot <-plot + labs(title=expression("Total Coal-Combustion PM"[2.5]*" Emissions by Year"), x="Year", y=expression("Total Emissions of PM"[2.5]))
plot
#with(mEmissionsByYear[mEmissionsByYear$variable=="NonCoalEmissions",], lines(Year, value, type="p", col="blue"))
dev.off()



