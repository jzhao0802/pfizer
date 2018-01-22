library(mlr)
library(palabmod)
library(feather)
library(palab)
library(dplyr)
library(ggplot2)
library(reshape2)
library(BBmisc)
library(xgboost)

df <- read_feather('F:/Projects/Pfizer_mCRPC/Data/pre_modelling/LRx_Dx_HCPHCos/04_total_with_datediff_and_dummies.feather')
var_config_with_descr <- read.csv("F:/Frederik/pfizer_mcrpc/pfizer_mcrpc/pre_modelling/bivariate_stats/LRx_Dx/var_config_with_descriptions.csv")

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
df <- subset(df, select = -patient_id)

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

# AUC ROC very good
ROCR::performance(asROCRPrediction(res$pred), measure = "auc")


# Average feature importance ---------------------------------------------------------
df_imp <- (lapply(res$extract, function(x) { data.frame("Imp" = t(x$res))}) %>% Reduce(f = `+`))/5
df_imp$Column <- rownames(df_imp)
var_config_imp <- left_join(var_config_with_descr, df_imp, by = "Column") %>%
  sortByCol(col = 'Imp', asc = FALSE)
head(var_config_imp)

# Write out to CSV
write.csv(var_config_imp, "variable_importance_with_descriptions_XGBoost_20180111.csv", row.names = FALSE)

# hhi and g214024 are by the most important
# hhi is most important feature
ggplot(data = df, mapping = aes(hhi, group = pn_flag, fill = pn_flag)) + 
  geom_density(alpha = 0.3)

# g214024_index_min_dd and g214024_max_min_dd are second and third
ggplot(data = df, mapping = aes(g214024_index_min_dd, group = pn_flag, fill = pn_flag)) + 
  geom_density(alpha = 0.3)



# Build XGboost without resampling to get detailed variable importance-----------------------
# Train model
mod <- train(lrn, task)

# Prediction
prediction <- predict(mod, task)

# PR curve
# Looks realistic, but considerable higher, does this mean overfitting?
palabmod::perf_plot_pr_curve(prediction) + scale_y_continuous(limits = c(0,1))

# plot ROC curve, trained on all data, of course looks quite high
plotROCCurves(generateThreshVsPerfData(prediction, 
                                       list(fpr, tpr)), diagonal = FALSE)

# AUC ROC very good
ROCR::performance(asROCRPrediction(prediction), measure = "auc")

df_imp_onetree <- getFeatureImportance(mod)$res %>% sort(decreasing = TRUE)
df_imp_onetree[1:10]

# DETAILED VARIABLE IMPORTANCE
# Change to numeric matrix
df_matrix <- as.matrix(df) %>% as.numeric() %>% matrix(ncol=4598)
colnames(df_matrix) <- colnames(df)

# extract detailed variable importance
detailed_vi <- xgb.importance(feature_names = mod$features,
                              model = mod$learner.model,
                              data = df_matrix, label = df_matrix[,1])



















  





