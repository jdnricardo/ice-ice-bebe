# Loading raw FB ads file for cleaning and saving as database
library(xlsx)
library(feather)
library(magrittr)
library(data.table)
library(lubridate)
library(purrr)

## Typically run from R or nb folders, one directory up
ads_file_nm <- "../inst/extdata/fbpac-ads-en-US"

## Read in csv (if more convenient format not saved)
if (length(list.files(dirname(ads_file_nm),
                      basename(ads_file_nm))) == 0) {
  
  ads_raw <- list.files(paste0(dirname(ads_file_nm),"/csv"),
                        basename(ads_file_nm),
                        full.names = TRUE)
  ads_raw <- read.csv(ads_raw, stringsAsFactors = FALSE) %>% 
    as.data.table()
  
  ads_raw <- ads_raw[, ':=' (created_at = ymd_hms(created_at),
                             updated_at = ymd_hms(updated_at))]
  setkey(ads_raw, created_at)
  
  ad_targs_raw <- ads_raw[grepl("\\w", targets), targets] %>% 
    gsub('([":\\}\\]|,\\s|List)', "", .) %>%
    strsplit('[\\{\\}\\[]*(\\{target|segment)') %>%
    map( ~ unlist(.x) %>% 
           trimws() %>% 
           gsub("(\\]|Like|Activity\\son.*|Oranjestad)*", "", .) %>% 
           .[grepl("\\w", .)]) %>% 
    map( ~ data.frame(target_cat = .x[c(TRUE, FALSE)],
                      # Even indexed items are target name
                      target = .x[c(FALSE,TRUE)]))
  
  ad_targs_raw_ids <- ads_raw[grepl("\\w", targets), id] 
  
  # Create separate dataset of ad target labels
  # with ids for later merging back with main dataset
  ad_targs_raw <- map2_dfr(ad_targs_raw, ad_targs_raw_ids,
                           function(x, y) {
                             x$id <- y
                             
                             return(x)
                           }) %>% 
    as.data.table()
  
  # Remove targets column from main dataset
  
  ads_raw[, targets := NULL]
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

# Manually enter last update timestamp
last_updated <- "20180928"
## Writing to feather (for R, Python)
feather_file_nm <- paste0(ads_file_nm, last_updated)
feather_file_nm_targs <- paste0(ads_file_nm, "-targs", last_updated)

if (!file.exists(feather_file_nm)) {
  write_feather(ads_raw, paste0(ads_file_nm,
                                gsub("\\-", "", Sys.Date())))
  
  write_feather(ad_targs_raw, paste0(ads_file_nm, "-targs",
                                     gsub("\\-", "", Sys.Date())))
} else {
  ads_feather <- function() {
    list(ads = read_feather(feather_file_nm),
         ad_targs = read_feather(feather_file_nm_targs))
  }
}