library(mlr)
library(palabmod)
library(feather)
library(palab)
library(dplyr)
library(ggplot2)
library(reshape2)
library(BBmisc)
library(xgboost)
library(readr)

df <- read.csv('F:/Projects/Pfizer_mCRPC/Data/pre_modelling/Combined/01_Lrx_Dx_HCPCos_EMR_with_datediff_dummies_no_sparse.csv')

# Some problem with the column names
pattern <- "[^[:alnum:]_]"
colnames(df)[grep(pattern, colnames(df))]
# Let's try to replace all these bad characters by _
colnames(df)[grep(pattern, colnames(df))] <- gsub(pattern, '_', colnames(df)[grep(pattern, colnames(df))])
# Funky characters are gone
grep(pattern, colnames(df))

# Check imbalance 
sum(df$pn_flag == 0)
sum(df$pn_flag == 1)

# Build XGboost with resampling ------------------------------------------------------
# Make pn_flag a factor and get rid of patient_id
df$pn_flag <- as.factor(df$pn_flag)
patient_ids <- df$patient_id
df <- subset(df, select = -c(patient_id, hhi, hcp_adt_score, hcp_agonist_pat_cnt, hcp_antagonist_pat_cnt))

# Make learner, task and resampling desc
task <- makeClassifTask(id = 'lrx_dx_data', df, target = 'pn_flag', positive = 1)
lrn <- makeLearner("classif.xgboost", predict.type = "prob", nrounds = 20)
rdesc <- makeResampleDesc("CV", iters = 5)


# Train models
res <- resample(lrn, task, rdesc, extract = getFeatureImportance)


# PR Curve ---------------------------------------------------------------------------
# PR curve
# Looks realistic
palabmod::perf_plot_pr_curve(res$pred) + scale_y_continuous(limits = c(0,1))
# binned values
pr_binned_values <- palabmod::perf_binned_perf_curve(res$pred, bin_num = 20)
write.csv(pr_binned_values, "First_PRCurve_XGBoost_AllData_5CV_Binned_20180111.csv", row.names = FALSE)


# AUC ROC rather good
ROCR::performance(asROCRPrediction(res$pred), measure = "auc")


# Average feature importance ---------------------------------------------------------
df_imp <- (lapply(res$extract, function(x) { data.frame("Imp" = t(x$res))})) %>% 
             Reduce(f = `+`) %>% 
              sortByCol(col='Imp', asc = FALSE)
df_imp$Column <- rownames(df_imp) 
var_config_imp <- left_join(var_config_with_descr, df_imp, by = "Column") %>%
  sortByCol(col = 'Imp', asc = FALSE)
head(var_config_imp)



# Build XGboost without resampling to get detailed variable importance-----------------------
# Train model
mod <- train(lrn, task)

# Prediction
prediction <- predict(mod, task)

# PR curve
# Looks realistic, but considerable higher, does this mean overfitting?
palabmod::perf_plot_pr_curve(prediction) + scale_y_continuous(limits = c(0,1))
