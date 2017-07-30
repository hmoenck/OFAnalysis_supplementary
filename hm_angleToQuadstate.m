function [state, conf] = hm_angleToQuadstate(val, tresh, eval, ...
    decisionBound, angleBin)
    %% Takes a histogram of directions and converts it to a quadstate.
    % That is, decide whether there is significant movement (more than tresh)
    % and if so, set it to contract (3), relax (1) or unsure (2).
	% This function is rather crucial, as it makes the difference from 
	% "We see some kind of movement" to "We see contraction/relaxation".
    %   Input:
    %       val				The value to be above threshold. You could also do this here...
	%		tresh			Threshold for significant movement
	%		eval			Directional data, binned.
	%		decisionBound	Confidence for one direction to be dominant.
    %   Output:
    %       state			Quadstate of this very frame
	%		conf			Currently unused. You might want to return a confidence though
    
    s = sum(eval(1:10));
    s2 = sum(eval(11:20));

	% Is there movement at all, ie. above threshold?
    if val > tresh 
		
		% This is the crucial part:
		% Check which direction has more movement.
		% You can try different things here, 
		% like maximum, fitting a gaussian, etc.
		% For us, taking a little more than 180° worked best.
		% Ie. 1:11 and 12:20. Taking into account the region around
		% the 0 (2:11 and 12:20 and 1) hardly has effect,
		% as there is hardly movement around 0.
		% For you to picture this: We start at 0 (see our radial plots).
		% Then we step forward in 20 bins, which are 18°. 
		% If hearts contracted perfectly vertically, quadrants 1 and 2
		% would hold relaxation (by definition, these have been qualized).
		% It's not perfectly vertically, but slightly "leaned". 
		% You can tall from angular distribution plots.
        eval = eval ./ max(eval);
        s = sum(eval(1:10+angleBin));
        s2 = sum(eval(10+angleBin:20));

		% apply states or "unsure".
        if(abs(s2-s)<decisionBound)
            state = 2;
        else
            if (s > s2)
                state = 1;
            else
                state = 3;
            end
        end
    else
		% No signal
        eval = 1:20;
        eval(:) = 0;
        state = 0.0;
    end
end
