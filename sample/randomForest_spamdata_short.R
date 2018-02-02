# feature tweaking: sample usage with spam data set -----------------------
require(tidyverse)
require(featureTweakR)

rm(list=ls())
set.seed(777)

# data preparation -------------------------------------------------------------
data(spam, package = "kernlab")
dataset <- sample_frac(spam) %>% dataSplit(test.ratio = 0.1)

important.var <- c("charExclamation", "charDollar", "remove", "free", "capitalAve", "capitalLong", "your", "hp")
data.train <- dataset$train %>% select(important.var)
true.y     <- dataset$train[ ,ncol(dataset$train)]

data.test  <- dataset$test  %>% select(important.var) %>% head(50)

# feature tweaking  -----------------------------------------------

# learn model
es <- learnModel(X.train = data.train, true.y = true.y, ntree = 22)
ft <- predict(es, newdata = data.test, label.from = "spam", label.to = "nonspam")
# ft %>% str(2)


plot(ft, k=4)
# plot(ft, k=4, .nonzero.only = TRUE)
# plot(ft, k=1)

plot(ft, type = "direction")
# plot(ft, type = "frequency")



# end ---------------------------------------------------------------------
