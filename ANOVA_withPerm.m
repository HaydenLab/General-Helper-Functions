% http://influentialpoints.com/Training/anova_by_randomization.htm
% simulation of ANOVA with randomization
function p = ANOVA_withPerm(A,grp,whichperm,M)
assert(size(A,1)== size(grp,1));
assert(size(A,2)==1);

if isempty(M)||~exist('M','var')
    M = zeros(size(grp,2));
end

%% Real
[~,T] = anovan(A,grp,'nested',M,'display','off');
F = cell2mat(T(2:1+size(grp,2),6))';
%% Permutation
rng('default');

shuffle = @(v)v(randperm(length(v)));
keep_same = setdiff([1:size(grp,2)],whichperm);
allcond = table2array(unique(table(grp(:,keep_same))));


F_dist = NaN(5000,size(grp,2));
for i = 1:5000
    thisgrp = grp;
    for jj = 1:size(allcond,1)
        cond = grp(:,keep_same) == allcond(jj,:);
        idx = find(all(cond,2));
        thisgrp(idx,whichperm) = shuffle(grp(idx,whichperm));
    end
    [~,T] = anovan(A,thisgrp,'nested',M,'display','off');
    F_dist(i,:) = cell2mat(T(2:1+size(grp,2),6));
end
% for i = 1:5000
%     keep_same = setdiff([1:size(grp,2)],whichperm);
%     values = arrayfun(@(i)unique(grp(:,i)),keep_same,'UniformOutput',false); 
%     len = arrayfun(@(i)length(unique(grp(:,i))),keep_same); 
%     % permute one but conserve the others
%     thisgrp = grp;
%     for jj = 1:prod(len)
%         cond = true(size(grp));
%         for k = 1:length(keep_same)
%             cond(:,k) = grp(:,keep_same(k))== values{k}(mod(jj,len(k))+1);
%         end
%         idx = find(all(cond,2));
%         thisgrp(idx,whichperm) = shuffle(grp(idx,whichperm));
%     end
%     [~,T] = anovan(A,thisgrp,'nested',M,'display','off');
%     F_dist(i,:) = cell2mat(T(2:1+size(grp,2),6));
% end
%% Plot and output p
% for i = 1:size(grp,2)
%     figure;
%     histogram(F_dist(:,i));
%     vline(F(i));
%     title(sprintf('Var %i',i));
% end

p = mean(F_dist>F);
end