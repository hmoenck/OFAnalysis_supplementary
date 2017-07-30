function [allsum, shifts] = hm_waveSpeedbyShiftBeats(movement, ...
    segmentWidth, from, count, left, right)
    %% Calculates the wave speed
    %   Input:
    %       movement		Movement data 
	%		segmentWidth	Segment width to look at
	%		from			defines start of current movement
	%		count			len for from
	%		left			Min to scroll to
	%		right			Max to scroll to
    %   Output:
    %       allsum			Vector of individual SSD's
	%		shifts			Calculated shifts

len = count; %eg. 500;
start = from; %eg. 200;

w = size(movement,2);
w = w/segmentWidth;
right = w-1;

% Set up for stream
xm = zeros(len,w);

% Grab "where" the segments are and their width
for i=1:w
     current =  movement(start:start+len-1,(i-1)*segmentWidth+1:i*segmentWidth);
     xm(:,i) = sum(current,2);
end

allsum = zeros(1,20);

% Take one curve at fixed position while moving the other "from left to right"
% These five lines are the core of the wave speed calculation
for i=1:20
         I = (xm(10:end-10,right) - xm(i:end-20+i,left));
         ssd = sum(I(:).^2);
         allsum(i) = sum(ssd);
end

% Find the min of the SSD's. Then take into account the shift. 
% (we start from 0 to 20, where 10 is actually no shift)
shifts = find(allsum(2:end) == min(allsum(2:end))) + 1 - 10;

% There might be two with the same sum. What to do? Just take the first.
% Ideally they are next to each other and the error is hence below error boundaries 
% (given by temporal resolution). There might be cases, where the calculation is off-limits.
shifts = shifts(1); 



 