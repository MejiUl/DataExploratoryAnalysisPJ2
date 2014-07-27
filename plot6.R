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

#We grep so we catch the On-Road Related Emissions
On.Road <- grepl("On-Road", SCC$EI.Sector)

#We subset to those emissions only by On.Road emissions.
SCC <- SCC[On.Road,]

#We subset for Baltimore and Los Angeles Cities
NEIBaltimore  <- NEI[NEI$fips=="24510",]
NEILosAngeles <- NEI[NEI$fips=="06037",] 

#We merge to their respective NEI and SCC
NEISCCBaltimore <-  merge(NEIBaltimore, SCC, by.x="SCC", by.y="SCC")
NEISCCLosAngeles <- merge(NEILosAngeles, SCC, by.x="SCC", by.y="SCC")

#We melt the data so we can summarise
meltBaltimore <-  melt(NEISCCBaltimore, id.vars=c("year"), measure.vars=c("Emissions"))
meltLosAngeles <- melt(NEISCCLosAngeles, id.vars=c("year"), measure.vars=c("Emissions"))

#We get the total amount of emissions for each year for each city
NEIBaltimoreLong <- dcast(meltBaltimore, year ~ variable, sum)
NEILosAngelesLong <- dcast(meltLosAngeles, year ~ variable, sum)

#As the plot we are goint to use (barplot), needs to be in a table, we first create a matrix
BaltLA <- matrix(nrow=2,ncol=4, dimnames=list(c("Baltimore", "Los Angeles"),c("1999","2002","2005","2008")))

#We fill the matrix with the values of the emissions of each year. 
#We divide by the base year (1999) and multiply by 100 to get the change in percentage of the PM emissions
BaltLA[1,] <- t((NEIBaltimoreLong$Emissions/NEIBaltimoreLong$Emissions[1])*100)
BaltLA[2,] <- t((NEILosAngelesLong$Emissions/NEILosAngelesLong$Emissions[1])*100)

#We cast the matrix to table so we can plot
BaltLA <- as.table(BaltLA)

#We create the plot
png(file="plot6.png", width=960, height=960)
par(xpd=FALSE)
barplot(BaltLA, main=expression("Change of PM"[2.5]*" Emissions Over The Years"), xlab="Year", ylab=expression("Change in % of PM"[2.5]* " Emissions"),col=c("#CED8F6", "steelblue"), beside=TRUE)
legend(9.8,115, pch=15, legend=row.names(BaltLA), col=c("#CED8F6","steelblue"), bty="n")
dev.off()

