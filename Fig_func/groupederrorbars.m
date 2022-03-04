%grouped error bars
function hBar = groupederrorbars(varargin)
% groupederrorbars(y,error)
%or groupederrorbars(y,neg,pos)

[~, ~, args] = parseplotapi(varargin{:});

if numel(args)>3
    warning('Too many inputs');
    return
end

if size(args{2})~=size(args{1})
    warning('The size of error must match the size of the data');
    return
end

% Grab the first delta inputs.
neg = args{2}';

% Grab the second delta inputs.
if numel(args) == 3
    % errorbar(x,y,neg,pos,...)
    pos = args{3}';
else
    % errorbar(y,e) or
    % errorbar(x,y,e)
    pos = neg;
end

y=args{1};

hBar = bar(y,0.5,'grouped');
if min(size(y))~=1
    for k1 = 1: size(y,2)
        ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
        ydt(k1,:) = hBar(k1).YData;
    end
else
    ctr = hBar.XData;
    ydt= hBar.YData;
end
hold on

e=errorbar(ctr(:),ydt(:),neg(:),pos(:),'.k','CapSize',0);

hold off
if numel(args)==3
    legend(e,'95% confidence interval from bootstrap test','location','southoutside','orientation','horizontal')
else
    legend(e,'Standard Error of the Mean','location','southoutside','orientation','horizontal');
end
end
