function flowResults = hm_doOpticalFlow(file, left, right)
    %% Calculates the optical flow for the main section.
    %   Uses Lukas-Kanade algorithm
    %   Input:
    %       file - Video file (full path)
    %       left - leftmost part of the segment to analyze
    %       right - rightmost part of the segment to analyze
    %   Output:
    %       flowResults - Comprehensive datastructure of OF analysis

	% Retrieve movie info
    movInfo = sh_seqinfo(file);
    totalFrames = movInfo.NumFrames;

	% Create optical flow object
    opticFlow = opticalFlowLKDoG('NoiseThreshold',0.00001);%

	% Our videos are 150px hight. 
	% These define the vertical sections to split into.
    tLow = 1;
    tHigh = 75;
    bLow = 76;
    bHigh = 150;

    % Set up for stream
    xmTop = 1:totalFrames;
    xmBot = 1:totalFrames;
    xm = 1:totalFrames;
    nFrames = 1;

	% Prepare data structure
    Cell = cell(totalFrames,2);

	% Load video file. We use a handcrafted C++ library using OpenCV/FFMPEG
	% for this, as it is faster than matlab native implementation.
	% However, matlab implementation will do the trick as well.
    vid = VideoLoader(file,1:1);

    while (nFrames<totalFrames)  
		% Process the videos in chunks of 2000 frames
        if mod(nFrames,2000) == 1
            vid = VideoLoader(file,nFrames:nFrames+2000);
            vid = vid(:,left:right,:);
        end
        frame = vid(:,:,mod(nFrames,2000)+1);

		% Use matlab OF implementation
        flow = estimateFlow(opticFlow,frame);
		
		% Grab magitudes and orientation into something more readable
        magsTop = flow.Magnitude(tLow:tHigh,:);
        magsBot = flow.Magnitude(bLow:bHigh,:);
        orisTop = flow.Orientation(tLow:tHigh,:);
        orisBot = flow.Orientation(bLow:bHigh,:);

		% Simple mean of magnitudes, filtering the noise away (>0.01)
        xmTop(nFrames) = mean(magsTop(magsTop>0.01));
        xmBot(nFrames) = mean(magsBot(magsBot>0.01));
        xm(nFrames) = mean(flow.Magnitude(flow.Magnitude>0.01));

		% Creating histograms of orientations weighted by magnitudes
		% Done for top and bottom separately
		% Histvw according to https://de.mathworks.com/matlabcentral/fileexchange/42493-generate-weighted-histogram
        [histw, histv] = histwv(orisTop(:), magsTop(:), -1*pi, pi, 20) ;
        eval = histw .* histv;
        Cell{nFrames,1} = eval;

        [histw, histv] = histwv(orisBot(:), magsBot(:), -1*pi, pi, 20) ;
        eval = histw .* histv;
        Cell{nFrames,2} = eval;

        nFrames = nFrames + 1;
    end

	% Save results into a return variable
    flowResults = cell(4,1);
    flowResults{1} = Cell;
    flowResults{2} = xmTop;
    flowResults{3} = xmBot;
    flowResults{4} = xm;
end

