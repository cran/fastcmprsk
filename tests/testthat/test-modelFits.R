library("testthat")
library("fastcmprsk")
library("cmprsk")
library("crrp")

context("test-modelFits.R")


test_that("Compare crr with fastCrr", {
  set.seed(4291)
  ftime <- rexp(200)
  fstatus <- sample(0:2, 200, replace = TRUE)
  cov <- matrix(runif(1000), nrow = 200)
  dimnames(cov)[[2]] <- c('x1','x2','x3','x4','x5')
  fit <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE)

  cov <- matrix(runif(600),nrow=200)

  fit.crr    <- crr(ftime, fstatus, cov, variance = FALSE)
  fit.fast   <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE)
  expect_equal(as.vector(fit.crr$coef), as.vector(fit.fast$coef), tolerance = 1E-4)
})

test_that("Compare crr with fastCrr w/ tied data", {
  set.seed(4291)
  ftime <- round(rexp(200) + 50, 0)
  fstatus <- sample(0:2,200,replace=TRUE)
  cov <- matrix(runif(600),nrow=200)

  fit.crr    <- crr(ftime, fstatus, cov, variance = FALSE)
  fit.fast   <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE)
  expect_equal(as.vector(fit.crr$coef), as.vector(fit.fast$coef), tolerance = 1E-4)
})

# 02/27/24: Removed crrp check since crrp is not available on CRAN as of 02/27/24
# test_that("Compare crrp with fastCrrp ", {
#   set.seed(4291)
#   ftime <- rexp(200)
#   fstatus <- sample(0:2,200,replace=TRUE)
#   cov <- matrix(runif(600),nrow=200)
#
#   #LASSO
#   fit.crrp    <- crrp(ftime, fstatus, cov, penalty = "LASSO", lambda = 0.01)
#   fit.fast   <- fastCrrp(Crisk(ftime, fstatus) ~ cov, penalty = "LASSO", lambda = 0.01)
#   expect_equal(as.vector(fit.crrp$beta), as.vector(fit.fast$coef), tolerance = 1E-4)
#
#   #SCAD
#   fit.crrp    <- crrp(ftime, fstatus, cov, penalty = "SCAD", lambda = 0.01)
#   fit.fast   <- fastCrrp(Crisk(ftime, fstatus) ~ cov, penalty = "SCAD", lambda = 0.01)
#   expect_equal(as.vector(fit.crrp$beta), as.vector(fit.fast$coef), tolerance = 1E-4)
#
#
#   #MCP
#   fit.crrp    <- crrp(ftime, fstatus, cov, penalty = "MCP", lambda = 0.01)
#   fit.fast   <- fastCrrp(Crisk(ftime, fstatus) ~ cov, penalty = "MCP", lambda = 0.01)
#   expect_equal(as.vector(fit.crrp$beta), as.vector(fit.fast$coef), tolerance = 1E-4)
#
# })

test_that("Compare crr with fastCrr (breslow jumps)", {
  set.seed(4291)
  ftime <- rexp(200)
  fstatus <- sample(0:2,200,replace=TRUE)
  cov <- matrix(runif(600),nrow=200)

  fit.crr    <- crr(ftime, fstatus, cov, variance = FALSE)
  fit.fast   <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE)
  expect_equal(as.vector(fit.crr$bfitj), as.vector(fit.fast$breslowJump[, 2]), tolerance = 1E-4)
})

test_that("Compare crr with fastCrr (CIF)", {
  set.seed(4291)
  ftime <- rexp(200)
  fstatus <- sample(0:2,200,replace=TRUE)
  cov <- matrix(runif(600),nrow=200)

  fit.crr    <- crr(ftime, fstatus, cov, variance = FALSE)
  fit.fast   <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE, returnDataFrame = TRUE)
  z0 <- rnorm(3)
  p1 <- predict(fit.crr, cov1 = z0)[,2]
  p2 <- predict(fit.fast, newdata = z0, getBootstrapVariance = FALSE)$CIF
  expect_equal(p1, p2, tolerance = 1E-4)
})

test_that("Compare crr with fastCrr w/o censoring", {
  set.seed(4291)
  ftime <- rexp(200)
  fstatus <- sample(1:2,200,replace=TRUE)
  cov <- matrix(runif(600),nrow=200)

  fit.crr    <- crr(ftime, fstatus, cov, variance = FALSE)
  # Expect a warning due to no censoring code
  expect_warning(fit.fast   <- fastCrr(Crisk(ftime, fstatus) ~ cov, variance = FALSE, returnDataFrame = TRUE))

  expect_equal(as.vector(fit.crr$coef), as.vector(fit.fast$coef), tolerance = 1E-4)

})
