# Run checks prior to submitting 

# First to build win so I can proceed with local while it is tested remotely 

# for vignette size warning. Since vignettes are only built locally, I only need add this argument
devtools::build_win('.', version = 'R-release', args = c('--resave-data','--compact-vignettes="gs+qpdf"')) 
devtools::build_win('.', version = 'R-devel', args = c('--resave-data','--compact-vignettes="gs+qpdf"')) ) 

devtools::check(args = '--as-cran', cran = TRUE, check_version = TRUE, build_args = c('--resave-data','--compact-vignettes="gs+qpdf"'))
# cran = FALSE probably runs tests skipped on cran
devtools::check(cran = FALSE, check_version = TRUE, args = '--as-cran')
devtools::check(cran = TRUE, check_version = TRUE )    
devtools::check(cran = FALSE, check_version = TRUE) 