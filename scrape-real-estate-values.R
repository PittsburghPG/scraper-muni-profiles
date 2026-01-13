# Allegheny County Real Estate Values Time Series Scraper
# This script scrapes certified real estate values from municipal profiles
# and tracks changes over time by appending to a historical dataset
# Data source: https://apps.alleghenycounty.us/website/MuniProfile.asp

# Required libraries
library(rvest)
library(dplyr)
library(purrr)
library(stringr)
library(httr)
library(tibble)
library(here)
library(readr)
library(lubridate)

#' Safely extract text from HTML nodes using XPath
#' @param doc HTML document
#' @param xpath XPath selector string
#' @param default Default value if extraction fails (default: NA)
#' @return Extracted text or default value
safe_extract <- function(doc, xpath, default = NA) {
  tryCatch({
    nodes <- html_nodes(doc, xpath = xpath)
    if (length(nodes) > 0) {
      text <- html_text(nodes[1], trim = TRUE)
      if (text == "" || is.null(text)) return(default)
      return(text)
    } else {
      return(default)
    }
  }, error = function(e) {
    return(default)
  })
}

#' Extract the "Value As Of" date from the page
#' @param page HTML document
#' @return Date string in ISO format (e.g., "2026-01-08") or NA
extract_value_as_of_date <- function(page) {
  # Look for text like "Value As Of 1/8/2026:"
  tryCatch({
    # Get the second row of the table which contains the "Value As Of" values
    row_text <- safe_extract(page, "//*[@id='no-more-tables']/table[1]/tbody/tr[2]/td[1]")
    if (!is.na(row_text)) {
      # Extract date - format is "Value As Of 1/8/2026:"
      date_match <- str_extract(row_text, "[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}")
      if (!is.na(date_match)) {
        # Convert from M/D/YYYY to YYYY-MM-DD format
        parsed_date <- mdy(date_match)
        if (!is.na(parsed_date)) {
          return(format(parsed_date, "%Y-%m-%d"))
        }
      }
    }
    return(NA)
  }, error = function(e) {
    return(NA)
  })
}

#' Scrape real estate values for a single municipality
#' @param muni_id Municipality ID (1-130)
#' @param value_as_of_date Date string extracted from the page (to avoid re-extracting)
#' @return List containing municipality data or NULL if scraping fails
scrape_real_estate_values <- function(muni_id, value_as_of_date = NULL) {
  url <- paste0("https://apps.alleghenycounty.us/website/MuniProfile.asp?muni=", muni_id)

  cat("Scraping municipality", muni_id, "...\n")

  # Respectful delay between requests
  Sys.sleep(1)

  tryCatch({
    # Read the page
    page <- read_html(url)

    # Extract the "Value As Of" date if not provided
    if (is.null(value_as_of_date)) {
      value_as_of_date <- extract_value_as_of_date(page)
    }

    # Get municipality name
    municipality_name <- NA
    if (muni_id <= length(municipality_names)) {
      municipality_name <- municipality_names[muni_id]
    }

    # Extract "Value As Of" values from the second row using exact XPath selectors
    taxable_value <- as.numeric(gsub("[^0-9.]", "",
      safe_extract(page, "//*[@id='no-more-tables']/table[1]/tbody/tr[2]/td[2]", "0")))

    exempt_value <- as.numeric(gsub("[^0-9.]", "",
      safe_extract(page, "//*[@id='no-more-tables']/table[1]/tbody/tr[2]/td[3]", "0")))

    purta_value <- as.numeric(gsub("[^0-9.]", "",
      safe_extract(page, "//*[@id='no-more-tables']/table[1]/tbody/tr[2]/td[4]", "0")))

    all_real_estate <- as.numeric(gsub("[^0-9.]", "",
      safe_extract(page, "//*[@id='no-more-tables']/table[1]/tbody/tr[2]/td[5]", "0")))

    # Return result with scrape metadata
    return(list(
      municipality = municipality_name,
      value_as_of_date = value_as_of_date,
      scraped_at = Sys.time(),
      taxable_value = taxable_value,
      exempt_value = exempt_value,
      purta_value = purta_value,
      all_real_estate = all_real_estate
    ))

  }, error = function(e) {
    cat("Error scraping municipality", muni_id, ":", e$message, "\n")
    return(NULL)
  })
}

