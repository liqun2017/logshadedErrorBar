% modify by LI Qun 2017
% Aim: power specturm with shadow errorbar in logarithmic scale 
% only show the upper error

function varargout = logshadedErrorBar_150(x,y,errBar,varargin)
% generate continuous error bar area around a line plot
%
% function H=shadedErrorBar(x,y,errBar, ...)
%
% Purpose 
% Makes a 2-d line plot with a pretty shaded error bar made
% using patch. Error bar color is chosen automatically.
%
%
% Inputs (required)
% x - vector of x values [optional, can be left empty]
% y - vector of y values or a matrix of n observations by m cases
%     where m has length(x);
% errBar - if a vector we draw symmetric errorbars. If it has a size
%          of [2,length(x)] then we draw asymmetric error bars with
%          row 1 being the upper bar and row 2 being the lower bar
%          (with respect to y). ** alternatively ** errBar can be a
%          cellArray of two function handles. The first defines which
%          statistic the line should be and the second defines the
%          error bar.
%
% Inputs (optional, param/value pairs)
% 'lineProps' - ['-k' by default] defines the properties of
%             the data line. e.g.:    
%             'or-', or {'-or','markerfacecolor',[1,0.2,0.2]}
% 'transparent' - [true  by default] if true, the shaded error
%               bar is made transparent. However, for a transparent
%               vector image you will need to save as PDF, not EPS,
%               and set the figure renderer to "painters". An EPS 
%               will only be transparent if you set the renderer 
%               to OpenGL, however this makes a raster image.
%
%
% Outputs
% H - a structure of handles to the generated plot objects.
%
%
% Examples:
% y=randn(30,80); 
% x=1:size(y,2); 
% logshadedErrorBar(x,mean(y,1),std(y),'lineprops','g');

% Rob Campbell - November 2009

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse input arguments
narginchk(3,inf)

params = inputParser;
params.CaseSensitive = false;
params.addParameter('lineProps', '-k', @(x) ischar(x) | iscell(x));
params.addParameter('transparent', true, @(x) islogical (x) || x==0 || x==1);

params.parse(varargin{:});

%Extract values from the inputParser
lineProps =  params.Results.lineProps;
transparent =  params.Results.transparent;

if ~iscell(lineProps), lineProps={lineProps}; end

%% data prepare for patch object in logarithmic scale(modify by Qun)
% delete outliner in high frequency>100 Hz

[~,startf3] = min(abs(x-100));%find 100 Hz
A = log10(errBar);
B = prctile(A(startf3:end),85);
C = find(A(startf3:end)>B);
C = C+startf3-1;
x(C)=[];
y(C)=[];
errBar(C)=[];

% delete log10(x)<0
if log10(x(1))<0
    A=find(log10(x)<0);
    x(A)=[];
    y(A)=[];
    errBar(A)=[];
end
clear A B C startf1 startf2

%%
%Make upper and lower error bars if only one was specified
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot to get the parameters of the line
H.mainLine = loglog(x,y,lineProps{:});%modify



% Work out the color of the shaded region and associated lines.
% Here we have the option of choosing alpha or a de-saturated
% solid colour for the patch surface.

col=get(H.mainLine,'color');
%edgeColor=col+(1-col)*0.55;
patchSaturation=0.15; % How de-saturated or transparent to make patch
if transparent
    faceAlpha=0.5;
    patchColor=col+(1-col)*(1-patchSaturation);
else
    faceAlpha=patchSaturation;
    patchColor=col;
    
end

%Calculate the error bars
uE=y+errBar(1,:);
%lE=y-errBar(2,:);%modify

%%
%Add the patch error bar
holdStatus=ishold;
if ~holdStatus, hold on,  end

%Make the patch
yP=[y,fliplr(uE)];% only upper
xP=[x,fliplr(x)];

%remove nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];

%%
H.patch=patch(xP,yP,1,'facecolor',patchColor, ...
              'edgecolor','none', ...
              'facealpha',faceAlpha);

%%
%Make pretty edges around the patch. 
%H.edge(1)=plot(x,lE,'-','color',edgeColor);
%H.edge(2)=plot(x,uE,'-','color',edgeColor);

%Now replace the line (this avoids having to bugger about with z coordinates)
uistack(H.mainLine,'top')

if ~holdStatus, hold off, end

if nargout==1
    varargout{1}=H;
end
