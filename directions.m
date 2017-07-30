function varout = directions(dirs,section)
    %% Calculates the direction data using an approximation via Gauss.
    %   The gauss is fitted on the directional vector distribution.
    %   The peak represents the mean direction at the given timepoint.
	%   This das not properly handle cases which wrap around 0,
	%	as this seems to be the most unrealistic movement/result possible.
	%	Iff you encounter these cases, evaluate your input videos
	%	for well-formedness.
    %   
    %   Input:
    %       dirs		Direction histograms (See OF interv. detection section)
	%		section		Section of frames to process
    %   Output:
    %       varout		Vector of peak directions
    
m = -1;
varout = zeros(length(section)+1,1);

parfor i=1:length(section)
   top = dirs{i,1}; 
   f = [];
   %Fit a gaussian
   try
       %Gauss1 may fail sometimes.
       %So worst-case use gauss2 (results might be inaccurate)
       f = fit((1:20)',double(dirs{section(i),1}),'gauss1');
   catch 
       try
            f = fit((1:20)',double(dirs{section(i),1}),'gauss2');
       catch
           varout(i) = 0;
           continue
       end
   end
   %find max
   [a,m]=max(feval(f, 1:0.1:20));
   actual = double(m)/10.0+1;
   actual = actual/20.0;
   varout(i) = actual;

end


