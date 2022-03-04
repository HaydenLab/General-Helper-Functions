% affinity propagation clustering code copied from Frey 2007 Sci
% takes an input similarity, where similarity is measured by -Euclidean
% distance s(i, k)= -abs(xi-xk)^2
% s(k,k) = preference = median(s(i,k)), if preference is set to be too
% small, it encourages more clusters
function [E,idx,K] = affinity_propagation_clustering(S)
N=size(S,1);
A=zeros(N,N);
R=zeros(N,N); % Initialize messages
S=S+1e-12*randn(N,N)*(max(S(:))-min(S(:))); % Remove degeneracies
lam=0.5; % Set damping factor 0.5-1 (larger damping factor slows down the algorithm, but prevents oscillations)
maxIter = 100;
for iter=1:maxIter
    % Compute responsibilities
    Rold=R;
    AS=A+S;
    [Y,I]=max(AS,[],2);
    for i=1:N
        AS(i,I(i))=-realmax;
    end
    [Y2,I2]=max(AS,[],2);
    R=S-repmat(Y,[1,N]);
    for i=1:N
        R(i,I(i))=S(i,I(i))-Y2(i);
    end
    R=(1-lam)*R+lam*Rold; % Dampen responsibilities
    % Compute availabilities
    Aold=A;
    Rp=max(R,0);
    for k=1:N
        Rp(k,k)=R(k,k);
    end
    A=repmat(sum(Rp,1),[N,1])-Rp;
    dA=diag(A); A=min(A,0);
    for k=1:N
        A(k,k)=dA(k);
    end
    A=(1-lam)*A+lam*Aold; % Dampen availabilities
end
E=R+A; % Pseudomarginals
I=find(diag(E)>0);
K=length(I); % Indices of exemplars
[tmp c]=max(S(:,I),[],2);
c(I)=1:K;
idx=I(c); % Assignments
end