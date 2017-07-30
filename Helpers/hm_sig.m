function [signature, send, sstart, act] = hm_sig(row,aggr, i, signature, ...
    send, sstart, minD, lw)
    %% Helper function to merge signatures.
	% A signature is a conbination of consecutive identical events. Eg.
	% if contr. = 2, relax. = 1, unsure = 3, nothing = 0
	% then you can define a signature as 4 = 2, 1 as a "heartbeat"
	% Now you might want to concidder 4 = 2, 0, 1 also as "heartbeat", iff the 0 section is short.
	% This way you could even define more sophisticated structures, such as
	% 5 = 4, 4 and apply recursively. Hence, this will be some kind of "well formed fibrillation" of n beats, hypothetically speaking.
	% Note that you might just want an aggregate of ill-formed events, such as 6 = 6, 0, 1 and 6 = 0, 1, etc.
	% 		or maybe just group anything close to each other which is not 4 is ill-formed.
	% From a technical perspective you can do with these sections whatever you want. Just define what's biologically meaningful.
	% This function takes an awful lot of parameters, as it is only thought to be a small helper.
    %   Input:
    %       row			Aggregate rule. Eg. for 4 = 2, 0, 1 this is [2 0 1]
	%		aggr		Aggregate result. Eg. for 4 = 2, 0, 1 this is 4
	%		i			The current signature to analyze (and successors)
	%		signature	Vector of all signatures
	%		send		Vector holding end   positions of sig's
	%		sstart		Vector holding start positions of sig's
	%		minD		Minimum size of the "center segment". 
	%					Eg. for [2 0 1] 0 must be shorter than minD to be regarded.
	%					Useful to filter noise. 
	%		lw			Same as minD, but for the first element in the rule. Eg. for [2 0 1] the 2
    %   Output:
    %       signature	Updated variables
	%		send		Updated variables
	%		sstart		Updated variables
	%		act			Did an update happen or not?
    
    if (i>length(signature))
       return; 
    end
    
    act = 0;
    if(length(row) == 3)
        if (signature(i) == row(1) ...
                && (lw == 0 || abs(send(i)-sstart(i)  < lw)) ...
                && signature(i+1) == row(2) ...
                && signature(i+2) == row(3) ...
                && abs(send(i+1)-sstart(i+1)) < minD)
            signature(i) = aggr;
            send(i) = send(i+2);
            signature(i+1) = [];
            sstart(i+1) = [];
            send(i+1) = [];
            signature(i+1) = []; 
            sstart(i+1) = [];
            send(i+1) = [];
            act = 1;
        end
    end

    if(length(row) == 2)
        if (signature(i) == row(1) ...
                && (lw == 0 || abs(send(i)-sstart(i) < lw) ) ...
                && signature(i+1) == row(2))
            signature(i) = aggr;
            send(i) = send(i+1);
            signature(i+1) = [];
            sstart(i+1) = [];
            send(i+1) = [];
            act = 1;
        end
    end
    
