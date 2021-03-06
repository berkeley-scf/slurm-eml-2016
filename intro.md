% EML SLURM training: the new EML SLURM-based cluster, Savio, and XSEDE resources
% October 7, 2016


# Introduction

We'll do this in part as a demonstration. I encourage you to login to one of the EML Linux machines and try out the various examples yourself as we go through them.

This material is based on:

 - [The EML high-priority cluster webpage](http://eml.berkeley.edu/52)
 - [The Savio user guide](http://research-it.berkeley.edu/services/high-performance-computing/user-guide)

The materials for this tutorial are available:

 - using git at [https://github.com/berkeley-scf/slurm-eml-2016](https://github.com/berkeley-scf/slurm-eml-2016) or 
 - simply as a [zip file](https://github.com/berkeley-scf/slurm-eml-2016/archive/master.zip).
 - example dataset for Python and R examples (*bayArea.csv*) available from [http://www.stat.berkeley.edu/share/paciorek/bayArea.csv](http://www.stat.berkeley.edu/share/paciorek/bayArea.csv).

# Outline

This training session will cover the following topics:

 - Overview of EML and campus resources
    - EML clusters (old and new)
    - Savio campus cluster
    - NSF XSEDE national infrastructure
 - Clusters and job scheduling
    - brief discussion of job competition and the scheduling problem
 - SLURM on the EML high-priority cluster
    - basic interactive and batch submission
    - submitting parallel jobs
    - Stata, Python, MATLAB, R templates for parallel code
 - Savio
    - Access models: Econ condo and faculty computing allowances
    - Basic usage of Savio
        - logging in
        - data transfer
        - accessing software
    - Disk space
 - XSEDE
 - How to get additional help


# Overview of EML and campus resources

 - EML clusters    
    - ['SGE' (old) cluster](http://eml.berkeley.edu/563): 256 cores across 8 nodes, 264 GB RAM / node
    - ['SLURM' (new) cluster](http://eml.berkeley.edu/52): 224 cores across 4 nodes, 132 GB RAM / node
    - Stata, Python, R, MATLAB, SAS
 - [Savio campus cluster](http://research-it.berkeley.edu/services/high-performance-computing)
    - ~6600 nodes across ~330 nodes, 64 GB RAM on most nodes but up to 512 GB RAM on high-memory nodes
    - 2 nodes (48 cores) owned by EML
    - Python, R, MATLAB, Spark, (SAS?)
 - [NSF XSEDE network](https://www.xsede.org) of supercomputers
    - Bridges supercomputer for big data computing, including Spark
    - many other clusters/supercomputers

**Big picture: if you don't have enough computing resources, don't give up and work on a smaller problem, talk to us.**

# Job competition and scheduling on the EML clusters

 - goals:
     - allow users to share the CPUs equitably
     - efficiently use the CPUs to maximum potential
     - allow large jobs to run
     - allow users to submit many jobs and have the scheduler manage them
 - jobs with various requirements
     - time length
     - number of cores
 - current scheduling policies
     - fairshare for queue
     - once running, only subject to time limits
     - backfilling and (on old cluster) resource reservations
 - time limits 
     - very helpful for the scheduler - please include with SLURM submissions

# SLURM (new) cluster

 - submission nodes: blundell durban frisch grace jorgenson laffont logit marshall radner sargan theil
 - compute nodes: eml-sm20, eml-sm21, eml-sm22, eml-sm23
 - 3 day time limit by default; 28 days if requested via `-t` flag
 - please try to give a rough time limit but be conservative
 - at most 28 cores per user at a time

# SLURM: basic batch job submission

Let's see how to submit a simple job. 

Here's an example job script (*job.sh*) that I'll run. 

```
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Wall clock limit (3 minutes here):
#SBATCH --time=00:03:00
#
## Command(s) to run:
python calc.py >& calc.out
```

By default this will request only one core for the job.

Now let's submit and monitor the job:

```
sbatch job.sh  # note JOB_ID is printed as output of this call

squeue -j JOB_ID

squeue -u ${USER}

# to see a bunch of useful information on all jobs
alias sq='squeue -o "%.7i %.9P %.20j %.8u %.2t %l %.9M %.5C %.8r %.6D %R %p %q"'
sq
```

We could also include the SLURM flags in the submission script. Here's the simplified script:

```
#!/bin/bash
python calc.py >& calc.out
```

and here is the job submission:

```
sbatch --job-name=test --time=00:03:00 job_short.sh
```


# SLURM: basic interactive job submission

To start an interactive session,

```
srun --pty /bin/bash
```

To use graphical interfaces, you need to do add an extra flag:

```
srun --pty --x11=first /bin/bash
matlab

# alternatively:
srun --pty --x11=first matlab
```

# SLURM: submitting parallel jobs overview

If you are submitting a job that uses multiple nodes, you'll need to carefully specify the resources you need. The key flags for use in your job script are:

 - `--cpus-per-task` (or `-c`): number of cpus to be used for each task
 - `--ntasks-per-node`: number of SLURM tasks (i.e., processes) one wants to run on each node
 - `--nodes` (or `-N`): number of nodes to use

In addition, in some cases it can make sense to use the `--ntasks` (or `-n`) option to indicate the total number of SLURM tasks and let the scheduler determine how many nodes and tasks per node are needed. 

Note that the --nodes flag is of somewhat limited use given we've limited users to at most 28 cores in use at once, but it is possible to request cores across multiple nodes.

Here's an example job script (see also *job-parallel.sh*) for a job that does calculations in parallel in Stata:

```
#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Number of MPI tasks needed for use case:
#SBATCH --ntasks=1
#
# Processors per task:
#SBATCH --cpus-per-task=8
#
# Wall clock limit:
#SBATCH --time=00:00:30
#
## Command(s) to run:
stata-mp -b do code.do 
```

# SLURM: submitting parallel jobs on the EML

On the EML, each user can only use 28 cores at a time and we only have four nodes, so one would generally only use the SLURM parallelization flags in a limited way.

Some common paradigms are:

 - `--nodes=1 --ntasks-per-node=1 --cpus-per-task=c` 
 - `--nodes=1 --ntasks-per-node=c --cpus-per-task=1` 

For many problems specifying the number of cores via `--cpus-per-task` or via `--ntasks-per-node` will equivalent. 

In general, the defaults for the various flags will be 1 so some of the flags above are not strictly needed.

If you use MATLAB DCS, iPython parallel, or parallelized R in certain ways, it's possible to run a job across cores on multiple nodes, which would require changing the flags to use:

 - `--ntasks=n --cpus-per-task=1`

# SLURM: submitting parallel jobs on Savio

On Savio one makes use of more functionality in terms of requesting resource for parallel jobs.

Here are some common paradigms on Savio:

 - multi-core or multi-process jobs on one node
     - `--nodes=1 --ntasks-per-node=1 --cpus-per-task=c` 
     - `--nodes=1 --ntasks-per-node=n --cpus-per-task=1` 
 - MPI jobs that use *one* CPU per task for each of *n* SLURM tasks
     - `--ntasks=n --cpus-per-task=1` 
     - `--nodes=x --ntasks-per-node=y --cpus-per-task=1` 
        - assumes that `n = x*y`
 - hybrid parallelization jobs (e.g., MPI+threading) that use *c* CPUs for each of *n* SLURM tasks
     - `--ntasks=n --cpus-per-task=c`
     - `--nodes=x --ntasks-per-node=y cpus-per-task=c` 
        - assumes that `y*c` equals the number of cores on a node and that `n = x*y` equals the total number of tasks

In general, the defaults for the various flags will be 1 so some of the flags above are not strictly needed.

For Savio, there are lots more examples of job submission scripts for different kinds of parallelization (multi-node (MPI), multi-core (openMP), hybrid, etc.) [here](http://research-it.berkeley.edu/services/high-performance-computing/running-your-jobs#Job-submission-with-specific-resource-requirements). 


# SLURM environment variables

When you write your code, you may need to specify information in your code about the number of cores to use. SLURM will provide a variety of variables that you can use in your code so that it adapts to the resources you have requested rather than being hard-coded. 

Here are some of the variables that may be useful: SLURM_NTASKS, SLURM_CPUS_PER_TASK, SLURM_NODELIST, SLURM_NNODES.

If you specified:

 - --cpus-per-task: use SLURM_CPUS_PER_TASK
 - --ntasks-per-node or --ntasks: use SLURM_NTASKS

Here's how you can access those variables in your code:

```
import os                                             ## Python
int(os.environ['SLURM_CPUS_PER_TASK'])                ## Python

as.numeric(Sys.getenv('SLURM_CPUS_PER_TASK'))         ## R

str2num(getenv('SLURM_CPUS_PER_TASK')))               ## MATLAB

local SLURM_CPUS_PER_TASK : env SLURM_CPUS_PER_TASK   ## Stata
```

We'll see in the next examples how one would then use such environment variables to programmatically control the parallelization in your code so that you don't need to hard-code the number of processes/threads/cores/etc.

In our examples, we will use --cpus-per-task. We could also use --ntasks with --nodes=1, but if we leave out the --nodes=1, then SLURM might put our tasks on multiple nodes and the parallel tools in these examples don't work across multiple nodes.

# SLURM templates: parallel Stata

The file *example-stata.sh* is an example job submission script for a parallel Stata job.

```
#!/bin/bash
# Job name:
#SBATCH --job-name=stata-test
#
# Wall clock limit (3 minutes here):
#SBATCH --time=00:03:00
#
#SBATCH --cpus-per-task=8
## Command(s) to run:
stata-mp -b do code.do 
```

By default Stata-MP will use 8 cores, so if you request 2-7 cores, please include the following at the top of your .do file:

```
local SLURM_CPUS_PER_TASK : env SLURM_CPUS_PER_TASK          
set processors `SLURM_CPUS_PER_TASK'
```

# SLURM templates: parallel Python

Here's an example of parallelizing Python code using iPython's parallel capability.
The file *example-python.sh* is an example job submission script for a parallel iPython job run in *parallel.py* (it just does a toy example stratified regression analysis of some airline departure data).

```
#!/bin/bash
# Job name:
#SBATCH --job-name=python-test
#
# Wall clock limit (30 minutes here):
#SBATCH --time=00:30:00
#
#SBATCH --cpus-per-task=8
#
## Command(s) to run:
# to be safe that we get the Python version we want
# in general I try to use python 3 but having some difficulty
# reading my data file with python 3
module unload python
module load python/3
ipcluster start -n $SLURM_CPUS_PER_TASK &
sleep 15
ipython < parallel.py
ipcluster stop
```

Now here's the Python code (see *parallel.py*) we're running:

```
from ipyparallel import Client
c = Client()
c.ids

dview = c[:]
dview.block = True
dview.apply(lambda : "Hello, World")

lview = c.load_balanced_view()
lview.block = True

import pandas
dat = pandas.read_csv('~/bayArea.csv', header = None, encoding='ISO-8859-1')
dat.columns = ('Year','Month','DayofMonth','DayOfWeek','DepTime','CRSDepTime','ArrTime','CRSArrTime','UniqueCarrier','FlightNum','TailNum','ActualElapsedTime','CRSElapsedTime','AirTime','ArrDelay','DepDelay','Origin','Dest','Distance','TaxiIn','TaxiOut','Cancelled','CancellationCode','Diverted','CarrierDelay','WeatherDelay','NASDelay','SecurityDelay','LateAircraftDelay')

dview.execute('import statsmodels.api as sm')

dat2 = dat.loc[:, ('DepDelay','Year','Dest','Origin')]
dests = dat2.Dest.unique()

mydict = dict(dat2 = dat2, dests = dests)
dview.push(mydict)

def f(id):
    sub = dat2.loc[dat2.Dest == dests[id],:]
    sub = sm.add_constant(sub)
    model = sm.OLS(sub.DepDelay, sub.loc[:,('const','Year')])
    results = model.fit()
    return results.params

import time
time.time()
parallel_result = lview.map(f, range(len(dests)))
#result = map(f, range(len(dests)))
time.time()

# some NaN values because all 'Year' values are the same for some destinations

parallel_result
```

# SLURM templates: MATLAB

### MATLAB with one core.  

See *example-matlab-onecore.sh*.

### MATLAB with threading

The file *example-matlab-parallel.sh* is an example job submission script for a parallel MATLAB job using threading or parfor.

The key thing when using threading in MATLAB (which is used by default) is to set the number of threads in your MATLAB code file so that your job uses no more cores than you've requested. Here's how (as also seen in *parallel-threaded.m*):

```
feature(’numThreads’, str2num(getenv('SLURM_CPUS_PER_TASK')));
```

### MATLAB with parfor

Here's an example of parallelizing MATLAB code. 

The file *example-matlab-parallel.sh* is (also) an example job submission script for a parallel MATLAB job using parfor.

The file *parallel-parfor.m* shows how to use parfor such that your code automatically detects how many cores it should use.

# SLURM templates: parallel R 

The file `example-R.sh` is an example job submission script for a parallel R job run in parallel.R (it just does a toy example stratified regression analysis of some airline departure data).

```
#!/bin/bash
# Job name:
#SBATCH --job-name=R-test
#
# Wall clock limit (30 minutes here):
#SBATCH --time=00:30:00
#
#SBATCH --cpus-per-task=8
#
## Command(s) to run:
R CMD BATCH --no-save parallel.R parallel.Rout
```

Now here's the R code (see *parallel.R*) we're running:
```
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
```

# Savio: access models

 - Direct access
    - EML has purchased two nodes (48 cores) and you can [request a Savio account](http://goo.gl/forms/Sqt8kBG4P5) as an individual EML user
 - Access through a faculty member
    - All regular Berkeley faculty can request 200,000 service units (roughly core-hours) per year through the [Faculty Computing Allowance (FCA)](http://research-it.berkeley.edu/services/high-performance-computing/faculty-computing-allowance)
    - Faculty/researchers can also purchase nodes for their own priority access and gain access to the shared Savio infrastructure and to the ability to *burst* to additional nodes through the [condo cluster program](http://research-it.berkeley.edu/services/high-performance-computing/condo-cluster-program)

Faculty/principal investigators can allow researchers working with them to get user accounts with access to the FCA or condo resources available to the faculty member.

As a member of the EML condo, you have access to 

  - savio2 nodes at regular priority and 
  - GPU, large memory, and other kinds of nodes at low priority (jobs can be killed without notice). 

Using a faculty compute allowance, you have access to all kinds of nodes at regular priority.

# Savio: logging in and submitting jobs

Savio requires two-factor authentication and installation of the Google authenticator application on your smartphone or tablet as described in detail [here](http://research-it.berkeley.edu/services/high-performance-computing/logging-savio).

When entering your password, remember to enter:  `AAAAAABBBBBB`, where AAAAAA is your Google Authenticator PIN and BBBBBB is the one-time password.

You can submit jobs using SLURM similarly to the EML SLURM cluster.

You should put any data files that will be input or output for your jobs in `/global/scratch/${USER}`.

To copy files to and from Savio, you need to do this from a data transfer node
```
ssh dtn
scp smith@theil.berkeley.edu:~/foo .
```

or use Globus (EML and Savio both have Globus endpoints).

# Data transfer: Globus

You can use Globus Connect to transfer data data to/from Savio (and between other resources) quickly and unattended. This is a better choice for large transfers. Here are some [instructions](http://research-it.berkeley.edu/services/high-performance-computing/using-globus-connect-savio).

Globus transfers data between *endpoints*. Possible endpoints include: Savio, your laptop or desktop, EML, and XSEDE, among others.

Savio's endpoint is named `ucb#brc` and EML's is `ucb#econ`.

If you are transferring to/from your laptop, you'll need 1) Globus Connect Personal set up, 2) your machine established as an endpoint and 3) Globus Connect Personal actively running on your machine. At that point you can proceed as below.

To transfer files, you open Globus at [globus.org](https://globus.org) and authenticate to the endpoints you want to transfer between. You can then start a transfer and it will proceed in the background, including restarting if interrupted. 

Globus also provides a [command line interface](https://docs.globus.org/cli/using-the-cli) that will allow you to do transfers programmatically, such that a transfer could be embedded in a workflow script.


# Savio: accessing software

A lot of software is available on Savio but needs to be loaded from the relevant software module before you can use it.

```
module list  # what's loaded in your session?
module avail  # what's available on the system?
```

One thing that tricks people is that the modules are arranged in a hierarchical (nested) fashion, so you only see some of the modules as being available *after* you load the parent module. Here's how we see the Python packages that are available.

```
which python
python

module avail
module load python/2.7.8
which python
module avail
module load numpy
python 
# import numpy as np
```


# Savio: Disk space

You have access to the following disk space, described [here in the *Storage and Backup* section](http://research-it.berkeley.edu/services/high-performance-computing/user-guide#Storage).

 - somewhat limited home directory storage (10 GB)
 - 1 PB scratch space ('unlimited' use but not backed up or permanent)
 - new condo storage offering: $14000 for 40 TB

Also, we have a copy of the Nielsen data on Savio so you don't need to make your own copy/download. 

# XSEDE resources

 - NSF network of supercomputing centers/resources
 - new resources in XSEDE2 currently under-utilized
 - PSC Bridges set up for big data, including Spark and very large memory nodes
 - access:
    - can get initial access via brc@berkeley.edu       
    - follow up with a start-up allocation (one-page, always approved)
    - finally, research grants possible (several page process)


# Online resources

 - EML SLURM cluster page: 
     - [http://eml.berkeley.edu/52](http://eml.berkeley.edu/52)
 - EML SGE (old) cluster page: 
     - [http://eml.berkeley.edu/563](http://eml.berkeley.edu/563)
 - SCF tutorials on computing topics including single-node and multiple-node parallelization:
     - [http://statistics.berkeley.edu/computing/tutorials](http://statistics.berkeley.edu/computing/training/tutorials)
  - Savio documentation: 
     - [http://research-it.berkeley.edu/services/high-performance-computing](http://research-it.berkeley.edu/services/high-performance-computing)

# How to get additional help

 - For EML resources 
    - consult@econ.berkeley.edu or trouble@econ.berkeley.edu
 - For initial Savio, XSEDE, and cloud computing questions:
    - consult@econ.berkeley.edu
 - For technical issues and questions about using Savio: 
    - brc-hpc-help@berkeley.edu
 - For questions about computing resources in general, including cloud computing: 
    - brc@berkeley.edu
 - For questions about data management (including HIPAA-protected data): 
    - researchdata@berkeley.edu

