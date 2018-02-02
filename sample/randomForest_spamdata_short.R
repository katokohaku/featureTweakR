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

important.var <- c("charExclamation", "charDollar", "remove", "free", "capitalAve", "capitalLong", "your", "hp")
data.train <- dataset$train %>% select(important.var)
data.test  <- dataset$test  %>% select(important.var)

true.y <- dataset$train[ ,ncol(dataset$train)]


# feature tweaking  -----------------------------------------------

buildInstance(X.train = data.train, true.y = true.y, .tryModel = TRUE)
es <- buildInstance(X.train = data.train, true.y = true.y, ntree = 22)


newdata = data.test

test.scaled  <- rescale(newdata, scaled = train.scaled)
tweaked <- tweak(es, forest = forest.rf, newdata= test.scaled,
                 label.from = "spam", label.to = "nonspam",
                 .dopar = TRUE)

tweaked %>% str
tweaked$original- tweaked$suggest

dt <- descale.tweakedFeature(tweaked, test.scaled)
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
