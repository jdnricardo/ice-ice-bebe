# Loading 
library(rvest)
library(magrittr)
library(data.table)
library(purrr)

### Directed to FEC FTP server from this page: https://classic.fec.gov/data/LobbyistBundle.do

fec_url <- "https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/"

### List manually copied on 8/24/18, rvest not cooperating

# Lots more than below on leadership committees, candidate disbursements (including state-level)

csv_paths <- c("electioneering",
               "lobbyist_table",
               "data.fec.gov/admin_fine",
               "data.fec.gov/lobbyist_bundle",
               "data.fec.gov/lobbyist") %>% 
  paste0(".csv")

csvs <- map(paste0(fec_url, csv_paths), fread) 

# read_html(paste0(fec_url, "index.html")) %>% 
#   html_node("div#listing") %>% 
#   html_nodes("*") %>% 
#   html_attr("href")