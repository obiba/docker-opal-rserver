# install R libraries in a R version independent directory
if (!file.exists("/srv/R/library")) {
  dir.create("/srv/R/library", recursive=TRUE)
}
.libPaths("/srv/R/library")
# for Pandoc
Sys.setenv(HOME="/srv")
# newline required
