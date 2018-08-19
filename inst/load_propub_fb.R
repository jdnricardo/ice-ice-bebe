# Loading raw FB ads file for cleaning and saving as database
library(xlsx)
library(feather)
library(RSQLite)

## Typically run from R or nb folders, one directory up
ads_file_nm <- "../inst/extdata/fbpac-ads-en-US"

## Read in csv (if more convenient format not saved)
if (length(list.files(dirname(ads_file_nm),
                      basename(ads_file_nm))) == 0) {
  ads_raw <- list.files(dirname(ads_file_nm),
                        basename(ads_file_nm),
                        full.names = TRUE)
  ads_raw <- read.csv(ads_raw, stringsAsFactors = FALSE)
}

## Save as more database-friendly formats

## Writing to excel spreadsheet (to import to MS Access)
# if (!file.exists(paste0(ads_file_nm,
#                         # Manually enter last update timestamp
#                         "20180819.xlsx"))) {
#   write.xlsx(ads_raw, paste0(ads_file_nm, 
#                              gsub("\\-", "", Sys.Date()),
#                              ".xlsx"))
# }

## Writing to feather (for R, Python)
feather_file_nm <- paste0(ads_file_nm,
                          # Manually enter last update timestamp
                          "20180819")

if (!file.exists(feather_file_nm)) {
  write_feather(ads_raw, paste0(ads_file_nm,
                                gsub("\\-", "", Sys.Date())))
} else {
  ads_feather <- function() read_feather(feather_file_nm)
}