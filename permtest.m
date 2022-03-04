% [h,p,mstat]=permtest(A,B,alpha,tail,nboot,...)
% mstat is the difference in bootstrapped mean of the two samples
% A and B are matrices/vectors
% They can be real samples, but they can also be a vector of test statistics
% calculated with bootstrap test, e.g.
% A = bootstrp(nboot,@mean,X1);
% B = bootstrp(nboot,@mean,X2);

% test whether the two samples have significantly different mean without
% assuming normal distribution of sample nor affected by the number of bootstraps taken, which is a pre-requirement for
% t-test
% unpaired two-sample

% permtest Version 1.0
% Created Jan 17, 2018 by Jiaxin Tu

function [h,p,mstat]=permtest(A,B,varargin)
%% Obtain options
[~, ~, args] = parseplotapi(varargin{:});

if nargin<2 
    warning('Need two groups to compare!')
    return
elseif nargin<5
    args=cell(5,1);
end

if isempty(args{1})
    alpha =0.05; %default
else
    alpha = args{1};
end

if isempty(args{2})
    tail = 'both'; %default
else
    tail = args{2};
end

if isempty(args{3})
    nboot = 10000; %default
else
    nboot =args{3};
end
%% True Start
% reshape A,B into vector form
A = reshape(A,[],1);
B = reshape(B,[],1);

% get length of two variables
lA = length(A);
lB = length(B);

% throw in a bag
C = vertcat(A,B);
lC = length(C);

D = [true(lA,1);false(lB,1)];

% resampling
mstat = NaN(nboot,1);
for i=1:nboot
%     if ~mod(i,100) %display i every 100 permutation
%         i
%     end
    rng(i,'twister') % for reproducibility
    tmp = D(randperm(lC));
    mstat(i)= mean(C(tmp))-mean(C(~tmp));
end

meandiff = mean(A)-mean(B);
plow = sum(mstat<meandiff)/nboot;
phigh = sum(mstat>meandiff)/nboot;

if strcmp(tail,'both')
    if meandiff>median(mstat)
        p = phigh;
    else
        p = plow;
    end
    h = p<alpha/2;
elseif strcmp(tail,'left')
    p = plow;
    h= p<alpha;
elseif strcmp(tail,'right')
    p = phigh;
    h= p<alpha;
else
    warning('Invalid tail specification');
    return
end

% params=mle(mstat);
% 
% 
% if strcmp(tail,'both')
%     if normcdf(mean(A)-mean(B),params(1),params(2))> 0.5
%         p = 1-normcdf(mean(A)-mean(B),params(1),params(2));
%     else
%         p = normcdf(mean(A)-mean(B),params(1),params(2));       
%     end
%     h = p < alpha/2;
% elseif strcmp(tail,'left')
%     p = normcdf(mean(A)-mean(B),params(1),params(2));
%     h = p < alpha;
% elseif strcmp(tail,'right')
%     p = 1-normcdf(mean(A)-mean(B),params(1),params(2)); 
%     h = p < alpha;
% else
%     warning('tail input should be ''left/right/both');
%     return
% end

end