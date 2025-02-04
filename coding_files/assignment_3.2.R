library(tidyverse)
# This is an example of inserting large datasets
psql_append_df(cred = cred_psql_docker, 
               schema_name = "example_schema",
               tab_name = "example_table",
               df = data)