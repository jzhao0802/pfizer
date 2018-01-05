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

# Run full output bivar_stats
bivar_stats_y_flag(df, var_config = var_config_with_descr, 
                   prefix = '04_pfizer_total_with_dd_no_flags', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats")

# Run bivar_stats on date_difference columns with vargt0 = FALSE
var_config_dd <- var_config_with_descr[grep(paste(c('_dd', 'pn_flag', 'patient_id'), collapse = '|'), x = var_config_with_descr$Column),]
var_config_dd$Column <- as.character(var_config_dd$Column)
ls_dd_columns <- as.character(var_config_dd$Column)
df_dd <- df[ls_dd_columns]
bivar_stats_y_flag(df_dd, var_config = var_config_dd, 
                   prefix = '04_pfizer_total_only_dd_', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = FALSE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats")
