function [speeds] = hm_waveSpeedBeats(file, fileW, flaFile, segmentWidth, cutlr, ...
    fstIdx, lstIdx, windowWidth, seconds)
    %% A wrapper to apply wavespeed calculation to all detected systoles.
	% This is rich in input args, but they are mostly to toy around (see parameter figure)
	% The defaults at (***) seem to work reasonably well.
    %   Input:
    %       file			Input file 
	%		fileW, 			Input file (old data format)
	%		flaFile			Data file, stores data from interval detection
	%		segmentWidth	Segment width to look at
	%		cutlr			Crop left/right
    % 		fstIdx			segmentWidth leaves you with n segments. This is "the first/left one"
	%						e.g. width=600, segWidth=100 leaves you with 6 segments.
	%						You can now compare eg. no. 2 and 5 (to leave out the boarders)
	% 		lstIdx			see above, second segment
	%		windowWidth		Width around systole, see comment at (****)
	%		seconds			Amount of seconds to work on
    %   Output:
    %       speeds			Wave speeds for all 

% microns/pixel for 10x magnification 1x1 bin
% for our camera type
% 435 microns / 600 pixels

% Note: Our videos run at 200 fps, hence the 200 magic numbers.

speeds = [ ];

% Get video length and calculate framesets to do
% flaFile = 'G:\Metadata\vin453\vin453_151-300.fla';
load(flaFile,'-mat');

% (***) some default parameters for lazy calling
if(nargin<5)
   cutlr = 0; 
   fstIdx = 2;
   lstIdx = 5;
   windowWidth = 50;
   seconds = -1;
end

% Is there actually data?
% If there is nothing, things may crash
if (length(diastoleEndIdx) < 5)
   return; 
end

%extend the shift-window by this amount of pixels to the left/right. E.g.: (****)
% [--wndWdh--|DiastoleEnd|--Systole--|DiastoleStart|--wndWdh--] 

% Just in case you want to crop the video
videoWidth = 600 - 2*cutlr;

% hm_waveGetMovement is just a wrapper for getting the movement curves while
% while cropping and being consistent to some legacy format.
% Movement is this from "hm_doOpticalFlow": flowResults{4} = xm;
% The others are rather self-explanatory
[msize, movement, videoWidth] = hm_waveGetMovement(file, fileW, cutlr);

% -2 to cut the outer parts. The border cases are generally troublesome 
% (eg. we see half a heartbeat in the beginning of the video) and hence cropped away.
% There is plentyful data in between.
len = (videoWidth / segmentWidth - 1) - 2;
if seconds>0
    movement = movement(1:seconds*200,:);
    tmp = find(diastoleEndIdx>seconds*200);
    diastoleEndIdx = diastoleEndIdx(1:tmp-1);
    tmp = find(diastoleBeginIdx>seconds*200);
    diastoleBeginIdx = diastoleBeginIdx(1:tmp-1);
end

%Calculate where to start and where to stop.
start = 1;
send = length(diastoleEndIdx)-1;
while diastoleEndIdx(start)-windowWidth < 1
   start = start + 1; 
end
while diastoleBeginIdx(send+1)+windowWidth > msize-1
   send = send - 1; 
end

% loop over all detected systoles
for i=start:send
    sidx = diastoleEndIdx(i) - windowWidth;
    len = diastoleBeginIdx(i+1) - diastoleEndIdx(i) + 2 * windowWidth;
    
	% This is abviously faulty - a heartbeat should not last > second
	% Do with these events whatever you want - log them, ignore them, even accept them
    if(seconds>0 && sidx+len>seconds*200)
       continue 
    end
	
	% This grabs the actual speed for the defined segment for current systole.
    [~, shifts] = hm_waveSpeedbyShiftBeats(movement, segmentWidth, ...
        sidx, len, fstIdx, lstIdx);
		
	% for each speed, log the center of the systole as the event timepoint
    fidx = (sidx+len/2);
    a = [shifts ; fidx];
    speeds = [speeds a];
end


