% starbarchart(myp,hbar,varargin)
% This function finds the bars and print stars
% The p-value input should be in the order of bars from left to right
function starbarchart(myp,hbar,varargin)

if nargin <2
    hbar=findobj(gca,'Type','bar');
end

if isempty(varargin)
    height = 1.1;
else
    height = varargin{1};
end

myp =myp(:);
sz=size(myp)% print out to check if it is correct

xpos = hbar(1).XData;
Xpositions = xpos+hbar(end).XOffset;
Ypositions = hbar(end).YData;
numBarsPerGroup = length(hbar);
for i = 1:numBarsPerGroup-1
    Xpositions = vertcat(Xpositions,xpos+hbar(end-i).XOffset);
    Ypositions = vertcat(Ypositions,hbar(end-i).YData);
end

% xpos = hbar(1).XData;
% Xpositions = [xpos+hbar(2).XOffset;xpos+hbar(1).XOffset];
% Ypositions = [hbar(2).YData;hbar(1).YData];

Xpositions = Xpositions(:);
Ypositions = Ypositions(:);

for k =1:numel(Xpositions)
    starY=Ypositions(k)*height;
    p=myp(k);
    if p<=1E-3
        stars='***';
    elseif p<=1E-2
        stars='**';
    elseif p<=0.05
        stars='*';
    else
        %         stars='n.s.';
        %     else
        stars='';
    end
    text(Xpositions(k),starY,stars,...
        'HorizontalAlignment','Center',...
        'BackGroundColor','none',...
        'Tag','sigstar_stars');
end
end