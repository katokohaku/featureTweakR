# Restore tweaked instances to the original scale

descale.tweakedFeature <- function(tweaked.X, scaled.X){
  stopifnot(class(tweaked.X) == "tweaked.suggestion", !missing(scaled.X))
  original <- descale(tweaked.X$original, scaled.X)
  suggest <- descale(tweaked.X$suggest, scaled.X)

  return(list(original = original, suggest = suggest,
              diff = as.tibble(suggest - original)) )
}
