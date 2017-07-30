// VideoInfo.cpp :
// Seems rather straight-forward and is not crucial...

#include "mex.h"
#include "matrix.h"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

std::string readMATLABString(const mxArray *prhs)
{
	int buflen = (mxGetM(prhs) * mxGetN(prhs)) + 1;
	char *input_buf = (char *)mxCalloc(buflen, sizeof(char));
	mxGetString(prhs, input_buf, buflen);

	std::string toReturn(input_buf);
	mxFree(input_buf);

	return toReturn;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	std::string vidfilename = "";
	if (!(mxIsChar(prhs[0]))){
		printf("(VideoInfo) First arg is no string! Enter movie path.\n");
	}else{
		vidfilename = readMATLABString(prhs[0]);
	}

	cv::VideoCapture vc(vidfilename);
    if ( !vc.isOpened() ){
		printf("Could not open video (reading failed) %s\n",vidfilename.c_str());
    }
	
	int w = vc.get(CV_CAP_PROP_FRAME_WIDTH);
	int h = vc.get(CV_CAP_PROP_FRAME_HEIGHT);
	int nf = vc.get(CV_CAP_PROP_FRAME_COUNT);
	int fps = vc.get(CV_CAP_PROP_FPS);
	int tw = w, th = h;

	mwSize outdim[1] = { 4 };
	plhs[0] = mxCreateNumericArray(1, outdim, mxSINGLE_CLASS, mxREAL);
	float *data = (float *)mxGetPr(plhs[0]);
	data[0] = nf;
	data[1] = fps;
	data[2] = w;
	data[3] = h;
}

