# Loading 
library(rvest)
library(magrittr)
library(data.table)
library(purrr)
library(lubridate)
library(feather)

# Scraping FEC data warehouse ---------------------------------------------

## Directed to FEC FTP server from this page: https://classic.fec.gov/data/LobbyistBundle.do

## File list manually copied on 8/26/18, rvest not cooperating

# Lots more than below on leadership committees, candidate disbursements (including state-level)

fec_paths <- function(subset = "*") {
  output <- paste0(c("electioneering",
                     "2014/ElectioneeringComm_2014",
                     "2016/ElectioneeringComm_2016",
                     "2018/ElectioneeringComm_2018",
                     # "2020/ElectioneeringComm_2020",
                     "lobbyist_table",
                     "data.fec.gov/admin_fine",
                     "data.fec.gov/lobbyist_bundle",
                     "data.fec.gov/lobbyist"),
                   ".csv")
  
  output[grepl(subset, output)]
}

fec_as_csv <- function(lookup_path, csv_paths) {
  
  if (!all(file.exists(paste0(lookup_path, gsub("\\/", "-", csv_paths))))) {
    
    fec_url <- "https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/"
    
    csvs <- map(paste0(fec_url, csv_paths), read.csv, stringsAsFactors = FALSE)
    
    # Save local csvs
    walk2(csvs, csv_paths, 
          ~ write.csv(.x, paste0(csv_locn_local, gsub("\\/", "-", .y))))
  } else {
    csvs <- map(paste0(csv_locn_local,
                       gsub("\\/", "-", csv_paths)),
                read.csv, stringsAsFactors = FALSE)
  }
  
  csvs
}