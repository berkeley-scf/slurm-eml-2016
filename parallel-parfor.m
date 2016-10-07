nslots = str2num(getenv('SLURM_CPUS_PER_TASK')));
mypool = parpool(nslots) 
% parpool open local nslots # alternative

n = 3000;
nIts = 500;
c = zeros(n, nIts);
parfor i = 1:nIts
     c(:,i) = eig(rand(n)); 
end

delete(mypool)
