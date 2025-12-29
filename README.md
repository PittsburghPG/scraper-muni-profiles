# Municipal Profile Scraper

R scraper to pull municipality profiles in Allegheny County, Pa.: <https://apps.alleghenycounty.us/website/MuniList.asp>

## Overview

This scraper collects detailed information about all 130 municipalities in Allegheny County, Pennsylvania. The data includes demographic information, property values, tax rates, political districts, emergency services, and municipal contact information.

## Usage

The scraper is implemented in `scraper.R` and can be run in two ways:

### Test Run
To test the scraper on a few municipalities:
```r
test_results <- test_scraper(c(1, 2, 3))
```

### Full Scrape
To scrape all 130 municipalities (takes 2-3 minutes):
```r
municipal_data <- scrape_all_municipalities()
```

The script automatically saves the output to `data/muni-profiles.csv`.

**Note:** The script includes a 1-second delay between requests to avoid overwhelming the county's server.

## Data Codebook

The scraped data includes the following columns:

| Column Name | Type | Description |
|-------------|------|-------------|
| municipality | Character | Full name of the municipality (e.g., "City of Pittsburgh", "Borough of Aspinwall") |
| muni_code | Character | Municipality code used by Allegheny County (e.g., "100", "801", "926") |
| school_code | Character | School district code (e.g., "1", "47", "26") |
| county_council_district | Character | Allegheny County Council district number |
| council_representative | Character | Name of the Allegheny County Council representative |
| senatorial_district | Character | Pennsylvania State Senate district |
| legislative_district | Character | Pennsylvania State House of Representatives district |
| congressional_district | Character | U.S. Congressional district |
| square_miles | Numeric | Geographic area of the municipality in square miles |
| school_district | Character | Name of the school district (uppercase, cleaned) |
| council_of_government | Character | Council of Governments (COG) membership |
| police_chief | Character | Police chief name or police department information |
| fire_chief | Character | Fire chief name |
| ems_agency | Character | Emergency medical services provider |
| sanitary_authority | Character | Name of the sanitary authority |
| contact_name | Character | Name of the primary municipal contact person |
| contact_address | Character | Municipal office address |
| contact_phone | Character | Municipal office phone number |
| median_property_value | Numeric | Median property value in dollars |
| certified_taxable_value | Numeric | Certified taxable property value |
| certified_exempt_value | Numeric | Certified tax-exempt property value |
| certified_purta_value | Numeric | Public Utility Realty Tax Act value |
| certified_all_real_estate | Numeric | Total real estate value (sum of above categories) |
| millage_2023_municipality | Numeric | Municipal tax rate for 2023 |
| millage_2024_municipality | Numeric | Municipal tax rate for 2024 |
| millage_2025_municipality | Numeric | Municipal tax rate for 2025 |
| millage_2023_school | Numeric | School district tax rate for 2023 |
| millage_2024_school | Numeric | School district tax rate for 2024 |
| millage_2025_school | Numeric | School district tax rate for 2025 |

## Data Source

All data is scraped from the Allegheny County Municipal Profiles website:
<https://apps.alleghenycounty.us/website/MuniProfile.asp>

## Dependencies

Required R packages:
- `rvest` - Web scraping
- `dplyr` - Data manipulation
- `purrr` - Functional programming tools
- `stringr` - String manipulation
- `httr` - HTTP requests
- `tibble` - Modern data frames
- `here` - Path management
- `readr` - Reading/writing CSV files
