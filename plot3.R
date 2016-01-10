# Shame I've added this to each file. But have a budget of only 4 files and each has to stand alone
# Not exactly professional, but necessary givent the constraints
obtain_data <- function() {
    # First read the data (all 2 million rows ?)
    #
    library("data.table")
    # Constants
    chrData_subdir <- "./data"  # Must contain "./" as first 2 characters
    chrDownload_address <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"  # Web source data
    chrDownload_filename <- "exdata_data_household_power_consumption.zip"                                           # downloaded filename
    chrData_file_complete <- "household_power_consumption.txt"                                                      # actual unzipped data file
    chrNA_vals <- c("?"," ","","NA")                                                                                # convert these to NA
    chrWorking_filename <- "htpc_selected.csv"
    chrDateTime_format <- "%d/%m/%Y %H:%M:%S"
    chrDate_format <- "%d/%m/%Y"
    #
    # Save current wd
    chrInit_wd <- getwd()

    # assume data is in "data" subdirectory
    if (! file.exists(chrData_subdir)) {
        dir.create(chrData_subdir)
    }
    # dir we want must exist now, so go to it
    setwd(substr(chrData_subdir,3,nchar(chrData_subdir)))
    # Do we have the expected file ?
    if (! file.exists(chrDownload_filename)) {
        # download the input data
        download.file(chrDownload_address,destfile=chrDownload_filename,method="curl")
    }
    # Is the file already available and decompressed ?
    if (! file.exists(chrData_file_complete)) {
        # Not already present, so decompress the zip file
        unzip (chrDownload_filename)  # Unzip using default routine and names specified in archive, to archive specified directory
    }

    # If necessary, read the source data file so we can ceate the much smaller working file
    if (! file.exists(chrWorking_filename)) {
        dtHpc <- fread(chrData_file_complete,header=TRUE,sep=";",na.strings=chrNA_vals <- c("?"," ","","NA"),verbose=TRUE)  # Fast read the file, to a data table
        dtHpc_selected <- dtHpc[dtHpc$Date == "1/2/2007" | dtHpc$Date == "2/2/2007",]  # Select rows with our dates, all columns
        # Assume supplied dates are GMT (UTC) - anything else would be amateurish
        dtHpc_selected[, datetime:=(as.POSIXct(strptime(dtHpc_selected$Date,format=chrDate_format,tz="GMT"))+as.ITime(dtHpc_selected$Time))]  # Add new date format column

        # write out the data we're actually interested in - speeds re-use
        write.table(dtHpc_selected,file=chrWorking_filename,sep=",")
    } else {
        # Data we want was already created, so read it back in (nice small subset - comparatively)
        dtHpc_selected <- read.table(chrWorking_filename)
    }
    #
    # All set and ready to go ... required data is now in variable   dtHpc_selected
    #
    # Restore wd
    setwd(chrInit_wd)
    # Pass the data of interest back to the caller
    dtHpc_selected   # Could also use return(dtHpc_selected)
}
#  =========================== Code to plot assignment data - Question 3 ================================= #
# Constants
chrOutput_file <- "plot3.png"
chrDate_format <- "%d/%m/%Y"
# Save current wd
chrInit_wd <- getwd()
# Now obtain the data
obtain_data()
# Open the output file
png(chrOutput_file, width = 480, height = 480, units = "px", pointsize = 12, bg = "white")
# Set global parameters
#par(cex=.75, font=1, family="serif")  # Scale fonts to less than normal size - looks better, use plain serif fonts

# Now build the plot canvas, first setting the Y axis size appropriately
numMax_ys <- c(max(dtHpc_selected$Sub_metering_1), max(dtHpc_selected$Sub_metering_2), max(dtHpc_selected$Sub_metering_3))
numMax_y <- c(0,rep(max(numMax_ys),length(dtHpc_selected$Sub_metering_1)-1))
plot((as.POSIXct(strptime(dtHpc_selected$Date,format=chrDate_format,tz="GMT"))+as.ITime(dtHpc_selected$Time)),numMax_y,xlab="",ylab="Energy sub metering",type="n")
# and add the lines
lines(as.POSIXct(strptime(dtHpc_selected$Date,format=chrDate_format,tz="GMT"))+as.ITime(dtHpc_selected$Time),dtHpc_selected$Sub_metering_1,type="l")
lines(as.POSIXct(strptime(dtHpc_selected$Date,format=chrDate_format,tz="GMT"))+as.ITime(dtHpc_selected$Time),dtHpc_selected$Sub_metering_2,type="l",col="red")
lines(as.POSIXct(strptime(dtHpc_selected$Date,format=chrDate_format,tz="GMT"))+as.ITime(dtHpc_selected$Time),dtHpc_selected$Sub_metering_3,type="l",col="blue")
legend("topright",legend=c("Sub_metering_1","Sub_metering_2", "Sub_metering_2"),col=c("black","red","blue"),lty=c(1,1,1))
# Close the device (file)
dev.off()
#
# Restore wd
setwd(chrInit_wd)
