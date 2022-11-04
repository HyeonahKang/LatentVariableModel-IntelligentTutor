# Code to reproduce LCM results

To reproduce the LCM results (Section 3 and Appendix B) simply run, in `R`, first make sure that the following packages are installed: `rstan`, `tidyverse`, and `xtable`. Please see below for `R` and package version numbers.

Then, run:

```
source('runLCM.r')
```

This will produce latex-formatted tables:

- `tab2.tex` for Table 2
- `tab3.tex` and `tab3cutoffs.tex` that, combined, make Table 3
- `tab4.tex` for Table 4
- `varComp.tex` which is not included in the paper as a table, but which includes estimates of variance components which appear in the text.
- `tableA3.tex` for Table A3 in Appendix B


It also produces artifacts (e.g. fitted models), console output, and some plots.

Note that running `fitMods.r` may take a very long time.

```
 > sessionInfo()
R version 4.1.1 (2021-08-10)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19044)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252
[2] LC_CTYPE=English_United States.1252
[3] LC_MONETARY=English_United States.1252
[4] LC_NUMERIC=C
[5] LC_TIME=English_United States.1252

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
 [1] xtable_1.8-4         forcats_0.5.1        stringr_1.4.0
 [4] dplyr_1.0.7          purrr_0.3.4          readr_2.0.2
 [7] tidyr_1.1.4          tibble_3.1.5         tidyverse_1.3.1
[10] rstan_2.21.5         ggplot2_3.3.5        StanHeaders_2.21.0-7

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.7         lubridate_1.8.0    prettyunits_1.1.1  ps_1.6.0
 [5] assertthat_0.2.1   utf8_1.2.2         R6_2.5.1           cellranger_1.1.0
 [9] backports_1.2.1    reprex_2.0.1       stats4_4.1.1       httr_1.4.2
[13] pillar_1.6.4       rlang_0.4.11       readxl_1.3.1       rstudioapi_0.13
[17] callr_3.7.0        loo_2.4.1          munsell_0.5.0      broom_0.7.9
[21] compiler_4.1.1     modelr_0.1.8       pkgconfig_2.0.3    pkgbuild_1.2.0
[25] tidyselect_1.1.1   gridExtra_2.3      codetools_0.2-18   matrixStats_0.61.0
[29] fansi_0.5.0        crayon_1.4.2       tzdb_0.1.2         dbplyr_2.1.1
[33] withr_2.4.2        grid_4.1.1         jsonlite_1.7.2     gtable_0.3.0
[37] lifecycle_1.0.1    DBI_1.1.1          magrittr_2.0.1     scales_1.1.1
[41] RcppParallel_5.1.4 cli_3.1.0          stringi_1.7.5      fs_1.5.0
[45] xml2_1.3.2         ellipsis_0.3.2     generics_0.1.1     vctrs_0.3.8
[49] tools_4.1.1        glue_1.4.2         hms_1.1.1          processx_3.5.2
[53] parallel_4.1.1     inline_0.3.19      colorspace_2.0-2   rvest_1.0.1
[57] haven_2.4.3
```
