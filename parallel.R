library(doParallel)

nCores <- as.numeric(Sys.getenv('SLURM_CPUS_PER_TASK'))
registerDoParallel(nCores)

dat <- read.csv('~/bayArea.csv', header = FALSE,
                stringsAsFactors = FALSE)
names(dat)[16:18] <- c('delay', 'origin', 'dest')
table(dat$dest)

destVals <- unique(dat$dest)

results <- foreach(destVal = destVals) %dopar% {
    sub <- subset(dat, dest == destVal)
    summary(sub$delay)
}

results
