function [xaTop, xaBot, xaAll] = hm_filterQuadstate(xaTop, xaBot)
    %% Filters a quadstate, does morphological ops, etc
	%  4 states are: "Nothing", "Contraction", "Relaxation", "Not sure"
	%  For details see "angleToQuadstate"
    %   Input:
    %       xaTop 	Top half data
	%		xaBot 	Bottom half data
    %   Output:
    %       xaTop	Top half data, fixed
	%		xaBot	Bottom half data, fixed
	%		xaAll	Merged data

    xaAll = zeros(length(xaBot),1);
    xaAll2 = zeros(length(xaBot),1);
    xaAll3 = zeros(length(xaBot),1);
    xaTmp = xaBot;

    %tringular swap, make phases identical
    xaTmp(xaTmp==1) = 4;
    xaTmp(xaTmp==3) = 1;
    xaTmp(xaTmp==4) = 3;
    xaBot = xaTmp;

    %Top & Bot == 1 --> 1
    xaAll(xaBot==1) = 1;
    xaAll(xaTop==1) = xaAll(xaTop==1)+1;
    xaAll(xaTop==2) = xaAll(xaTop==2)+1;
    xaAll(xaAll==1) = 0;
    xaAll(xaAll>=2) = 1;

    %Top & Bot == 3 --> 2
    xaAll2(xaBot==3) = 3;
    xaAll2(xaTop==3) = xaAll2(xaTop==3)+3;
    xaAll2(xaAll2==3) = 0;
    xaAll2(xaAll2==6) = 2;

    %Union
    xaAll = xaAll + xaAll2;

    %Set ambigious results
    tmp = xaBot + xaTop;
    xaAll(tmp==4) = 1.5;
    xaAll(tmp==5) = 2;
    xaAll(tmp==3) = 1;

    %Can't do this with a filter?
	%Anyways, expand regions where "uncertain".
    for i=1:30
        f1 = [0 ; xaAll];
        f2 = [xaAll ; 0];
        r = [0 ; xaAll];

        if mod(i,2) == 0
            r = [xaAll ; 0];
        end

        r(f1+f2==3.5) = 2;
        r(f1+f2==2.5) = 1;

        if mod(i,2) == 0
            xaAll = r(2:end);
        else
            xaAll = r(1:end-1);
        end
    end
    
    %Some simple noise suppression
    pf = 1;
    t = xaAll(1);
    for i=1:length(xaAll)
        tn = xaAll(i);
        if (tn ~= t)
            seg = xaAll(pf:i-1);
            if (length(seg)<4)
                xaAll(pf:i-1) = xaAll(max(pf-1,1));
            end
            pf = i;
        end
        
        t = tn;
    end
end
