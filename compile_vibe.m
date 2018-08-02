% compile_vibe.m
% -------------------------------------------------------------------
% Reference: mexopencv-master/BackgroundSubtractorMOG2
% Authors: LSS
% Date:    27/04/2017
% Last modified: 27/04/2017
% -------------------------------------------------------------------

cmd = ['mex -largeArrayDims VIBE_.cpp'];
eval(cmd)