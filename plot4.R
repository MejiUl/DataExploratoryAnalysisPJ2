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

#We grep so we catch the Coal Combustion Related Emissions in the EI.Sector column
#This yields all the activities of coal combustion related Emissions, you can run 
#SCC$EI.Sector to check this out
coalVector <- grepl("[Cc]oal", SCC$EI.Sector)


#We subset the coalRelated emissions and also the Non-Related Coal Emissions
coalRelatedSCC <- SCC[coalVector,]
norRelatedCoalSCC <- SCC[!coalVector,]
#coalRelatedSCC$EI.Sector

#We merge the data so we can map the NEI emissions with the Coal/Non.Coal Related emissions
coalRelatedNEI <- merge(NEI, coalRelatedSCC, by.x="SCC", by.y="SCC")
#noncoalRelatedNEI <- merge(NEI, norRelatedCoalSCC, by.x="SCC", by.y="SCC")

#We melt the data so we can summarise
meltDataCoalRelated <- melt(coalRelatedNEI, id.vars=c("year"), measure.vars=c("Emissions"))
meltDataWhole <- melt(NEI, id.vars=c("year"), measure.vars=c("Emissions"))

#WE summarise by adding all the emissions from coal and Non.Coal related emissions.
coalEmissionsByYear <- dcast(meltDataCoalRelated, year ~ variable, sum)
totalEmissionsByYear <- dcast(meltDataWhole, year ~ variable, sum)

#We get the Non.Coal Related emissions by substracting the Total Emissions minus Coal Related Emissions
#This was done this way because merging the NEI with SCC for Non-Coal Emissions takes too much memory to complete and 
#We also name the columns
EmissionsByYear <- cbind(coalEmissionsByYear, (totalEmissionsByYear - coalEmissionsByYear)$Emissions)
names(EmissionsByYear) <- c("Year", "CoalEmissions", "NonCoalEmissions")

#mEmissionsByYear <- melt(EmissionsByYear, id.vars=c("Year"), measure.vars=c("CoalEmissions", "NonCoalEmissions"))

#We plot only the coal-Related Emissions, but it's easy to plot the Non-Coal Related Emissions too
png(file="plot4.png", width=960, height=960)
plot <- ggplot(EmissionsByYear, aes(x=Year, y=CoalEmissions))
plot <- plot + geom_point(size=3, color="steelblue")
plot <-plot + labs(title=expression("Total Coal-Combustion PM"[2.5]*" Emissions by Year"), x="Year", y=expression("Total Emissions of PM"[2.5]))
plot
dev.off()



