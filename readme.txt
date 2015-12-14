README
funcflow v1.0
==============================================
This is an implementation for the funcflow framework using a pixel-basis.  For 
details on the method, please refer to the pdf attached in this folder.  
The code has been tested on Matlab 2015a on a CentOS 7 machine.

In short, the algorithm initializes correspondence among a network of images
using an off-the-shelf optical flow algorithm such as SIFTflow(http://people.csail.mit.edu/celiu/SIFTflow/) projected into a reduced
space.  Then, through alternating optimization, we optimize new correspondences 
that are consistent across the network of images.  We optimize in the reduced space
using functional maps, as it is easier to do so.

There are many functions and not many comments as of yet, sorry.  Right now 
the package works only for pixels.  Superpixel functionality to be added 
soon.

=============================================
Dependencies:
=============================================
cvx (http://cvxr.com/cvx/)
dsp (http://vision.cs.utexas.edu/projects/dsp/)
gbvs (http://www.vision.caltech.edu/~harel/share/gbvs.php)
gist (http://people.csail.mit.edu/torralba/code/spatialenvelope/) 
gop (http://www.philkr.net/home/gop)
siftflow ( http://people.csail.mit.edu/celiu/SIFTflow/ )
SLIC (http://ivrl.epfl.ch/research/superpixels) 

Please download/install all these packages in the "external" folder
The ones with public licenses have already been added (cvx, gbvs, gop, SLIC).  

NOTE: current release does not use cvx or SLIC

For additional datasets, please download iCoseg(http://chenlab.ece.cornell.edu/projects/touch-coseg/)
and MSRC (http://research.microsoft.com/en-us/projects/objectclassrecognition/)
==============================================
-
-
-

To run the pipeline, simply execute demo.  The code assumes the images you
want segment are all in the same directory.  For evaluation, it assumes there is a 
sub-directory in your image-directory named "GroundTruth" that has the ground truth
binary masks of every photo, with the same name.  

There are a number of parameters with explanations in the demo.m file 
that can be modified.  Not all files are used.  This is a work in progress.
