library(feather)
library(palab)

# Read the dataframe
df <- read_feather('F:/Projects/Pfizer_mCRPC/Data/Raw_data/04_total_with_datediff_and_dummies_no_flags.feather')

# Generate the config file, both to csv and assign it to var_config
var_config <- var_config_generator(input_df = df, 
                     prefix = "04_with_datediff_and_dummies_no_flags", 
                     output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats")

# Added description columns to the var_config file in Python, need to reload
var_config_with_descr <- read.csv("F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/04_with_datediff_and_dummies_no_flags_var_config.csv")

# Clean up some bad characters in the column names of the custom HCP columns
# var_config_with_descr$Column <- gsub(paste(c('&', '/', '-', ','), collapse = "|"), '', var_config_with_descr$Column)

# Assign key to patient_id row
# var_config_with_descr[1,'Type'] <- 'key'

# Run full output bivar_stats
bivar_stats_y_flag(df, var_config = var_config_with_descr, 
                   prefix = '04_pfizer_total_with_dd_no_flags', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats")
