library(feather)
library(palab)
library(dplyr)
# Read the dataframe
df <- read_feather('F:/Projects/Pfizer_mCRPC/Data/Raw_data/Oncology_EMR/02_Oncology_EMR_cleaned_with_dummies_with_dd_no_sparse.feather')

# Generate the config file, both to csv and assign it to var_config
var_config_generator(input_df = df, 
                     prefix = "01_Oncology_EMR_with_datediff_and_dummies", 
                     output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")

# Changed patient_id to key and load var_config in 
var_config <- read.csv("F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR/01_Oncology_EMR_with_datediff_and_dummies_var_config.csv")

# problem with two column names ending with + and -
colnames(df)[names(df) == "onc_latest_n_n0_i+"] <- "onc_latest_n_n0_iplus"
colnames(df)[names(df) == "onc_latest_n_n0_i-"] <- "onc_latest_n_n0_iminus"
var_config$Column <- as.character(var_config$Column)
var_config[var_config$Column == 'onc_latest_n_n0_i+',]$Column <- "onc_latest_n_n0_iplus"
var_config[var_config$Column == 'onc_latest_n_n0_i-',]$Column <- "onc_latest_n_n0_iminus"

# Split datedifference columns and other columns in two dataframes, as bivariate stats for datedifference columns
# are calculated with vargt0 = FALSE, while the others have vargt0 = TRUE
var_config_dd <- var_config[grep(paste(c('_dd', 'pn_flag', 'patient_id'), collapse = '|'), x = var_config$Column),]
var_config_dd$Column <- as.character(var_config_dd$Column)
ls_dd_columns <- as.character(var_config_dd$Column)
df_dd <- df[ls_dd_columns]

var_config_no_dd <- var_config[!grepl('_dd', x = var_config$Column),]
var_config_no_dd$Column <- as.character(var_config_no_dd$Column)
ls_no_dd_columns <- as.character(var_config_no_dd$Column)
df_nodd <- df[ls_no_dd_columns]

  
# Run full output bivar_stats
bivar_stats_y_flag(df, var_config = var_config, 
                   prefix = '01_FULL_Oncology_EMR_all_columns_', outcome_var = 'pn_flag',
                   concise_output = FALSE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")

# Run concise output bivar_stats
# For the not datedifference columns, with vargt0 = TRUE
bivar_stats_y_flag(df_nodd, var_config = var_config_no_dd, 
                   prefix = '01_CONCISE_Oncology_EMR_no_datediff_', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")
# and the datedifference columns, with vargt0 = FALSE
bivar_stats_y_flag(df_dd, var_config = var_config_dd, 
                   prefix = '01_CONCISE_Oncology_EMR_only_datediff_', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = FALSE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")


