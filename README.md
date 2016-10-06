
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/jmarshallnz/statsNZ.svg?branch=master)](https://travis-ci.org/jmarshallnz/statsNZ) [![Coverage Status](https://img.shields.io/codecov/c/github/jmarshallnz/statsNZ/master.svg)](https://codecov.io/github/jmarshallnz/statsNZ?branch=master)

statsNZ
=======

The statsNZ package allows access to the [StatisticsNZ](http://www.stats.govt.nz/) [API](https://statisticsnz.portal.azure-api.net/) from within R.

This is very much a work in progress! The StatisticsNZ API is brand new and still in the testing phase.

This package will very likely change in the future!

Installation
------------

statsNZ is not currently available from CRAN, but you can install it from github with:

``` r
# install.packages("devtools")
devtools::install_github("jmarshallnz/statsNZ")
```

Usage
-----

``` r
library(statsNZ)

#' Take a look at the expected what data are available
available_stats()

#' See what groups are available for the alcohol statistics
get_groups('ALC')

#' Fetch some statistics for the Litres of Beverage consumed
alc <- get_stats("ALC", "Litres of Beverage")

#' Some of this information is yearly totals rather than quarterly, so to
#' plot we first filter some stuff out

library(dplyr)
library(ggplot2)
alc %>%
  filter(substr(SeriesReference, 1, 4) != 'ALCQ') %>%
  ggplot(aes(x=Period, y=DataValues)) +
    geom_line(aes(colour=SeriesTitle1)) +
    xlab("") +
    ylab("Litres of Beverage") + 
    theme(legend.title = element_blank())
```

![](README-alcohol-1.png)
