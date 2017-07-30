function [total, totalMov, st, sm, stm, smm, graphs] = angularMovement(f1,f2,total)
	%% Gets average plot for a single entity.
	% To do so the intervals etc are required via file
    %   Input:
    %       f1			A file containing flowResults data
	%		f2			A file containing diastole limits (end/begin)
	%		total 		Direction data as returned by "directions.m"
    %   Output:
    %       total		Circular means
	%		totalMov	Movement means
	%		st			Circular SD
	%		sm			Circular SM
	%		stm			Movement SD
	%		smm			Movement SM
	%		graphs 		Graphs for each individual heartbeat

%Load previous data
load(f1,'-mat');
load(f2,'-mat');

%% You might want to limit the data you are analyzing.
% The start and end of a heartbeat might be dominated by noise at times.
% Rather cut some few frames and interpolate them, if you really need.
cutoff = 0;
% This might be helpful, eg. to just look at the first minute.
upTo = 10000;

dirs = flowResults{1};

% Movement plot, just for reference:
mov = flowResults{2};
% Legacy sins...
all = total;
clear total;
endIdx = length(diastoleBeginIdx(diastoleBeginIdx < upTo));
section = diastoleEndIdx(1):diastoleBeginIdx(2);

graphs = cell(endIdx,2);
mat = ones(endIdx-1,100)*-1;
matm = ones(endIdx-1,100)*-1;

%% First values
%Angle and dir
vals = all(section);
valsMov = mov(section);
%first entry in avg vectors
total = vals;
totalMov = valsMov;

%Cheap error handling
if (length(vals)<6)
    total = -1;
    return;
end

%shortcut, cut of the first and last to remove noise
vtmp = vals(cutoff:end-cutoff);
vmtmp = valsMov(cutoff:end-cutoff);

%save individual graphs
graphs{1,1} = vtmp;
graphs{1,2} = vmtmp;

%interpolate first datapoint
vtmp100 = interp1(1:length(vtmp), vtmp, linspace(1,length(vtmp),100));
vmtmp100 = interp1(1:length(vmtmp), vmtmp, linspace(1,length(vmtmp),100));
mat(1,:) = vtmp100;
matm(1,:) = vmtmp100;

% main loop over all beats.
% Sorts out erroneous data (eg. noise instead of beats? Fibrillations or the kind?)
for i=2:endIdx-1 % Always skip the first and last (the video might start half into a beat)
    section = diastoleEndIdx(i):diastoleBeginIdx(i+1);

	%Error handling...
    if (length(all)<section(end))
       continue 
    end

	%Grab data for corresponding section
    vals = all(section);
    valsMov = mov(section);
    vtmp = vals(cutoff+1:end-cutoff);
    vmtmp = valsMov(cutoff+1:end-cutoff);

	%Error handling...
    if (length(vtmp)<6)
       continue 
    end
	
	%For plotting later
    graphs{i,1} = vtmp;
    graphs{i,2} = vmtmp;
	
	%Interpolate for some smooth equal lengths
    vtmp100 = interp1(1:length(vtmp), vtmp, linspace(1,length(vtmp),100));
    vmtmp100 = interp1(1:length(vmtmp), vmtmp, linspace(1,length(vmtmp),100));
	
	%Save the trajectory for this beat
    mat(i,:) = vtmp100;
    matm(i,:) = vmtmp100;
end

%% The following block does the math.
% Mean/std/sm of individual lines

total = zeros(100,1);
st = zeros(100,1);
for i=1:size(mat,2)
	%Want your results in deg or rad?
    %x = mat(:,i)*360;
    x = mat(:,i)*2*pi;
    total(i) = circ_mean(x);
    st(i) = circ_std(x);
end

sm = st ./ sqrt(length(st));

totalMov = mean(matm,1);
stm = std(matm,1);
smm = stm ./ sqrt(length(stm));


