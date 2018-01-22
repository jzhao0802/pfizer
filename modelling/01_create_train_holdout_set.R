library(feather)
library(readr)
library(dplyr)


# Load data
df_emr <- read.csv('F:/Projects/Pfizer_mCRPC/Data/pre_modelling/Combined/01_Lrx_Dx_HCPCos_EMR_with_datediff_dummies_no_sparse.csv')
df_lrx_dx <- read_feather('F:/Projects/Pfizer_mCRPC/Data/pre_modelling/LRx_Dx_HCPHCos/04_total_with_datediff_and_dummies.feather')

# Fraction holdout set
fract_holdout = 0.2

# EMR patients train-test holdout split -----------------------------------------------------
# Get positive and negative patient IDs
emr_ids_pos <- df_emr[df_emr$pn_flag == 1,]$patient_id
emr_ids_neg <- df_emr[df_emr$pn_flag == 0,]$patient_id

# Get the number of positive and negative patients
n_pos <- length(emr_ids_pos)
n_neg <- length(emr_ids_neg)

# Sample a fraction of both negative and positive as test holdout
emr_ids_pos_holdout <- emr_ids_pos %>% sample(n_pos*fract_holdout)
emr_ids_neg_holdout <- emr_ids_neg %>% sample(n_neg*fract_holdout)

# Take the other patient ids as training set
emr_ids_pos_train <- setdiff(emr_ids_pos, emr_ids_pos_holdout)
emr_ids_neg_train <- setdiff(emr_ids_neg, emr_ids_neg_holdout)

# Join the pos and neg together
emr_ids_train <- c(emr_ids_pos_train, emr_ids_neg_train)
emr_ids_holdout <- c(emr_ids_pos_holdout, emr_ids_neg_holdout)

# LRx/Dx only patients --------------------------------------------------------------------
# Get positive and negative patient IDs
lrx_ids_pos <- df_lrx_dx[df_lrx_dx$pn_flag == 1,]$patient_id
lrx_ids_neg <- df_lrx_dx[df_lrx_dx$pn_flag == 0,]$patient_id

# Get positive and negatives of LRx only patients
lrx_only_ids_pos <- setdiff(lrx_ids_pos, emr_ids_pos)
lrx_only_ids_neg <- setdiff(lrx_ids_neg, emr_ids_neg)

# Get the number of positve and negative patients
n_pos_lrx_only <- length(lrx_only_ids_pos)
n_neg_lrx_only <- length(lrx_only_ids_neg)

# Sample for holdout set
lrx_only_ids_pos_holdout <- lrx_only_ids_pos %>% sample(n_pos_lrx_only*fract_holdout)
lrx_only_ids_neg_holdout <- lrx_only_ids_neg %>% sample(n_neg_lrx_only*fract_holdout)

# Take the other patient ids as training set
lrx_only_ids_pos_train <- setdiff(lrx_only_ids_pos, lrx_only_ids_pos_holdout)
lrx_only_ids_neg_train <- setdiff(lrx_only_ids_neg, lrx_only_ids_neg_holdout)


# LRx/Dx patients train-test holdout split ---------------------------------------------
lrx_ids_pos_train <- c(lrx_only_ids_pos_train, emr_ids_pos_train)
lrx_ids_neg_train <- c(lrx_only_ids_neg_train, emr_ids_neg_train)
lrx_ids_train <- c(lrx_ids_pos_train, lrx_ids_neg_train)

lrx_ids_pos_holdout <- c(lrx_only_ids_pos_holdout, emr_ids_pos_holdout)
lrx_ids_neg_holdout <- c(lrx_only_ids_neg_holdout, emr_ids_neg_holdout)
lrx_ids_holdout <- c(lrx_ids_pos_holdout, lrx_ids_neg_holdout)

# Some sanity checks ------------------------------------------------------------------
# The train/holdout ratio is correct
length(lrx_ids_train)/length(lrx_ids_holdout)
length(emr_ids_train)/length(emr_ids_holdout)

# No train/holdout overlap
sum(lrx_ids_holdout %in% lrx_ids_train)
sum(emr_ids_holdout %in% emr_ids_train)

# The EMR sets are subsets of the lrx sets
all(emr_ids_train %in% lrx_ids_train)
all(emr_ids_holdout %in% lrx_ids_holdout)

# Class imbalances seem good
1/mean(df_lrx_dx[df_lrx_dx$patient_id %in% lrx_ids_train,]$pn_flag)
1/mean(df_emr[df_emr$patient_id %in% emr_ids_train,]$pn_flag)


# Export different datasets -----------------------------------------------------------
df_emr_train <- df_emr[df_emr$patient_id %in% emr_ids_train,]
df_emr_holdout <- df_emr[df_emr$patient_id %in% emr_ids_holdout,]

df_lrx_train <- df_lrx_dx[df_lrx_dx$patient_id %in% lrx_ids_train,]
df_lrx_holdout <- df_lrx_dx[df_lrx_dx$patient_id %in% lrx_ids_holdout,]

write_feather(df_emr_train, 'F:/Projects/Pfizer_mCRPC/Data/modelling/LRx_Dx_HCPCos_EMR/01_TRAIN_LRx_Dx_HCP_EMR.feather')
write_feather(df_emr_holdout, 'F:/Projects/Pfizer_mCRPC/Data/modelling/LRx_Dx_HCPCos_EMR/01_TEST_LRx_Dx_HCP_EMR.feather')

write_feather(df_lrx_train, 'F:/Projects/Pfizer_mCRPC\Data/modelling/LRx_Dx_HCPCos/01_TRAIN_LRx_Dx_HCP.feather')
write_feather(df_lrx_holdout, 'F:/Projects/Pfizer_mCRPC/Data/modelling/LRx_Dx_HCPHCos/01_TEST_LRx_Dx_HCP.feather')






