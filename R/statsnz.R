#' @importFrom utils read.table type.convert
NULL

#' Fetch from the NZ Statistics API
#'
#' Helper function to fetch information from the StatisticsNZ API
#'
#' @param url_path The subpath of the base-URL.
#' @param query A query list for the API. Defaults to NULL (no query)
#' @return The results of the GET request
api_fetch <- function(url_path, query = NULL) {

  api_key <- "0a2e5e79ca3e41508d706468d74eff1c"
  base_url <- "https://statisticsnz.azure-api.net/data/"

  # build URL
  url <- httr::modify_url(paste0(base_url, url_path), query = query)

  # perform the request
  req = NULL
  tryCatch(
    req <- httr::GET(url,
                     httr::add_headers(
                       'Ocp-Apim-Subscription-Key' = api_key
                     )),
    error = function(e) { message("api_fetch failed: ", conditionMessage(e)) })
  req
}

#' Statistics available from the StatisticsNZ API
#'
#' @return A data.frame with columns Stat and Description of statistics from the StatsNZ API.
#' @export
available_stats <- function() {

  nz_stats <- read.table(header=TRUE, colClasses = 'character', text =
                "Stat Description
                 ALC  'Alcohol available for Consumption'
                 BOP  'Balance of Payments and International Investment Position'
                 BPI  'Business Price Indexes'
                 CRT  'Christchurch Retail Trade Indicator'
                 ESM  'Economic Survey of Manufacturing'
                 GDP  'Gross Domestic Product'
                 GDPRegional  'Regional Gross Domestic Product'
                 GST  'Goods and Services Trade by Country'
                 LMS  'Labour Market Statistics'
                 NACFGCentralGovernment  'Government Finance Statistics (Central Government)'
                 NACFGLocalGovernment    'Government Finance Statistics (Local Government)'
                 OTI  'Overseas Trade Indexes (Prices and Volumes)'
                 ProductivityStatistics  'Productivity Statistics'
                 RTS  'Retail Trade Survey'
                 VBW  'Value of Building Work Put in Place'
                 WTS  'Wholesale Trade Survey'")
  return(nz_stats)
}

#' Get groups for a particular statistic
#'
#' Get the groups available for a particular statistic from the StatisticsNZ API
#'
#' @param stat the statistic to query
#' @return a vector of groups available for this statistic
#' @export
get_groups <- function(stat) {

  # Check if the given statistic is available
  if (!(stat %in% available_stats()$Stat))
    stop(paste("The statistic", stat, "is not available."))

  # setup the query
  req <- api_fetch(paste0(tolower(stat), "/v0.1/groups"))

  # Grab data
  httr::content(req, simplifyVector = TRUE)
}

#' Get data on a particular statistic
#'
#' Get statistics data on a given statistic (optionally) and given group from the StatisticsNZ API
#'
#' @param stat The statistic to fetch.
#' @param group The (optional) group of this statistic to fetch
#' @return a data.frame containing the statistic of interest, usually a time-series
#' @export
get_stats <- function(stat, group = NULL) {

  # Check if the given statistic is available
  if (!(stat %in% available_stats()$Stat))
    stop(paste("The statistic", stat, "is not available."))

  # build query
  query = NULL
  if (!is.null(group))
    query = list(groupName = group)

  req <- api_fetch(paste0("api/", stat), query)

  # grab the data
  dat <- httr::content(req, simplifyVector = TRUE)

  # process the data
  if ('Period' %in% names(dat)) {
    dat[['Period']] = lubridate::parse_date_time2(dat[['Period']], orders="%Y.%m")
  }
  convert_column_type <- function(x) {
    if (is.character(x)) {
      type.convert(x)
    } else {
      x
    }
  }
  data.frame(lapply(dat, convert_column_type))
}
