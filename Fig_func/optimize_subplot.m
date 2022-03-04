function [i,j] = optimize_subplot(nsubplot)
assert(numel(nsubplot)== 1& nsubplot>0 & mod(nsubplot,1)==0) % check that it is only one number, greater than 0 and is an integer
N = ceil(sqrt(nsubplot));
M = [1:N].*[1:N]';
sorted = unique(M)';
noptimal = sorted(find(sorted>=nsubplot,1));
idx = find(M==noptimal);
[i,j] = ind2sub([N,N],idx);

length_diff = abs(i-j);
[~,imin] = min(length_diff);
i = i(imin);
j = j(imin);

end