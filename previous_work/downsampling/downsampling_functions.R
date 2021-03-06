
#' Downsample a time series
#'
#'
#' @param data data frame with a column named "dates"
#' @param frequency number of samples to be retained within each year
#' @param span date range to include
#' @param selection_random logical indicating if the downsampling is random 
#'    (TRUE) or ordered (FALSE)
#' @param selection_order
#'
#' @return Table of species counts per period
#'
#' @author Juniper Simonis
#'
#' @export 

downsample <- function(data = NULL, frequency = NULL, span = NULL, 
                       selection_random = FALSE, selection_order = 1){

  # number of species

    nspecies <- ncol(data[ , -1])

  # reduce the data to the span input  

    data_span <- data[which(data$dates >= span[1] & data$dates < span[2]), ]

  # dates of samples 

    dates_os <- data_span$dates

  # count the number of years

    yr <- format(dates_os, "%Y")
    yrs <- unique(yr)
    nyears <- length(yrs)

  # how many downsamples

    ndsamples <- nyears * frequency

  # set up the dates for down sampling

    dsample_date <- rep(NA, ndsamples)

    for(i in 1:nyears){

      # subset the dates to the year of interest

        dates_of_year <- dates_os[which(yr == yrs[i])]

      # break the year up into a number of bins = frequency
      #  requires start and end dates for each bin, which requires a bin/step
      #  size

        bin_size <- 365.25/frequency    
        bins <- 1:frequency
        bin_start <- rep(NA, frequency) 
        bin_stop <- rep(NA, frequency)

        ref_origin <- paste(yrs[i], "-01-01", sep = "")

        for(j in 1:frequency){

          start_jd <- floor((j - 1) * bin_size)
          stop_jd <- floor(j * bin_size)

          bin_start[j] <- format(as.Date(start_jd, ref_origin), "%Y-%m-%d")
          bin_stop[j] <- format(as.Date(stop_jd, ref_origin), "%Y-%m-%d")
        }

        bin_stop[frequency] <- paste(yrs[i], "-12-31", sep = "")

      # within each bin, downsample the prescribed sample or sample at random

        selected_dates <- rep(NA, frequency)

        for(j in 1:frequency){

          # subset the dates

            bin_dates <- dates_of_year[which(dates_of_year >= bin_start[j] & 
                                             dates_of_year < bin_stop[j])]

          # make sure they're in order

            bin_dates <- sort(bin_dates)

          # if random, select random
          #  else, select by order given

            if(selection_random == TRUE){

              nbds <- length(bin_dates) 
              selected_dates[j] <- as.character(bin_dates[sample(1:nbds, 1)])

            }else{

              selected_dates[j] <- as.character(bin_dates[selection_order])

            }

        }

      # specific sample date indicators for the output vector

        sd_1 <- ((i - 1) * frequency) + 1
        sd_2 <- (i * frequency)

      dsample_date[sd_1:sd_2] <- as.character(selected_dates)
    }



  # matrix to hold the downsamples

    dsm <- matrix(NA, ncol = nspecies, nrow = ndsamples)

  # downsample

    for(i in 1:ndsamples){
 

        specific_data <- which(dates_os == dsample_date[i])

        dsm[i, ] <- as.numeric(data_span[specific_data, -1])
    }

    colnames(dsm) <- colnames(data)[-1]

  # prep output

    output <- data.frame(date = dsample_date, dsm)



  return(output)

}



#' Save out a histogram of the topics for a dataset
#'
#'
#' @param dd data
#' @param nn name
#'
#' @return Figure saved out
#'
#'
#' @export 

ntopic_hist_file <- function(dd = NULL, nn = NULL){
      jpeg(paste("n_topics_", nn, ".jpeg", sep = ""), width = 4, height = 4, 
           unit = "in", res = 200)
      hist(dd$k, breaks= seq(0.5, 9.5, 1), main = nn, 
           xlab = "Topics")
      dev.off()
}



#' Save out a multi-panel histogram of the change points for a dataset
#'
#'
#' @param dd data
#' @param cpms change point models
#' @param ntopics number of topics in the LDA used
#' @param niter number of iterations in the model
#' @param nn name
#'
#' @return Figure saved out
#'
#'
#' @export 


cp_hists_file <- function(dd = NULL, cpms = NULL, ntopics = NULL, 
                          niter = NULL, nn = NULL){


        ncpms <- length(cpms)
        cds <- as.Date(as.character(dd[, 1]))
        year_continuous <- 1970 + as.integer(julian(cds)) / 365.25
        jpeg(paste("cp_", nn, ".jpeg", sep = ""), height = 10, width = 6, 
             unit = "in", res = 200)
        par(mfrow = c(ncpms,1))
 
        for(i in 1:ncpms){
          annual_hist(cpms[[i]], year_continuous)
          text(1973, 1.1 * niter, cex = 1.25, adj = -1, xpd = T,
           paste("AIC = ", 
                 round(mean(cpms[[i]]$saved_lls * -2) + 
                       2 * (3 * (ntopics - 1) * (i + 1) + (i)), 2),
                 sep = ""))
          if(i == 1){
            mtext(side = 3, nn, line = 1)
          }
        }

        dev.off()
}