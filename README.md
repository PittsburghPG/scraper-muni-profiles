# Municipal Profile and Millage Rate Scraper

R scrapers to pull municipality profiles and millage rates in Allegheny County, Pa.: <https://apps.alleghenycounty.us/website/MuniList.asp>

## Quick Start

This repository contains two main scrapers:

### 1. Scrape Municipal Profiles

```r
source("scrape-profiles.R")
```

This scraper collects detailed information about all 130 municipalities from the Allegheny County Municipal Profiles website:
- Demographics and geographic information
- Property values and assessment data
- Contact information for municipal offices
- Emergency services information
- Political district assignments

**Output:** `data/muni-profiles.csv`

**Time:** ~2-3 minutes (1-second delay between requests)

### 2. Scrape Millage Rates

```r
source("scrape-millage.R")
```

This scraper fetches tax millage rates for all available years (currently 2018-2025) from the Allegheny County Treasurer's Office:
- Municipal millage rates from https://apps.alleghenycounty.us/website/MillMuni.asp
- School district millage rates from https://apps.alleghenycounty.us/website/millsd.asp
- County millage rates

**Output:** Three long-format CSV files ready for joining with assessment data:
  - `data/muni-millage-rates.csv` - Municipal millage rates
  - `data/school-millage-rates.csv` - School district millage rates
  - `data/county-millage-rates.csv` - County millage rates

**Time:** ~1 minute (1-second delay between requests)

**Data Preservation:** The millage scraper preserves historical data when re-run. If the Treasurer's Office removes older years from their website, those years will still be retained in your local CSV files. New data is merged with existing data using `distinct()` to avoid duplicates.

## Data Diciontary

#### `muni-profiles.csv`

The main scraped data file includes the following columns:

| Column Name | Type | Description |
|-------------|------|-------------|
| `municipality` | Character | Full name of the municipality |
| `muni_code` | Character | Municipality code used by Allegheny County  |
| `school_code` | Character | School district code |
| `county_council_district` | Character | Allegheny County Council district number |
| `council_representative` | Character | Name of the Allegheny County Council representative |
| `senatorial_district` | Character | Pennsylvania State Senate district |
| `legislative_district` | Character | Pennsylvania State House of Representatives district |
| `congressional_district` | Character | U.S. Congressional district |
| `square_miles` | Numeric | Geographic area of the municipality in square miles |
| `school_district` | Character | Name of the school district (uppercase, cleaned) |
| `council_of_government` | Character | Council of Governments (COG) membership |
| `police_chief` | Character | Police chief name or police department information |
| `fire_chief` | Character | Fire chief name |
| `ems_agency` | Character | Emergency medical services provider |
| `sanitary_authority` | Character | Name of the sanitary authority |
| `contact_name` | Character | Name of the primary municipal contact person |
| `contact_address` | Character | Municipal office address |
| `contact_phone` | Character | Municipal office phone number |
| `median_property_value` | Numeric | Median property value in dollars |
| `certified_taxable_value` | Numeric | Certified taxable property value |
| `certified_exempt_value` | Numeric | Certified tax-exempt property value |
| `certified_purta_value` | Numeric | Public Utility Realty Tax Act value |
| `certified_all_real_estate` | Numeric | Total real estate value (sum of above categories) |

#### `muni-millage-rates.csv`

Long-format municipal millage rates file for joining with assessment appeals data. Each row represents a municipality-year combination.

| Column Name | Type | Description |
|-------------|------|-------------|
| `municipality` | Character | Full name of the municipality |
| `muni_code` | Character | Municipality code used by Allegheny County |
| `tax_year` | Integer | Tax year (2018-2025) |
| `millage` | Numeric | Municipal tax rate for that year (in mills) |

#### `school-millage-rates.csv`

Long-format school district millage rates file for joining with assessment appeals data. Each row represents a school district-year combination.

| Column Name | Type | Description |
|-------------|------|-------------|
| `school` | Character | Name of the school district (uppercase, cleaned) |
| `school_code` | Character | School district code |
| `tax_year` | Integer | Tax year (2018-2025) |
| `millage` | Numeric | School district tax rate for that year (in mills) |

**Note:** The school district file uses `distinct()` to remove duplicate rows since multiple municipalities can be in the same school district.

#### `county-millage-rates.csv`

Long-format county millage rates file for joining with assessment appeals data. Each row represents a tax year.

| Column Name | Type | Description |
|-------------|------|-------------|
| `county` | Character | County name (always "Allegheny County") |
| `tax_year` | Integer | Tax year (2018-2025) |
| `millage` | Numeric | Allegheny County tax rate for that year (in mills) |

**Note:** Tax rates are expressed in mills (1 mill = $1 per $1,000 of assessed value). County millage rates are uniform across all municipalities in Allegheny County.

**Important:** Municipal and School District taxes in McDonald Borough and Trafford Borough are not based on current Allegheny County assessed property values. These municipalities use different assessment systems, so their millage rates should not be directly compared with other Allegheny County municipalities.

## Data Sources

- **Municipal Profiles:** <https://apps.alleghenycounty.us/website/MuniProfile.asp>
- **Municipal Millage Rates:** <https://apps.alleghenycounty.us/website/MillMuni.asp>
- **School District Millage Rates:** <https://apps.alleghenycounty.us/website/millsd.asp>
