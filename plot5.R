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
keep <- c("fips", "SCC", "Emissions","year")
NEI <- NEI[, names(NEI) %in% keep]

#We keep these columns in this dataframe
del <- c("SCC","EI.Sector")
SCC <- SCC[, names(SCC) %in% del]

#We grep so we catch the On-Road Related Emissions. This category involves all the vehicles that use a motor to move around
#This was done by a hint from the Coursera Forum Section.
On.Road <- grepl("On-Road", SCC$EI.Sector)

#We subset to those emissions only by On.Road emissions.
SCC <- SCC[On.Road,]

#We subset to only Baltimore City
NEI <- NEI[NEI$fips=="24510",]

#We merge both data.frames
NEISCC <- merge(NEI, SCC, by.x="SCC", by.y="SCC")

#We make some whiskerplots for each to see the change in the of motor vehicle emissions.
#Note: The data has a lot of outliers, so I decided to put a limit in the Y axis of 0.4, as
#most of the emissions were lower that 0.4. 
png("plot5.png", width=960, height=960)
plot <- ggplot(NEISCC, aes(year, Emissions))
plot <- plot + geom_boxplot(fill="#CED8F6", outlier.size=1.5, outlier.colour="blue") + ylim(0,0.4)
plot <- plot + labs(title=expression("Motor Vehicles Emissions of PM"[2.5]* " in Baltimore"), x="Year", y=expression("Emission of PM"[2.5]*" Particles"))
plot
dev.off()
