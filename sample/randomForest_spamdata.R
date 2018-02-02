# feature tweaking: sample usage with spam data set -----------------------
require(tidyverse)
require(magrittr)
require(randomForest)
# devtools::install_github("hoxo-m/pforeach")
# require(pforeach)
require(featureTweakR)

rm(list=ls())
set.seed(777)


# data preparation -------------------------------------------------------------

data(spam, package = "kernlab")
dataset <- sample_frac(spam) %>% dataSplit(test.ratio = 0.1)


# bilding randomForest -----------------------------------------
X <- dataset$train[, 1:(ncol(dataset$train)-1)]
true.y <- dataset$train[, ncol(dataset$train)]

forest.all <- randomForest(X, true.y, ntree=500)
forest.all
par(mfrow=c(1,2))
varImpPlot(forest.all) # to view varImp, x3 & x4 should be removed.
plot(forest.all)
par(mfrow=c(1,1))

# model shrinkage based on importance -------------------------
top.importance <- forest.all$importance %>%
  data.frame %>%
  tibble::rownames_to_column(var = "var") %>%
  arrange(desc(MeanDecreaseGini)) %>%
  head(12)

X.train = dataset$train %>% select(top.importance$var)
newdata = dataset$test %>% select(top.importance$var)
true.y  = true.y
ntree   = 100

forest.rf <- randomForest(X.train, true.y, ntree = ntree)

forest.all
forest.rf
plot(forest.rf)

# test sampling (for demo)
ep <- featureTweakR:::getRules.randomForest(forest.rf, k=2, label.to = NULL)
ep %>% str(2)
ep[["spam"]]$path[[1]]

# feature tweaking  -----------------------------------------------
ktree    = 22
resample = TRUE

train.scaled <- scale(X.train)
test.scaled  <- rescale(newdata, scaled = train.scaled)
forest.rf <- randomForest(train.scaled, true.y, ntree = ktree)

print(forest.rf)
plot(forest.rf)

rules.rf <- getRules(forest.rf, ktree = ktree, resample = resample)
es.rf   <- set.eSatisfactory(rules.rf, epsiron = 0.3)



tweaked <- tweak(es.rf, forest = forest.rf, newdata= test.scaled,
                 label.from = "spam", label.to = "nonspam",
                 .dopar = TRUE)

tweaked %>% str
tweaked$original- tweaked$suggest


dt <- descale.tweakedFeature(tweaked, X.test)
dt %>% str(1)

# plot suggestion for each instance
which(tweaked$predict == "spam")
plotSuggest(tweaked, 4)
plotSuggest(tweaked, 11)
plotSuggest(tweaked, 15)
plotSuggest(tweaked, 15, .ordered = TRUE, .nonzero.only = TRUE)


# Plot population importances
pp <- plot(tweaked, type="a")
pp <- plot(tweaked, type="d")
pp <- plot(tweaked, type="f")

# end ---------------------------------------------------------------------
