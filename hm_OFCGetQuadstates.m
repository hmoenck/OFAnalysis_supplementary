function [xm, xaAll, confAll] = hm_OFCGetQuadstates( ...
    Cell, movement, tresh, angleBin)
    %% Gets intervals from optical flow
    % Input:
    % 	Cell				= OF data
    % 	movement			= movement derived from optical flow
    % 	tresh				= threshold passed to other functions, e.g. 0.012
    % 	confidenceTresh		= Confidence threshold for deciding on the direction
    % 	angleBin			= Angle for deciding whether up or down (eg. is 180 the decision bound or...?)
	% Output:
	%	xm					= Filtered version of the input movement
	%	xaAll				= Quadstates merged from top and bottom
	%	confAll				= Union of confidence levels (unused)

confidenceTresh = 0.6;
xm = movement;

% Make sure these will always be defined and never empty
xaTop = 1:size(Cell,1);
xaBot = 1:size(Cell,1);
confTop = 1:size(Cell,1);
confBot = 1:size(Cell,1);

nFramesStart = 1;
nFrames = nFramesStart;

% some filtering and vertical alignment (removes base noise level)
xm(isnan(xm)) = 0;
xm = xm-min(medfilt1(xm));
xm(xm<0) = 0;

% Grab the quadstates
while (nFrames<size(Cell,1))
    [xaTop(nFrames), confTop(nFrames)] = hm_angleToQuadstate( ...
        xm(nFrames),tresh,Cell{nFrames,1},confidenceTresh, angleBin);
    [xaBot(nFrames), confBot(nFrames)] = hm_angleToQuadstate( ...
        xm(nFrames),tresh,Cell{nFrames,2},confidenceTresh, angleBin*-1);
    nFrames = nFrames + 1;
end

confAll = (confTop + confBot) ./ 2.0;
confAll(confTop<0) = -1;

% Filter the quadstates
[xaTop, xaBot, xaAll] = hm_filterQuadstate(xaTop, xaBot);

