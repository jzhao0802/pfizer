library(feather)
library(palab)

# Read the dataframe
df <- read_feather('F:/Projects/Pfizer_mCRPC/Data/Raw_data/Oncology_EMR/02_Oncology_EMR_cleaned_with_dummies_with_dd_no_sparse.feather')

# Generate the config file, both to csv and assign it to var_config
var_config_generator(input_df = df, 
                     prefix = "01_Oncology_EMR_with_datediff_and_dummies", 
                     output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")

# Changed patient_id to key and load var_config in 
var_config <- read.csv("F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR/01_Oncology_EMR_with_datediff_and_dummies_var_config.csv")


# Run concise output bivar_stats
bivar_stats_y_flag(df, var_config = var_config, 
                   prefix = '01_CONCISE_Oncology_EMR_with_datediff_and_dummies', outcome_var = 'pn_flag',
                   concise_output = TRUE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")

# Run full output bivar_stats
bivar_stats_y_flag(df, var_config = var_config, 
                   prefix = '01_FULL_Oncology_EMR_with_datediff_and_dummies', outcome_var = 'pn_flag',
                   concise_output = FALSE, vargt0 = TRUE, date_diff_code = "_dd", 
                   output_dir = "F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/Oncology_EMR")