# Municipality names mapping (same as in scrape-profiles.R)
municipality_names <- c(
  "Aleppo Township", "Borough of Aspinwall", "Borough of Avalon",
  "Borough of Baldwin", "Baldwin Township", "Borough of Bell Acres",
  "Borough of Bellevue", "Borough of Ben Avon", "Borough of Ben Avon Hts.",
  "Municipality of Bethel Park", "Borough of Blawnox", "Borough of Brackenridge",
  "Borough of Braddock", "Borough of Braddock Hills", "Borough of Bradford Woods",
  "Borough of Brentwood", "Borough of Bridgeville", "Borough of Carnegie",
  "Borough of Castle Shannon", "Borough of Chalfant", "Borough of Cheswick",
  "Borough of Churchill", "City of Clairton", "Collier Township",
  "Borough of Coraopolis", "Borough of Crafton", "Crescent Township",
  "Borough of Dormont", "Borough of Dravosburg", "City of Duquesne",
  "East Deer Township", "Borough of East McKeesport", "Borough of East Pittsburgh",
  "Borough of Edgewood", "Borough of Edgeworth", "Borough of Elizabeth",
  "Elizabeth Township", "Borough of Emsworth", "Borough of Etna",
  "Fawn Township", "Findlay Township", "Borough of Forest Hills",
  "Forward Township", "Borough of Fox Chapel", "Borough of Franklin Park",
  "Frazer Township", "Borough of Glassport", "Borough of Glenfield",
  "Borough of Green Tree", "Hampton Township", "Harmar Township",
  "Harrison Township", "Borough of Haysville", "Borough of Heidelberg",
  "Borough of Homestead", "Indiana Township", "Borough of Ingram",
  "Borough of Jefferson Hills", "Kennedy Township", "Kilbuck Township",
  "Leet Township", "Borough of Leetsdale", "Borough of Liberty",
  "Borough of Lincoln", "Marshall Township", "Town of McCandless",
  "Borough of McDonald", "City of McKeesport", "Borough of McKees Rocks",
  "Borough of Millvale", "Municipality of Monroeville", "Moon Township",
  "Municipality of Mt. Lebanon", "Borough of Mt. Oliver", "Borough of Munhall",
  "Neville Township", "North Braddock Borough", "North Fayette Township",
  "North Versailles Township", "Borough of Oakdale", "Borough of Oakmont",
  "O'Hara Township", "Ohio Township", "Borough of Glen Osborne",
  "Municipality of Penn Hills", "Pennsbury Village", "Pine Township",
  "Borough of Pitcairn", "City of Pittsburgh", "Borough of Pleasant Hills",
  "Borough of Plum", "Borough of Port Vue", "Borough of Rankin",
  "Reserve Township", "Richland Township", "Robinson Township",
  "Ross Township", "Borough of Rosslyn Farms", "Scott Township",
  "Borough of Sewickley", "Borough of Sewickley Hts.", "Borough of Sewickley Hills",
  "Shaler Township", "Borough of Sharpsburg", "South Fayette Township",
  "South Park Township", "South Versailles Township", "Borough of Springdale",
  "Springdale Township", "Stowe Township", "Borough of Swissvale",
  "Borough of Tarentum", "Borough of Thornburg", "Borough of Trafford",
  "Borough of Turtle Creek", "Upper St. Clair Township", "Borough of Verona",
  "Borough of Versailles", "Borough of Wall", "West Deer Township",
  "Borough of West Elizabeth", "Borough of West Homestead", "Borough of West Mifflin",
  "Borough of West View", "Borough of Whitaker", "Borough of White Oak",
  "Borough of Whitehall", "Wilkins Township", "Borough of Wilkinsburg",
  "Borough of Wilmerding"
)

