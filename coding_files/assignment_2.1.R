library(RPostgres)
library(DBI)

# load credentials
source("exam_folder/.credentials_exam.R")

# load functions to send queries to Postgres
source("exam_folder/psql_queries.R")

# create marketing schema
psql_manipulate(cred = cred_psql_docker, 
                query_string = "CREATE SCHEMA marketing;")

# create marketing_campaign table
psql_manipulate(cred = cred_psql_docker, 
                query_string = "
CREATE TABLE marketing.marketing_campaign (
    campaign_id serial primary key,
    campaign_name text,
    budget decimal(6,1),
    start_date timestamp,
    is_active boolean
);")

# create data frame
df <- data.frame(
  campaign_name = "Holiday Sale Campaign",
  budget = 5000,
  start_date = as.POSIXct("2024-12-01 08:00:00.00", format = "%Y-%m-%d %H:%M:%S"),
  is_active = TRUE
)

# Append data frame to the table
psql_append_df(cred = cred_psql_docker,
               schema_name = "marketing",
               tab_name = "marketing_campaign",
               df = df)
