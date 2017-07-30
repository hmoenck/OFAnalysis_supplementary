// VideoLoader.cpp : Definiert die exportierten Funktionen für die DLL-Anwendung.
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
		printf("First arg is no string! Enter movie path.\n");
	}else{
		vidfilename = readMATLABString(prhs[0]);
	}

	cv::VideoCapture vc(vidfilename);
    if ( !vc.isOpened() ){
		printf("Could not open video (reading failed) %s\n",vidfilename.c_str());
    }else{
		//success
    }
	int w = vc.get(CV_CAP_PROP_FRAME_WIDTH);
	int h = vc.get(CV_CAP_PROP_FRAME_HEIGHT);
	int nf = vc.get(CV_CAP_PROP_FRAME_COUNT);
	int tw = w, th = h;
	double *frameIdxs = mxGetPr(prhs[1]);
	int indSize = (mxGetM(prhs[1]) * mxGetN(prhs[1]));
	const mwSize *dims = mxGetDimensions(prhs[1]);

	mwSize outdim[3] = { th, tw, indSize };
	plhs[0] = mxCreateNumericArray(3, outdim, mxSINGLE_CLASS, mxREAL);
	float *data = (float *)mxGetPr(plhs[0]);
	cv::Mat m(h, w, CV_8UC3);
	cv::Mat timg(th, tw, CV_32FC3);
    cv::Mat gray;
    int prev = -2;

	for (int i = 0; i<indSize; i++)
	{
		long frame = frameIdxs[i];

        if (frame != prev+1){
            vc.set(CV_CAP_PROP_POS_FRAMES, frame);
        }
        prev = frame; 
		if (frame >= nf)
			m.setTo(0);
		else
			vc >> timg;

        cvtColor(timg, gray, CV_BGR2GRAY);
        
		float *ptr = &data[i*tw*th];
		unsigned char *srcptr = gray.data;
        for(int x=0, z=0; x<tw; x++)
        {
            for(int y=0; y<th; y++, z++)
            {
                ptr[z] = srcptr[(y*tw+x)] / 255.f;
			}
		}
	}

}

