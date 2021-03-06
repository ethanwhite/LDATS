% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/time_series_functions.r
\name{multinom_chunk}
\alias{multinom_chunk}
\title{Fit multinomial time chunk model}
\usage{
multinom_chunk(data, formula, start_time, end_time, weights, ...)
}
\arguments{
\item{data}{data frame including the predictor and response variables}

\item{formula}{Right Hand Side of the continuous time formula as a 
character vector}

\item{start_time}{start time for the chunk}

\item{end_time}{end time for the chunk}

\item{weights}{weights}

\item{...}{other arguments to be passed to the multinom function}
}
\value{
fitted model for the chunk
}
\description{
Fit a multinomial regression model to topic model data for
  dates within a defined chunk of time (start_date, end_date] with  
  covariate impacts assuming no temporal autocorrelation by default
}
