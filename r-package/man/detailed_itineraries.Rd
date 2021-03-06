% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/detailed_itineraries.R
\name{detailed_itineraries}
\alias{detailed_itineraries}
\title{Plan multiple itineraries}
\usage{
detailed_itineraries(
  r5r_core,
  origins,
  destinations,
  mode = "WALK",
  departure_datetime = Sys.time(),
  max_walk_dist = Inf,
  max_trip_duration = 120L,
  walk_speed = 3.6,
  bike_speed = 12,
  shortest_path = TRUE,
  n_threads = Inf,
  verbose = TRUE
)
}
\arguments{
\item{r5r_core}{A rJava object to connect with R5 routing engine}

\item{origins, destinations}{Either a spatial sf POINT or a data.frame
containing the columns \code{id}, \code{lon} and
\code{lat}.}

\item{mode}{A string, defaults to "WALK". See details for other options.}

\item{departure_datetime}{A POSIXct object. If working with public transport
networks, please check \code{calendar.txt} within
the GTFS file for valid dates.}

\item{max_walk_dist}{numeric, Maximum walking distance (in Km) for the whole trip.}

\item{max_trip_duration}{An integer. Maximum trip duration in minutes.
Defaults to 120 minutes (2 hours).}

\item{walk_speed}{numeric, Average walk speed in Km/h. Defaults to 3.6 Km/h.}

\item{bike_speed}{numeric, Average cycling speed in Km/h. Defaults to 12 Km/h.}

\item{shortest_path}{A logical. Whether the function should only return the
fastest route alternative (default) or multiple
alternatives.}

\item{n_threads}{numeric, The number of threads to use in parallel computing.
Defaults to use all available threads (Inf).}

\item{verbose}{logical, TRUE to show detailed output messages (Default) or
FALSE to show only eventual ERROR messages.}
}
\value{
A LINESTRING sf with detailed information about the itineraries
between specified origins and destinations.
}
\description{
Returns multiple detailed itineraries between specified origins
and destinations.
}
\details{
R5 allows for multiple combinations of transport modes. The options
include:
\subsection{Transit modes}{

TRAM, SUBWAY, RAIL, BUS, FERRY, CABLE_CAR, GONDOLA, FUNICULAR. The option
'TRANSIT' automatically considers all public transport modes available.
}

\subsection{Non transit modes}{

WALK, BICYCLE, CAR, BICYCLE_RENT, CAR_PARK
}
}
\examples{
\donttest{
library(r5r)

# build transport network
data_path <- system.file("extdata", package = "r5r")
r5r_core <- setup_r5(data_path = data_path)

# load and set origin/destination points
points <- read.csv(file.path(data_path, "poa_points_of_interest.csv"))

origins <- points[10,]
destinations <- points[12,]

# inputs
mode = c("WALK", "BUS")
max_walk_dist <- 1
departure_datetime <- as.POSIXct("13-03-2019 14:00:00",
                                 format = "\%d-\%m-\%Y \%H:\%M:\%S")

df <- detailed_itineraries(r5r_core,
                           origins,
                           destinations,
                           mode,
                           departure_datetime,
                           max_walk_dist)

}
}
\seealso{
Other routing: 
\code{\link{travel_time_matrix}()}
}
\concept{routing}
