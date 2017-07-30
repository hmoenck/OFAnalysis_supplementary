function [signature, send, sstart] = hm_intervalRules( ...
    signature, send, sstart, lw, minD, maxGapSize, rule)
    %% Combines signature stream levels to create interval signature levels
    %  Roughly speaking: first we had signatures: null, contract, null, relax
    %                    Now we have: null, beat
	%  See comments of hm_sig or details.
    %   Input:
	%		signature	Vector of all signatures
	%		send		Vector holding end   positions of sig's
	%		sstart		Vector holding start positions of sig's
	%		maxGapSize	Minimum size of the "center segment". 
	%					Eg. for [2 0 1] 0 must be shorter than minD to be regarded.
	%					Useful to filter noise. 
	%		minD		unused, redundant to maxGapSize. REMOVE.
	%		lw			Same as minD, but for the first element in the rule. Eg. for [2 0 1] the 2
	%		rule		Name of the ruleset as a string. For convinience
    %   Output:
    %       signature	Updated variables
	%		send		Updated variables
	%		sstart		Updated variables

    %% This loop combines heart beat signute combination.
    % Where 2 is a contraction, 0 nothing and 1 a relaxation.
    % 4 is an evaluation type, which means "complete beat".
    act = 0;

    i = 1;
    if (strcmp(rule,'Default'))
	
		% This applies a rather common ruleset.
        while i<length(signature)-2
			%This rule "eats" small artifacts, where you can regulate artifact size (The 0 is the artifact)
            %2 gap 2
            [signature, send, sstart, act] = hm_sig([2 0 2],2, i, signature, send, sstart, maxGapSize, 0);
            i = i - act;
            
            %2 gap 1  %% Artifact as well
            [signature, send, sstart, act] = hm_sig([1 0 1],1, i, signature, send, sstart, maxGapSize, 0);
            i = i - act;

            %2 gap 1  %% Heartbeat with some "tension time" or detection error
            [signature, send, sstart, act] = hm_sig([2 0 1],4, i, signature, send, sstart, maxGapSize, 0);
            i = i - act;

            %2 to 1  %% Heartbeat, seemless
            [signature, send, sstart, act] = hm_sig([2 1],4, i, signature, send, sstart, 0, 0);
            i = i - act;

            %4 gap 1 %% Eating some more artifacts
            [signature, send, sstart, act] = hm_sig([4 0 1],4, i, signature, send, sstart, maxGapSize, 0);
            i = i - act;

            i = max(i+1,1);
        end 
    end
    
    
    if (strcmp(rule,'Aging'))
		% Different ruleset for different kind of videos.
		% ...
    end    
end