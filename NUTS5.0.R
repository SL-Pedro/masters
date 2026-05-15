# ============================================================
# REGPAT (EPO App) — Convert NUTS 2013 -> NUTS 2021 and build
# NUTS2-year panel with:
#   region, year, patent_count, log_patents,
#   patent_growth, patent_lag1, patent_per_capita
#
# Files:
#   - 202401_EPO_App_reg.txt
#   - 202401_EPO_IPC.txt
#   - demo_r_pjanaggr3__custom_20942564_spreadsheet.xlsx
#
# Output:
#   - EPO_NUTS2_2021_features1.csv
# ============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(readxl)
  library(tidyr)
  library(nuts)
  library(tibble)
})

# -------------------------------
# PART 1 — Inputs / settings
# -------------------------------
path_epo_app_reg <- "202401_EPO_App_reg.txt"
path_epo_ipc     <- "202401_EPO_IPC.txt"
path_population  <- "demo_r_pjanaggr3__custom_20942564_spreadsheet.xlsx"

time_var <- "Prio_year"   # "Prio_year" or "App_year"
out_file <- "EPO_NUTS2_2021_features1.csv"

stopifnot(file.exists(path_epo_app_reg), file.exists(path_epo_ipc))
stopifnot(file.exists(path_population))
stopifnot(time_var %in% c("Prio_year", "App_year"))

# -------------------------------
# PART 2 — Read REGPAT tables
# -------------------------------
epo_app <- read_delim(path_epo_app_reg, delim = "|", show_col_types = FALSE)
epo_ipc <- read_delim(path_epo_ipc,     delim = "|", show_col_types = FALSE)

names(epo_app) <- tolower(names(epo_app))
names(epo_ipc) <- tolower(names(epo_ipc))

time_var_lc <- tolower(time_var)

# -------------------------------
# PART 3 — Read and clean population file
# Eurostat Excel export in wide format
# Output: nuts2_2021, year, population
# -------------------------------
pop_raw <- read_excel(
  path_population,
  sheet = 1,
  col_names = FALSE
)

# Row 10 contains year headers in this export
year_row <- unlist(pop_raw[10, ], use.names = FALSE)
data_raw <- pop_raw[-c(1:10), ]

tmp_names <- c("nuts2_2021", "region_label", paste0("col_", seq_len(ncol(data_raw) - 2)))
names(data_raw) <- tmp_names

for (j in seq_along(names(data_raw))) {
  if (j >= 3) {
    yr_val <- suppressWarnings(as.character(year_row[j]))
    if (!is.na(yr_val) && grepl("^[0-9]{4}$", yr_val)) {
      names(data_raw)[j] <- yr_val
    }
  }
}

year_cols <- names(data_raw)[grepl("^[0-9]{4}$", names(data_raw))]

pop_df <- data_raw %>%
  transmute(
    nuts2_2021 = toupper(as.character(nuts2_2021)),
    across(all_of(year_cols), ~ suppressWarnings(as.numeric(.x)))
  ) %>%
  filter(!is.na(nuts2_2021)) %>%
  filter(grepl("^[A-Z]{2}[A-Z0-9]{2}$", nuts2_2021)) %>%   # NUTS2 codes only
  pivot_longer(
    cols = all_of(year_cols),
    names_to = "year",
    values_to = "population"
  ) %>%
  mutate(
    year = as.integer(year),
    population = as.numeric(population)
  ) %>%
  filter(!is.na(year))

# -------------------------------
# PART 4 — Attach year to applicant-region table
# -------------------------------
epo_years <- epo_ipc %>%
  select(appln_id, prio_year, app_year) %>%
  distinct(appln_id, .keep_all = TRUE)

epo_app_y <- epo_app %>%
  left_join(epo_years, by = "appln_id") %>%
  mutate(
    time = .data[[time_var_lc]],
    reg_code = toupper(as.character(reg_code)),
    ctry_code = toupper(as.character(ctry_code)),
    reg_share = suppressWarnings(as.numeric(reg_share)),
    app_share = suppressWarnings(as.numeric(app_share)),
    weight = reg_share * app_share
  ) %>%
  filter(!is.na(time), !is.na(reg_code), !is.na(weight))

# -------------------------------
# PART 5 — Build NUTS3 (2013) applicant counts
# -------------------------------
epo_nuts3_2013 <- epo_app_y %>%
  group_by(reg_code, time) %>%
  summarise(app_count = sum(weight, na.rm = TRUE), .groups = "drop") %>%
  transmute(
    geo   = toupper(reg_code),
    time  = as.integer(time),
    value = app_count
  )

# -------------------------------
# PART 6 — Keep only plausible NUTS3 codes
# -------------------------------
epo_nuts3_2013_only <- epo_nuts3_2013 %>%
  filter(nchar(geo) == 5) %>%
  filter(grepl("^[A-Z]{2}[A-Z0-9]{3}$", geo)) %>%
  filter(!grepl("ZZZ$", geo)) %>%
  filter(!grepl("000$", geo))

