function [diCl, dsCl, fwCl, fwrCl] = ...
    hm_OFCGetIntervalsFromQuadstate(xaAll,minDist, ...
    maxGapSize,artifactWidth, ruleset)
    %% Processes a stream of quadstates into intervals
    %   Input:
    %       xaAll				Quadstate sequence
	%		minDist				Passed to hm_intervalRules. See docstring there.
	%		maxGapSize			Passed to hm_intervalRules. See docstring there.
	%		artifactWidth		Passed to hm_intervalRules. See docstring there.
	%		ruleset 			Passed to hm_intervalRules. See docstring there. 
    %   Output:
    %       diCl				Diastolic interv. markers ("from")
	%		dsCl				Systolic interv. markers ("to")
	%		fwCl				Contraction durations
	%		fwrCl				RelaxationDurations
    
%% Initialize data structures
tmp = xaAll;
%Filter again, if you feel you need it. 
%tmp = medfilt1(xaAll);

signature = [];
sstart = [];
send = [];

tmp(tmp==1.5) = 0;

origBlocks = tmp;

%% find basic signature blocks
blockstart = 1;
blockend = 1;
inblock = 0;
for i=1:length(tmp)
   if tmp(i) ~= inblock
       inblock = tmp(i);
       blockend = i-1;
           signature = [signature tmp(i)];
           sstart = [sstart blockstart];
           send = [send blockend];
       blockstart = i;
   end
end

%Border case...
signature = [0 signature];

%% merge blocks
%sig 1 == 0 only
%sig 1 == 1 only
%sig 2 == 2 only
%sig 3 == 1-2
%sig 4 == 2-1
%sig 5 == 1-2-1

% Do this or not, according to your needs. Noisefilters are always helpful.
[signatureCl, sendCl, sstartCl] = hm_filterNoiseSequences(signature, send, sstart);

[signatureCl, sendCl, sstartCl] = hm_intervalRules( ...
    signatureCl, sendCl, sstartCl, artifactWidth, minDist, maxGapSize, ruleset);
[diCl, dsCl, fwCl, fwrCl] = hm_signatureToIntervals(signatureCl, sendCl, sstartCl, origBlocks);

return;