#' Scrape real estate values for all municipalities
#' @return Data frame containing real estate values for all municipalities
scrape_all_real_estate_values <- function() {
  cat("Starting to scrape real estate values for all municipalities...\n")

  # Get municipality IDs (1-130)
  municipality_ids <- 1:130

  # First, scrape one municipality to get the "Value As Of" date
  cat("Extracting 'Value As Of' date from first municipality...\n")
  first_page <- read_html(paste0("https://apps.alleghenycounty.us/website/MuniProfile.asp?muni=1"))
  value_as_of_date <- extract_value_as_of_date(first_page)

  if (is.na(value_as_of_date)) {
    cat("Warning: Could not extract 'Value As Of' date. Proceeding anyway...\n")
  } else {
    cat("'Value As Of' date found:", value_as_of_date, "\n")
  }

  # Initialize results list
  all_results <- list()

  # Scrape each municipality
  for (i in municipality_ids) {
    result <- scrape_real_estate_values(i, value_as_of_date)
    if (!is.null(result)) {
      all_results[[length(all_results) + 1]] <- result
    }

    # Progress indicator
    if (i %% 10 == 0) {
      cat("Completed", i, "of", length(municipality_ids), "municipalities\n")
    }
  }

  # Convert to data frame
  df <- bind_rows(all_results)

  return(df)
}

#' Update the real estate values time series file
#' This function scrapes current values and appends them to the historical dataset
#' @param output_file Path to the output CSV file
#' @return Data frame with updated time series
update_real_estate_time_series <- function(output_file = here("data", "muni-real-estate-time-series.csv")) {
  cat("=== Real Estate Values Time Series Update ===\n")
  cat("Starting scrape at:", as.character(Sys.time()), "\n\n")

  # Scrape current values
  new_data <- scrape_all_real_estate_values()

  # Check if historical file exists
  if (file.exists(output_file)) {
    cat("\nReading existing historical data...\n")
    historical_data <- read_csv(output_file, show_col_types = FALSE)

    # Check if this value_as_of_date already exists in the data
    if (nrow(new_data) > 0 && !is.na(new_data$value_as_of_date[1])) {
      existing_date <- new_data$value_as_of_date[1]
      if (existing_date %in% historical_data$value_as_of_date) {
        cat("Data for 'Value As Of' date", existing_date, "already exists in historical file.\n")
        cat("Skipping append to avoid duplicates.\n")
        return(historical_data)
      }
    }

    # Append new data to historical data
    combined_data <- bind_rows(historical_data, new_data)
    cat("Appended", nrow(new_data), "new records to", nrow(historical_data), "historical records.\n")
  } else {
    cat("\nNo historical file found. Creating new file...\n")
    combined_data <- new_data
  }

  # Remove any duplicates based on municipality and value_as_of_date
  combined_data <- combined_data %>%
    distinct(municipality, value_as_of_date, .keep_all = TRUE) %>%
    arrange(municipality, value_as_of_date)

  # Write to file
  write_csv(combined_data, output_file)
  cat("\nData written to:", output_file, "\n")
  cat("Total records in file:", nrow(combined_data), "\n")
  cat("Scrape completed at:", as.character(Sys.time()), "\n")

  return(combined_data)
}

# Main execution when script is run directly (not sourced)
if (!interactive() && sys.nframe() == 0) {
  cat("=== Allegheny County Real Estate Values Time Series Scraper ===\n")
  cat("This script tracks certified real estate values over time.\n\n")
  cat("Starting update...\n\n")

  # Run the update
  update_real_estate_time_series()
} else {
  # Just show usage instructions when sourced
  cat("=== Allegheny County Real Estate Values Time Series Scraper ===\n")
  cat("This script tracks certified real estate values over time.\n\n")
  cat("To scrape current values and update the time series:\n")
  cat("  data <- update_real_estate_time_series()\n\n")
  cat("The script will:\n")
  cat("  1. Scrape current 'Value As Of' values from all 130 municipalities\n")
  cat("  2. Extract the 'Value As Of' date from each profile\n")
  cat("  3. Append new data to the historical dataset (avoiding duplicates)\n")
  cat("  4. Save to data/muni-real-estate-time-series.csv\n\n")
  cat("Note: The script includes a 1-second delay between requests.\n")
}