nuts_countries <- c(
  "AT","BE","BG","CH","CY","CZ","DE","DK","EE","EL","ES","FI","FR",
  "HR","HU","IE","IS","IT","LI","LT","LU","LV","MT","NL","NO","PL",
  "PT","RO","SE","SI","SK","UK"
)

epo_nuts3_2013_only <- epo_nuts3_2013_only %>%
  mutate(
    geo = toupper(as.character(geo)),
    cc  = substr(geo, 1, 2)
  ) %>%
  filter(cc %in% nuts_countries) %>%
  select(-cc)

# -------------------------------
# PART 7 — Classify NUTS codes and keep one version per year
# -------------------------------
cls1 <- nuts::nuts_classify(
  epo_nuts3_2013_only,
  nuts_code  = "geo",
  group_vars = "time"
)

get_cls_df <- function(x) {
  if (!is.null(x$data)) return(as_tibble(x$data))
  if (!is.null(x$classified_data)) return(as_tibble(x$classified_data))
  if (!is.null(x$nuts_data)) return(as_tibble(x$nuts_data))
  stop("Could not find classified data table inside nuts.classified object.")
}

cls1_df <- get_cls_df(cls1)

if ("from_code" %in% names(cls1_df) && !("geo" %in% names(cls1_df))) {
  cls1_df <- cls1_df %>% rename(geo = from_code)
}

cls1_df <- cls1_df %>%
  filter(!is.na(from_version), !is.na(from_level)) %>%
  filter(from_level == 3)

top_version_by_time <- cls1_df %>%
  count(time, from_version, name = "n") %>%
  arrange(time, desc(n)) %>%
  group_by(time) %>%
  slice(1) %>%
  ungroup() %>%
  select(time, keep_version = from_version)

data_one_version <- cls1_df %>%
  inner_join(top_version_by_time, by = "time") %>%
  filter(from_version == keep_version) %>%
  select(geo, time, value)

cls2 <- nuts::nuts_classify(
  data_one_version,
  nuts_code  = "geo",
  group_vars = "time"
)

# -------------------------------
# PART 8 — Convert version: NUTS -> 2021
# -------------------------------
epo_nuts3_2021 <- nuts::nuts_convert_version(
  cls2,
  to_version = "2021",
  variables  = c("value" = "absolute")
) %>%
  as_tibble()

code_col <- dplyr::case_when(
  "to_code" %in% names(epo_nuts3_2021) ~ "to_code",
  "geo"     %in% names(epo_nuts3_2021) ~ "geo",
  TRUE ~ NA_character_
)

if (is.na(code_col)) {
  stop("Cannot find NUTS code column in epo_nuts3_2021. Available columns: ",
       paste(names(epo_nuts3_2021), collapse = ", "))
}

# -------------------------------
# PART 9 — Aggregate NUTS3 (2021) -> NUTS2 (2021)
# -------------------------------
base_nuts2_time <- epo_nuts3_2021 %>%
  mutate(
    nuts3_2021 = .data[[code_col]],
    nuts2_2021 = substr(nuts3_2021, 1, 4)
  ) %>%
  group_by(nuts2_2021, time) %>%
  summarise(
    patent_count = sum(value, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(year = time) %>%
  arrange(year, nuts2_2021)

# -------------------------------
# PART 10 — Create requested features only
# -------------------------------
nuts2_features <- base_nuts2_time %>%
  arrange(nuts2_2021, year) %>%
  group_by(nuts2_2021) %>%
  mutate(
    log_patents   = log1p(patent_count),
    patent_growth = log_patents - lag(log_patents),
    patent_lag1   = lag(patent_count)
  ) %>%
  ungroup() %>%
  mutate(
    patent_growth = coalesce(patent_growth, 0),
    patent_lag1   = coalesce(patent_lag1, 0)
  ) %>%
  left_join(pop_df, by = c("nuts2_2021", "year")) %>%
  mutate(
    patent_per_capita = if_else(
      !is.na(population) & population > 0,
      patent_count / population,
      NA_real_
    )
  ) %>%
  transmute(
    region = nuts2_2021,
    year,
    patent_count,
    log_patents,
    patent_growth,
    patent_lag1,
    patent_per_capita
  ) %>%
  arrange(year, region)

# -------------------------------
# PART 11 — Save output
# -------------------------------
write_csv(nuts2_features, out_file)
message("Saved: ", out_file)

print(names(nuts2_features))
print(summary(nuts2_features$patent_count))
print(summary(nuts2_features$log_patents))
print(summary(nuts2_features$patent_growth))
print(summary(nuts2_features$patent_lag1))
print(summary(nuts2_features$patent_per_capita))