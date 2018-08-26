# Loading 
library(rvest)
library(magrittr)
library(data.table)
library(purrr)
library(lubridate)
library(feather)

### Directed to FEC FTP server from this page: https://classic.fec.gov/data/LobbyistBundle.do

### List manually copied on 8/24/18, rvest not cooperating

# Lots more than below on leadership committees, candidate disbursements (including state-level)

csv_paths <- paste0(c("electioneering",
                      "lobbyist_table",
                      "data.fec.gov/admin_fine",
                      "data.fec.gov/lobbyist_bundle",
                      "data.fec.gov/lobbyist"),
                    ".csv")

if (!all(file.exists(paste0("./inst/extdata/csv/", gsub("\\/", "-", csv_paths))))) {
  
  fec_url <- "https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/"
  
  csvs <- map(paste0(fec_url, csv_paths), read.csv, stringsAsFactors = FALSE)
  
  # Save local csvs
  walk2(csvs, csv_paths, 
        ~ write.csv(.x, paste0("./inst/extdata/csv/", gsub("\\/", "-", .y))))
}

### Electioneering

electioneering <- csvs[[1]] %>% 
  setNames(gsub("\\.", "", tolower(names(.))))
  
electioneering <- data.table(electioneering)

elect_date_cols <- grep("_dt$", names(electioneering), value = TRUE)
electioneering[, c(elect_date_cols) := lapply(.SD,
                                              function(x){
                                                sub("([A-Z])([A-Z]+)", "\\1\\L\\2", 
                                                    x, perl = TRUE)
                                              }),
               .SDcols = (elect_date_cols)]
# electioneering[, c(elect_date_cols) := lapply(.SD,
#                                               function(x){
#                                                 as_datetime(x, format = "%d-%b-%y")
#                                               }),
#                .SDcols = (elect_date_cols)]