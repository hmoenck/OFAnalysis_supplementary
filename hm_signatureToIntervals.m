function [di, ds, fw, fwr] = hm_signatureToIntervals( ...
    signature, send, sstart, origBlocks)
    %% Transforms signature streams with intervals into interval vectors
    %   Input:
    %       signature		Signature vector
	%		send			Signature ends
	%		sstart			Signature starts
	%		origBlocks		Original signature blocks
    %   Output:
    %       di				Diastolic interv. markers ("from")
	%		ds				Systolic interv. markers ("to")
	%		fw				Contraction durations
	%		fwr				RelaxationDurations
    
%% Assemble 4-blocks ("complete beats") to interval vectors
i = 1;
di = [];
ds = [];
fw = [];
fwr = [];
prev = 0;
while i<length(signature)-2
    if (signature(i)==4 && abs(send(i)-sstart(i))>8)
        %Grab the signature block from the vector
        b = send(i);
        a = sstart(i);
        block = origBlocks(a:b);
        
        %Find the falling edge, i.e. contraction -> relaxation
        try
        y = [block ; block(end)];
        x = [block(1) ; block];
        fall = x-y;
        pos = find(fall==2);

        pos = length(find(block==2));
        posr = length(find(block==1));
        fw = [fw pos];
        fwr = [fwr posr];
        ds = [ds a];
        di = [di prev];
        prev = b;
        catch
			% Maybe do some error handling? Up to you
        end
    end
    i = i+1;
end

end