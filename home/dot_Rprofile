import_env_settings <- function(folder_path) {
  env <- read.table(paste(folder_path, "/.envrc", sep = ""))
  library(sqldf)
  env2 <- sqldf("select V2 from env where V1 = 'export'")[[1]]
  for(line in env2) {
      r <- strsplit(line, split = '=')[[1]]
      args = list(r[2])
      names(args) = r[1]
      do.call(Sys.setenv, args)
    }
}
