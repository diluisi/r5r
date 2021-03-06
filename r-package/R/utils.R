############# Support functions for r5r
# nocov start

#' Set verbose argument
#'
#' @param r5r_core a rJava object to connect with R5 routing engine
#' @param verbose logical, passed from function above
#' @export
#' @family support functions
#'
set_verbose <- function(r5r_core, verbose) {

  # in silent mode only errors are reported

  checkmate::assert_logical(verbose)

  if (verbose) r5r_core$verboseMode()
  else r5r_core$silentMode()

}



#' Set max walking distance
#'
#' @param max_walk_dist numeric, Maximum walking distance (in Km) for the whole
#'                      trip. Passed from routing functions.
#' @param walk_speed numeric, Average walk speed in Km/h. Defaults to 3.6 Km/h.
#'                    Passed from routing functions.
#' @param max_trip_duration numeric, Maximum trip duration in seconds. Defaults
#'                          to 120 minutes (2 hours). Passed from routing functions.
#' @export
#' @family support functions

set_max_walk_distance <- function(max_walk_dist, walk_speed, max_trip_duration) {

  checkmate::assert_numeric(max_walk_dist)

  if (is.infinite(max_walk_dist)) return(max_trip_duration)

  max_street_time <- as.integer(round(60 * max_walk_dist / walk_speed, digits = 0))

  # if max_street_time ends up being higher than max_trip_duration, uses
  # max_trip_duration as a ceiling

  if (max_street_time > max_trip_duration) max_street_time <- max_trip_duration

  return(max_street_time)

}



#' Select transport mode
#'
#' @param mode character string, defaults to "WALK"
#' @export
#' @family support functions
#'
select_mode <- function(mode="WALK") {

  mode <- toupper(unique(mode))

  # List all available modes
  dr_modes <- c('WALK','BICYCLE','CAR','BICYCLE_RENT','CAR_PARK')
  tr_modes <- c('TRANSIT', 'TRAM','SUBWAY','RAIL','BUS','FERRY','CABLE_CAR','GONDOLA','FUNICULAR')
  all_modes <- c(tr_modes, dr_modes)

  # check for invalid input
  lapply(X=mode, FUN=function(x){
    if(!x %chin% all_modes){stop(paste0("Eror: ", x, " is not a valid 'mode'.
                                        Please use one of the following: ",
                                        paste(unique(all_modes),collapse = ", ")))} })

  # assign modes accordingly
  direct_modes <- mode[which(mode %chin% dr_modes)]
  transit_mode <- mode[which(mode %chin% tr_modes)]
  if("TRANSIT" %in% transit_mode){ transit_mode <- tr_modes }

  # if only a direct_mode is passed, all others are empty
  if (length(direct_modes) != 0 & length(transit_mode) == 0) {
    egress_mode <- access_mode <- mode[which(mode %chin% c('WALK', 'BICYCLE'))]
    if (length(access_mode) == 0){ egress_mode <- access_mode <- 'WALK' }
    if (direct_modes == "CAR"){ egress_mode <- access_mode <- 'CAR' }
    transit_mode <- ""
  } else

    # if only transit mode is passed, assume 'WALK' as access_ and egress_modes
    if (length(transit_mode) != 0 & length(direct_modes) == 0) {
      egress_mode <- access_mode <- mode[which(mode %chin% c('WALK', 'BICYCLE'))]
      if (length(access_mode) == 0){ egress_mode <- access_mode <- 'WALK' }
      direct_modes <- ""

    } else

      # if transit & direct modes are passed, consider direct as access & egress_modes
      if (length(transit_mode) != 0 & length(direct_modes) != 0) {
        access_mode <- direct_modes[which(direct_modes %chin% c('WALK', 'BICYCLE', 'CAR'))]
        egress_mode <- access_mode <- unique(c('WALK', access_mode))
      }


  # create output as a list
  mode_list <- list('direct_modes' = paste0(direct_modes, collapse = ";"),
                    'transit_mode' = paste0(transit_mode, collapse = ";"),
                    'access_mode' = paste0(access_mode, collapse = ";"),
                    'egress_mode' = paste0(egress_mode, collapse = ";"))


  return(mode_list)
}



#' Generate date and departure time strings from POSIXct
#'
#' @param datetime An object of POSIXct class.
#'
#' @return A list with 'date' and 'departure_time' names.
#' @export
#' @family support functions

posix_to_string <- function(datetime) {

  checkmate::assert_posixct(datetime)

  datetime_list <- list(
    date = strftime(datetime, format = "%Y-%m-%d"),
    time = strftime(datetime, format = "%H:%M:%S")
  )

  return(datetime_list)

}



#' Assert class of origin and destination inputs and the type of its columns
#'
#' @param df Any object.
#' @param name Object name.
#'
#' @return A data.frame with columns \code{id}, \code{lon} and \code{lat}.
#' @export
#' @family support functions

assert_points_input <- function(df, name) {

  # check if 'df' is a data.frame or a POINT sf

  if (is(df, "data.frame")) {

    if (is(df, "sf")) {

      if (as.character(sf::st_geometry_type(df, by_geometry = FALSE)) != "POINT") {

        stop(paste0("'", name, "' must be either a 'data.frame' or a 'POINT sf'."))

      }

      df <- sfheaders::sf_to_df(df, fill = TRUE)
      data.table::setDT(df)
      data.table::setnames(df, "x", "lon")
      data.table::setnames(df, "y", "lat")
      data.table::setnames(df, names(df)[1], "id")

    }

    checkmate::assert_names(names(df), must.include = c("id", "lat", "lon"), .var.name = name)

    if (!is.character(df$id)) {

      df$id <- as.character(df$id)
      warning(paste0("'", name, "$id' forcefully cast to character."))

    }

    checkmate::assert_numeric(df$lon, .var.name = paste0(name, "$lon"))
    checkmate::assert_numeric(df$lat, .var.name = paste0(name, "$lat"))

    return(df)

  }

  stop(paste0("'", name, "' must be either a 'data.frame' or a 'sf POINT'."))

}



#' Set number of threads
#'
#' @description Sets numbers of threads to be used by the R5R .jar.
#'
#' @param r5r_core a rJava object to connect with R5 routing engine
#' @param n_threads Any object.
#' @export
#' @family support functions

set_n_threads <- function(r5r_core, n_threads) {

  checkmate::assert_numeric(n_threads)

  if (is.infinite(n_threads)) {

    r5r_core$setNumberOfThreadsToMax()

  } else {

    n_threads <- as.integer(n_threads)
    r5r_core$setNumberOfThreads(n_threads)

  }

}



#' Set walk and bike speed
#'
#' @description Sets walk and bike speed considered by R5R. R5 inputs speed in
#' m/s, while our functions inputs it in km/h.
#'
#' @param r5r_core a rJava object to connect with R5 routing engine
#' @param speed A numeric representing the speed in km/h.
#' @param mode Either \code{"bike"} or \code{"walk"}.
#' @export
#' @family support functions

set_speed <- function(r5r_core, speed, mode) {

  checkmate::assert_numeric(speed, .var.name = paste0(mode, "_speed"))

  # convert from km/h to m/s
  speed <- speed * 5 / 18

  if (mode == "walk") r5r_core$setWalkSpeed(speed)
  else r5r_core$setBikeSpeed(speed)

}

# nocov end
