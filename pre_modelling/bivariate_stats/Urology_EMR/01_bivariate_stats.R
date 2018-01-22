library(readr)
library(palab)
library(dplyr)
# Read the dataframe
df <- read.csv('F:/Projects/Pfizer_mCRPC/Data/pre_modelling/EMR_Urology/02_EMR_urology_with_dd_with_dummies_no_sparse.csv')
df$X <- NULL

# Generate the config file, both to csv and assign it to var_config
var_config_generator(input_df = df, 
                     prefix = "01_Urology_EMR_dd_dummies_no_sparse_", 
                     output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Urology_EMR")

# Changed patient_id to key and load var_config in 
var_config <- read.csv("F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Urology_EMR/01_Urology_EMR_dd_dummies_no_sparse__var_config.csv")


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
                   prefix = '01_FULL_Urology_EMR_all_columns_', outcome_var = 'pn_flag',
                   concise_output = FALSE, vargt0 = FALSE, date_diff_code = "_dd", 
                   output_dir = "F:/Projects/Pfizer_mCRPC/Results/Descriptive_stats/Urology_EMR")

# Run full output bivar_stats
bivar_stats_y_flag(df, var_config = var_config, 
                   prefix = '01_CONCISE_Urology_EMR_all_columns_', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = FALSE, date_diff_code = "_dd", 
                   output_dir = "F:/Projects/Pfizer_mCRPC/Results/Descriptive_stats/Urology_EMR")
