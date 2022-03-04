% Two sample T-test with permutation, shuffling one but conserving the others
% test_group has to be only 1 and 0 s
function p = ttest2_withPerm(X,test_group,other_group)
assert(size(X,2)==1);
assert(size(X,1)==size(test_group,1));
assert(size(X,1)==size(other_group,1));
%% Real
[~,~,~,stats] = ttest2(X(test_group==1),X(test_group==0));
T = stats.tstat;
 %% Permutation
rng('default');

shuffle = @(v)v(randperm(length(v)));
allcond = table2array(unique(table(other_group)));

% permute one but conserve the others
thisgrp = test_group;
T_dist = NaN(5000,1);
for i = 1:5000
    for jj = 1:size(allcond,1)
        cond = other_group == allcond(jj,:);
        idx = find(all(cond,2));
        thisgrp(idx) = shuffle(test_group(idx));
    end
    [~,~,~,stats] = ttest2(X(thisgrp==1),X(thisgrp==0));
    T_dist(i) = stats.tstat;
end

%% Plot and output p
% figure;
% histogram(T_dist);
% vline(T(i));
% title(sprintf('Var %i',i));
if any(isnan(T_dist))
    p = NaN;
else
    p = [mean(T_dist>T),mean(T_dist<T)]; % p greater than /smaller than (two-sided)
end
end