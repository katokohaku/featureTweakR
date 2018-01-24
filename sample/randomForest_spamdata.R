# feature tweaking: sample usage with spam data set -----------------------
require(tidyverse)
require(magrittr)
require(randomForest)
# devtools::install_github("hoxo-m/pforeach")
require(pforeach)

rm(list=ls())
source("./R/tweak_feature.R")


# data preparation -------------------------------------------------------------
set.seed(777)

data(spam, package = "kernlab")
dataset <- sample_frac(spam)
n.test <- floor(NROW(dataset) *0.1)

dataset.train <- chop(dataset, n.test)
dataset.test  <- tail(dataset, n.test)

dim(dataset);dim(dataset.train);dim(dataset.test)

# bilding randomForest -----------------------------------------
X <- dataset.train[, 1:(ncol(dataset.train)-1)]
true.y <- dataset.train[, ncol(dataset.train)]

forest.all <- randomForest(X, true.y, ntree=500)
forest.all
par(mfrow=c(1,2))
varImpPlot(forest.all) # to view varImp, x3 & x4 should be removed.
plot(forest.all)
par(mfrow=c(1,1))

# model shrinkage based on importance -------------------------
top.importance <- forest.all$importance %>% data.frame %>%
  tibble::rownames_to_column(var = "var") %>% 
  arrange(desc(MeanDecreaseGini)) %>% 
  head(12)

dataset.train.fs <- dataset.train %>% select(top.importance$var)
dataset.test.fs  <- dataset.test %>% select(top.importance$var)

# scaling feature-selected data  ---------------------------
X.train <- scale( dataset.train.fs )
X.test  <- rescale( dataset.test.fs, scaled = X.train )

dataset.test.fs[1:6, 1:6]
descale(X.test, scaled = X.train)[1:6, 1:6]
descale(X.test, scaled = X.test)[1:6, 1:6]

forest.rf <- randomForest(X.train, true.y, ntree=100)

forest.all
forest.rf
plot(forest.rf)


# feature tweaking  ---------------------------------------------------------------

# test sampling (for demo)
ep <- getRules.randomForest(forest.rf, k=2, label.to = NULL)
ep %>% str(2)
ep[["spam"]]$path[[1]]

# es.rf_ <- set.eSatisfactory(forest.rf, ntree = 30, epsiron = 0.3)
es.rf <- set.eSatisfactory(forest.rf, ntree = 30, epsiron = 0.3, resample = TRUE)
es.rf %>% str(2)


# eval predicted instance -------------------------------------------------

# tweaked_ <- tweak(es.rf, newdata= X.test, label.from = "spam", label.to = "nonspam",
#                  .dopar = FALSE)
tweaked <- tweak(es.rf, newdata= X.test, label.from = "spam", label.to = "nonspam",
                 .dopar = TRUE)
tweaked %>% str


dt <- descale.tweakedFeature(tweaked, X.test)
dt %>% str(1)

# plot suggestion for each instance
which(tweaked$predict == "spam")
plot.suggest(tweaked, 4)
plot.suggest(tweaked, 11)
plot.suggest(tweaked, 15)
plot.suggest(tweaked, 15, .ordered = TRUE, .nonzero.only = TRUE)


# Plot population importances
pp <- plot.tweakedPopulation(tweaked, "a")
pp <- plot.tweakedPopulation(tweaked, "d")
pp <- plot.tweakedPopulation(tweaked, "f")

# end ---------------------------------------------------------------------
