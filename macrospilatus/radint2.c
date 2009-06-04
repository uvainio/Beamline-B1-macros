/*
  radint2.c
  
  Perform radial/sector/asimuthal integration on 2d scattering data.
  This is a mex-c file, for Octave/Matlab. See radint.m, sectorint.m
  or asimint.m for help text, respectively.
  
  Before you can use it, you must compile it with mex.
 
  COMPILING:
     1. Radial integration:
          mex -v -DRADINT radint2.c -output radint
     2. Sector integration:
          mex -v -DSECTORINT radint2.c -output sectorint
     3. Asimuthal integration:
          mex -v -DASIMINT radint2.c -output asimint
  Please take note of the warning messages on the output lines.
  You can add other parameters on compile time:
     -DNSUBDIVX=<small integer value> : the pixels of the scattering matrix
               will be divided to this many sub-pixels in the x direction.
               Thus one such sub-pixel will have 1/(NSUBDIVX*NSUBDIVY) of
               the intensity corresponding to that pixel. Default value is 7.
     -DNSUBDIVY=<small integer value> : the same as above but for y direction.
     -DNSUBDIV=<small integer value> : equivalent to 
          -DNSUBDIVX=<small integer value> -DNSUBDIVY=<small integer value>
     -DBSRADIUS=<nonnegative value> : the radius in mm on the detector surface,
               which corresponds to the first q-bin. This is only used when
               automatic creation of the q-range is requested. Default value
	       is 0.
 
  Question about this piece of code are welcome. I will try to answer :-)

  Created: 6.2.2009. Andras Wacha (awacha@gmail.com)
  Edited: 10.2.2009. AW (now all three functions are in one file. Distinction
  is made by analysing the called name, from mexFunctionName)
  Edited: 12.2.2009. AW (a bit of speedup in the error calculation, thanks
  Ulla!)
  Edited: 26.4.2009. AW Now q/a range can be supplied without producing
  SEGFAULT. This is accomplished by returning a copy of that vector, not the
  vector itself, which was received as an input parameter.
  Edited: 27.4.2009. AW mask is now allocated if it was not supplied as an
  mxLogical, thus another SEGFAULT is eliminated.
  Edited: 4.5.2009. AW Replaced call-by-name method to decide-on-compile-time.
  Edited: 21.5.2009. AW Swapped q-loop and pixel loops to gain speed. Also,
  I have re-written TEST3, because it was not correct. Complete restructuring
  of code.
  Edited: 26.5.2009. AW The default q_max is now calculated from the length
  of the diagonal of the detector, not from its half value.
  Edited: 27.5.2009. AW if the first argument is "info", an informational
  message is printed about configuration. Q-range is now deduced from the mask
  matrix.
 */

#include "mex.h"
#include <math.h>
#include <string.h>

#ifdef INT_MODE
#undef INT_MODE
#endif

#if ((defined(RADINT) && defined(SECTORINT)) || (defined(RADINT) && defined(ASIMINT)) || (defined(SECTORINT) && defined(ASIMINT)))
#error Only one of RADINT, SECTORINT, ASIMINT should be defined at compile time!
Die here. /*this is needed, as lcc for Matlab 7.0 treats #error
	    directives as warnings, and they are ignored if there are
	    no syntax errors in the source.*/
#endif

#define RAD 1
#define SECTOR 2
#define ASIM 3

#ifdef RADINT
#define INT_MODE RAD
#define MODESTRING "radint"
#elif defined(SECTORINT)
#define INT_MODE SECTOR
#define MODESTRING "sectorint"
#elif defined(ASIMINT)
#define INT_MODE ASIM
#define MODESTRING "asimint"
#else
#error One of RADINT, SECTORINT, ASIMINT should be defined at compile time!
Die here. /*look above.*/
#endif


#ifndef HAVE_OCTAVE /*Matlab 7 does not yet define mwSize and
		     mwIndex. Octave does. I do not have access to
		     higher versions of Matlab, so I could not find a
		     test for that. Please, someone, help.*/
typedef int mwSize;
typedef int mwIndex;
#define strncasecmp strnicmp   /*lcc of Matlab 7 does not have
                                strncasecmp.  Octave, however does not
                                have strnicmp. :-(*/
#endif

#ifndef BSRADIUS
#warning Default value for BSRADIUS (0) used. Override it with -DBSRADIUS=<your value> if you like.
#define BSRADIUS 0 /*radius of the beamstop, in mm-s. This is only
		     used when automatic q-range generation is
		     requested.*/
#endif

#ifdef NSUBDIV
#define NSUBDIVX NSUBDIV
#define NSUBDIVY NSUBDIV
#else
#ifndef NSUBDIVX
#define NSUBDIVX 7
#warning Default value for NSUBDIVX (7) used. Override it with -DNSUBDIVX=<your value> if you like.
#endif
#ifndef NSUBDIVY
#define NSUBDIVY 7
#warning Default value for NSUBDIVY (7) used. Override it with -DNSUBDIVY=<your value> if you like.
#endif
#endif

#ifndef HC
#define HC 12396.4  /*Planck's constant times speed of light, in
		      eV*Angstroem units.*/
#endif

#define MIN(a,b) (((a)>(b))?(b):(a))
#define ABS(a)   (((a)>0)?(a):(-(a)))

double smallestangle(double a, double b)
{
  double tmp=fmod(a-b+10*M_PI,2*M_PI);
  double tmp1=ABS(tmp-M_PI);
  return MIN(tmp,tmp1);
}

int test3intersect(double angle_corner1, double angle_corner2,
		   double angle_line)
{
  double angle_edge=smallestangle(angle_corner1,angle_corner2);
  return (smallestangle(angle_corner1,angle_line)<=angle_edge) && 
    (smallestangle(angle_corner2,angle_line)<=angle_edge);
}

void doaveraging(const double *data, const double *dataerr,
		 const double energy, const double dist,
		 const double xresol, const double yresol,
		 const double bcx, const double bcy, const mxLogical *mask,
		 const double *q, double *I, double *E, double *A,
		 const mwSize M, const mwSize N, const mwSize Noutput,
		 const double par1, const double par2);

/*This is the entry point, like main() in non-Matlab(R) C.*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mwSize N,M,Noutput; /*sizes*/
  double *data, *dataerr; /*data and error matrices*/
  mxLogical *mask; /*this is the mask. It is always a logical
		     matrix. If not, it is converted.*/
  double energy, dist, xresol, yresol, bcx,bcy,resol; 
  mxArray *Imx, *qmx, *Emx, *Amx; /*mxArrays for the results*/
  double *q, *I, *E, *A; /*these are the Pr fields of the mxArrays above*/
  double par1,par2; /*parameters for sector and asimuthal mode.*/
  int qaindex; /*the index of q or a vectors on the parameter list.*/
  
  if (nrhs>0)
  if (mxGetClassID(prhs[0])==mxCHAR_CLASS)
  {
      char *tmp;
      tmp=mxArrayToString(prhs[0]);
      if (!strncasecmp(tmp,"info",4))
      {
          mexPrintf("radint.c: general purpuse integration routine.\n");
          mexPrintf("Built in:\n\tmode : %s\n\tbeamstop radius : %lf\n",
                    MODESTRING,(double)BSRADIUS);
          mexPrintf("\tsubdivision points in x direction : %u\n",
                    (unsigned)NSUBDIVX);
          mexPrintf("\tsubdivision points in y direction : %u\n",
                    (unsigned)NSUBDIVY);
          mexPrintf("\tHC : %lf ev*A\n",(double)HC);
      }
      else
      {
          mexErrMsgTxt("Incorrect string parameter (only \"info\" is supported).");
      }
      mxFree(tmp);
      return;
  }
  
  /*Check if enough arguments were supplied.*/
#if INT_MODE == RAD
  if (nrhs<8)
    mexErrMsgTxt("At least 8 arguments have to be supplied.");
#else
  if (nrhs<10)
    mexErrMsgTxt("At least 10 arguments have to be supplied.");
#endif


  /*get the dimensions of the 2d data.*/
  M=mxGetM(prhs[0]); /*No. of rows*/
  N=mxGetN(prhs[0]); /*No. of columns*/
  
  /*If the size of the data, the error and the mask matrix differ, produce an
    error*/
  if (mxGetM(prhs[1])!=M || mxGetN(prhs[1])!=N ||
      mxGetM(prhs[7])!=M || mxGetN(prhs[7])!=N)
    mexErrMsgTxt("The sizes of DATA, DATAERR and MASK should be identical.");
  
  /*Now check types of arguments. For scalars, the size too.*/
  if (mxGetClassID(prhs[0])!=mxDOUBLE_CLASS)
    mexErrMsgTxt("DATA should be a double precision array.");
  if (mxGetClassID(prhs[1])!=mxDOUBLE_CLASS)
    mexErrMsgTxt("DATAERR should be a double precision array.");
  if (mxGetClassID(prhs[2])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[2])!=1)
    {
      /*      mexPrintf("Type of ENERGY is: %d, size of it is: %lu mxDOUBLE_CLASS is: %d\n",mxGetClassID(prhs[2]),mxGetNumberOfElements(prhs[2]),mxDOUBLE_CLASS);*/
      mexErrMsgTxt("ENERGY should be a double precision scalar.");
    }
  if (mxGetClassID(prhs[3])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[3])!=1)
    mexErrMsgTxt("DISTANCE should be a double precision scalar.");
  if (mxGetClassID(prhs[4])==mxDOUBLE_CLASS)
    {
      if (mxGetNumberOfElements(prhs[4])==2)
	{
	  xresol=*mxGetPr(prhs[4]);
	  yresol=*(mxGetPr(prhs[4])+1);
	}
      else if (mxGetNumberOfElements(prhs[4])==1)
	{
	  xresol=yresol=*mxGetPr(prhs[4]);
	}
      else
	mexErrMsgTxt("RES should have one or two elements.");
    }
  else
    mexErrMsgTxt("RES should be a double precision scalar or a vector of length 2.");
  if (mxGetClassID(prhs[5])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[5])!=1)
    mexErrMsgTxt("BCX should be a double precision scalar.");
  if (mxGetClassID(prhs[6])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[6])!=1)
    mexErrMsgTxt("BCY should be a double precision scalar.");
  
  /*MASK should be treated separately. If it is of type mxLogical,
    simply get the value.*/
  if (mxGetClassID(prhs[7])==mxLOGICAL_CLASS)
    mask=(mxLogical*) mxGetData(prhs[7]);
  else if (mxGetClassID(prhs[7])==mxDOUBLE_CLASS) /*if not, try double*/
    {
      double *m1;
      mwIndex i;
      mwIndex ne=mxGetNumberOfElements(prhs[7]);
      mask=mxCalloc(ne,sizeof(mxLogical));
      mexPrintf("MASK was of type DOUBLE, converted to LOGICAL.\n");
      m1=mxGetPr(prhs[7]);
      for(i=0; i<ne; i++)
	mask[i]=m1[i];
    }
  else /*if not, fail.*/
    mexErrMsgTxt("MASK should be a logical or double precision array.");
  
  /*extract the other values*/
  data=mxGetPr(prhs[0]);
  dataerr=mxGetPr(prhs[1]);
  energy=*mxGetPr(prhs[2]);
  dist=*mxGetPr(prhs[3]);
  resol=(xresol<yresol)?(yresol):(xresol);
  bcx=*mxGetPr(prhs[5]);
  bcy=*mxGetPr(prhs[6]);
  
  /*for SECTORINT and ASIMINT, get the other two parameters*/
#if INT_MODE == SECTOR
  if (mxGetClassID(prhs[8])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[8])!=1)
    mexErrMsgTxt("PHI0 should be a double precision scalar.");
  if (mxGetClassID(prhs[9])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[9])!=1)
    mexErrMsgTxt("DPHI should be a double precision scalar.");
  par1=*mxGetPr(prhs[8])*M_PI/180.0; /*degrees -> radians*/
  par2=*mxGetPr(prhs[9])*M_PI/180.0;
#elif INT_MODE == ASIM
  if (mxGetClassID(prhs[8])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[8])!=1)
    mexErrMsgTxt("QMIN should be a double precision scalar.");
  if (mxGetClassID(prhs[9])!=mxDOUBLE_CLASS ||
      mxGetNumberOfElements(prhs[9])!=1)
    mexErrMsgTxt("QMAX should be a double precision scalar.");
  par1=*mxGetPr(prhs[8]);
  par2=*mxGetPr(prhs[9]);
#else  /*INT_MODE==RAD*/
  par1=par2=0;  /*set default values.*/
#endif
#if INT_MODE==RAD
  qaindex=8;
#else
  qaindex=10;
#endif
  if (nrhs>qaindex) /*if q or a was supplied*/
    {
      double *q1;
      mwIndex i;
      /*if the argument is not double precision, or it is more than 1
	dimensional*/
      if (((mxGetM(prhs[qaindex])>1) && (mxGetN(prhs[qaindex])>1))
	  || mxGetClassID(prhs[qaindex])!=mxDOUBLE_CLASS)
	mexErrMsgTxt("The argument for the independent variable should be a double precision vector!");
      
      q1=mxGetPr(prhs[qaindex]); /*get q.*/
      Noutput=mxGetNumberOfElements(prhs[qaindex]); /*length of
						      q. This
						      determines the
						      number of points
						      in the outputs,
						      I, E and A.*/
      /*make a copy of q. It is probably not the best idea to return the
	same object what was supplied on the parameter list.*/
      qmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
      q=mxGetPr(qmx);
      for (i=0; i<Noutput; i++)
	q[i]=q1[i];
#if INT_MODE==ASIM
      /*convert degrees to radians*/
      {
	mwIndex i;
	for (i=0; i<Noutput; i++)
	  q[i]*=M_PI/180.0;
      }
#endif
      if (Noutput<2)
	mexErrMsgTxt("At least two values should be supplied for the independent variable.");
    }
  else  /*q or a was not supplied. In this case, create the default range.*/
    {
#if (INT_MODE==RAD) || (INT_MODE==SECTOR)
      /*we need a default q-range.*/
      {
	double qmin,qmax,qstep;
    unsigned long j,k;
	mwIndex i;
	Noutput=ceil(sqrt(M*M+N*N))/2;
	qmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
	q=mxGetPr(qmx);
/*	qmin=4*M_PI*sin(0.5*atan(BSRADIUS/dist))*energy/HC;*/
    /*26.5.2009 AW a factor of 0.5 was removed from atan(). This was present
     there as for the gas detector at B1/HASYLAB the beam center was in the
     middle. For the Pilatus300k it is in the corner. So it is more safe to
     calculate the automatic q-range this way.*/
	/*qmax=4*M_PI*sin(0.5*atan(0.5*resol*sqrt(M*M+N*N)/dist))*energy/HC;*/
    /*qmax=4*M_PI*sin(0.5*atan(resol*sqrt(M*M+N*N)/dist))*energy/HC;*/
    /*27.5.2009 AW now the q-range is defined by taking the mask into account.*/
    qmin=-1;
    qmax=-1;
    for(j=0;j<M; j++)
        for(k=0;k<N; k++)
    {
        double xc,yc,q;
    	if (mask[k*M+j]!=0) /*if the pixel is masked, continue with
            		      the next one.*/
            continue;
        
        xc=(j-(bcx-1))*xresol; /*the coordinates of the center of
                        		 the pixel.*/
        yc=(k-(bcy-1))*yresol;
        q=4*M_PI*sin(0.5*atan(sqrt(xc*xc+yc*yc)/dist))*energy/HC;
        if (qmin<0)
        {
            qmin=q;
            qmax=q;
        }
        if (q<qmin)
            qmin=q;
        if (q>qmax)
            qmax=q;
    }
	qstep=(qmax-qmin)/(Noutput-1);
	for(i=0; i<Noutput; i++)
	  q[i]=qmin+i*qstep;
      }
#else /*INT_MODE==ASIM*/
      {
	mwIndex i;
	Noutput=ceil(2*(tan(asin(par2*HC/energy/4/M_PI)*2)*dist/resol));
	qmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
	q=mxGetPr(qmx);
	for(i=0; i<Noutput; i++)
	  q[i]=i*2*M_PI/((double)(Noutput)); /*radians*/
      }
#endif
      /*print a warning message about this, to inform user.*/
      mexPrintf("%s: Independent variable vector has not been supplied, using default scale.\n",MODESTRING);
    }
  
  /*At this point, we have qmx, q and Noutput.*/
  Imx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
  Emx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
  Amx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
  I=mxGetPr(Imx);
  E=mxGetPr(Emx);
  A=mxGetPr(Amx);
  /*now do the averaging. Note that par1 and par2 are supplied, as
    well as mode.*/
  doaveraging(data, dataerr, energy, dist, xresol, yresol, bcx, bcy, mask,
	      q, I, E, A, M, N, Noutput,par1,par2);
  
  /*doaveraging updated I,E,A. Now we update the left-hand-side.*/
  
  /*but before it, we convert q-scale from radians to degrees, if we
    are in ASIMUTHAL mode.*/
#if INT_MODE==ASIM
  {
    mwIndex i;
    for (i=0; i<Noutput; i++)
      q[i]*=180.0/M_PI;  /*radians -> degrees*/
  }
#endif
  if (nlhs==1) /*only I requested*/
    {
      plhs[0]=Imx;
    }
  if (nlhs==2)
    {
      plhs[0]=qmx;
      plhs[1]=Imx;
    }
  if (nlhs==3)
    {
      plhs[0]=qmx;
      plhs[1]=Imx;
      plhs[2]=Emx;
    }
  if (nlhs==4)
    {
      plhs[0]=qmx;
      plhs[1]=Imx;
      plhs[2]=Emx;
      plhs[3]=Amx;
    }
}


/*this function does the job of averaging.*/
void doaveraging(const double *data, const double *dataerr,
		 const double energy, const double dist,
		 const double xresol, const double yresol,
		 const double bcx, const double bcy, const mxLogical *mask,
		 const double *q, double *I, double *E, double *A,
		 const mwSize M, const mwSize N, const mwSize Noutput,
		 const double par1, const double par2)
  
/* Directions:
 * +-----------------------------------------> Y
 * | 1,1    1,2    1,3    1,4    ...    1,N
 * | 2,1    2,2    2,3    2,4    ...    1,N
 * | 3,1    3,2    3,3    3,4    ...    1,N
 * | 4,1    4,2    4,3    4,4    ...    1,N
 * |  .      .      .      .     .       .
 * |  .      .      .      .      .      .
 * |  .      .      .      .       .     .
 * | M,1    M,2    M,3    M,4    ...    M,N
 * |
 * | X
 * v 
 *
 */         
  
{
  mwIndex i,j,k;
#if INT_MODE==ASIM
  double rmin, rmax;
  double *phi0, *dphi;
  double dmax2,dmin2; /*dmax and dmin to the second, this is used for TEST2*/
#else
  double *rmin,*rmax; /*rmin and rmax: distances from the origin
			corresponding to the current q-ring*/
  double *dmax2,*dmin2; /*dmax and dmin to the second, this is used for TEST2*/
#if INT_MODE==SECTOR
  double phi0, dphi; /*phi0 is the beginning angle of the sector, dphi is
		       the length of it. Both are expressed in radians.*/
#endif
#endif
  double xc,yc,x0,y0,x1,y1; /*for each pixel, xc,yc is its center,
			      x0,y0,x1,y1 are the coordinates for the
			      corners*/
  double x,y;       /*loop variables for subpixel resolution*/
  unsigned long n;  /*counter for subpixel resolution*/
  double p;         /*used for subpixel resolution*/
  double avgresol=sqrt(xresol*xresol+yresol*yresol);  /*the average resolution*/
  
  /*"decode" par1 and par2*/
#if INT_MODE==ASIM
  /*these are the distances from the origin, corresponding to the lower and
    high bounds of the q-ring for azimuthal averaging.*/
  rmin=tan(asin(par1*HC/energy/4/M_PI)*2)*dist; 
  rmax=tan(asin(par2*HC/energy/4/M_PI)*2)*dist;
  /*limits for TEST2*/
  dmax2=pow(rmax+avgresol,2);
  dmin2=pow(((rmin-avgresol)<0)?0:(rmin-avgresol),2);
  phi0=mxMalloc(sizeof(double)*Noutput);
  dphi=mxMalloc(sizeof(double)*Noutput);
#else /*RAD or SECTOR*/
  rmin=mxMalloc(sizeof(double)*Noutput);
  rmax=mxMalloc(sizeof(double)*Noutput);
  dmax2=mxMalloc(sizeof(double)*Noutput);
  dmin2=mxMalloc(sizeof(double)*Noutput);
#if INT_MODE==SECTOR
  phi0=par1;  /*these are now in radians*/
  dphi=par2;
#endif /*INT_MODE==SECTOR*/
#endif /*INT_MODE==ASIM*/
  
  for (i=0; i<Noutput; i++) /*this loop cleans all the q-bins and
			      initializes rmin,rmax or phi0,dphi
			      depending on the mode. The
			      initialization of those array seems to
			      be a better idea than calculating these
			      values in every q-bin, as this is done
			      once, that would be done about M*N
			      times. Think about a 1024x1024 matrix...*/
    {
      double q1,q2; /*the left and right hand side of the i-th q-bin.*/
      A[i]=0; /*clear the bin*/
      I[i]=0;
      E[i]=0;
	    
      /********************************************************************
       *  Bin borders (marked by "x"):
       *
       *  x    x        x          x                           x         x     
       *  |         |        |            |           |                  |
       * q[0]      q[1]     q[2]         q[3] ...  q[Noutput-2]     q[Noutput-1]
       *
       *
       ********************************************************************/
      if (i>0) /*if this is not the first bin*/
	q1=0.5*(q[i-1]+q[i]);
      else /*if this is the first*/
	q1=q[0];
      if (i<(Noutput-1))  /*if this is not the last bin*/
	q2=0.5*(q[i]+q[i+1]);
      else /*if this is the last bin*/
	q2=q[Noutput-1];
	    
#if INT_MODE==ASIM
      /*the starting angle and the length of the bin. Note, that
	for angles, not the min-max interval method is used, as for q-s,
	as problems can occur around 2*pi.*/
      phi0[i]=q1;
      dphi[i]=fmod((q2-q1)+10*M_PI,2*M_PI);
      /*rmin, rmax, dmax2 and dmin2 are already defined*/
#else /*RADINT and SECTORINT*/
      /*find the minimal and the maximal radius for the given q-bin.
	For ASIMINT, it was done outside the q-loop*/
      /*phi0 and dphi is already defined for SECTORINT. They are not
	used for RADINT*/
      rmin[i]=tan(asin(q1*HC/energy/4/M_PI)*2)*dist;
      rmax[i]=tan(asin(q2*HC/energy/4/M_PI)*2)*dist;
      dmax2[i]=(rmax[i]+avgresol)*(rmax[i]+avgresol);
      dmin2[i]=(((rmin[i]-avgresol)<0)?0:(rmin[i]-avgresol))*
	(((rmin[i]-avgresol)<0)?0:(rmin[i]-avgresol));
#endif
    }
  
  /*go through the pixels.*/
  for(j=0; j<M; j++) /*rows*/
    for(k=0; k<N; k++) /*columns*/
      {
	double d1,d2,d3,d4; /*these contain the SQUARES of the distances of
			      the corners of the current pixel, from the 
			      origin*/
#if INT_MODE==ASIM || INT_MODE==SECTOR        
        double phi1,phi2,phi3,phi4; /*these contain the polar angles of the
				      corners of the current pixel, with
				      respect to angle 0 (axis x, which is
				      downwards).*/
#endif
	/*TASK #1: eliminate unneeded pixels.*/
	
	/*the current pixel is data[k*M+j] as Octave and Matlab
	  represents the matrices column-wise, as Fortran.*/
	if (mask[k*M+j]!=0) /*if the pixel is masked, continue with
			      the next one.*/
	  continue;
	/*if the pixel data or error is NaN or infinite, disregard
	  that pixel as well.*/
	if (!mxIsFinite(data[k*M+j]) || !mxIsFinite(dataerr[k*M+j]))
	  continue;

	/*TASK #2: calculate pixel coordinates and all the data which
	  have to be calculated here, not inside the q-loop.*/

	/*now calculate the coordinates. All coordinates are
	  relative to the beam-center!*/
	xc=(j-(bcx-1))*xresol; /*the coordinates of the center of
				 the pixel.*/
	yc=(k-(bcy-1))*yresol;
	/*the coordinates of the corners*/
	x0=xc-xresol*0.5;  y0=yc-yresol*0.5;
	x1=xc+xresol*0.5;  y1=yc+yresol*0.5;
	/*the squared distances of the corners from the origin.*/
	d1=x0*x0+y0*y0;  d2=x0*x0+y1*y1;
	d3=x1*x1+y1*y1;  d4=x1*x1+y0*y0;
#if (INT_MODE==SECTOR) || (INT_MODE==ASIM)        
        /*the polar angles of the corners, with respect to the +x axis*/
        phi1=atan2(y0,x0);    	phi2=atan2(y1,x0);
    	phi3=atan2(y1,x1);    	phi4=atan2(y0,x1);
#endif
	/*TASK #3: throw away pixels which for sure fall outside the
	  integration range. This means the sector for SECTORINT
	  (defined by phi0 and dphi) and the ring for ASIMINT (given
	  by rmin and rmax).*/

#if (INT_MODE==SECTOR)
        /*for sector integration only, because for azimuthal integration,
	  this is carried out inside the a-loop.*/
        /*TEST 3: For sector and asimuthal averaging methods. If neither
	  of the lines defining the sector intersects none of the edges
	  of the pixel, ignore the pixel. For an edge and a line, the
	  condition of intersection is when the following equation is
	  true for the angle of the line and one end of the edge (a1),
	  the angle of the line and the other end of the edge (a2) and
	  the angle of the two ends of the edge (b):
	  a1<b and a2<b
	  By "angle of two objects" I mean the smallest possible
	  positive angle between 0 and pi/2.*/
        if (!test3intersect(phi1,phi2,phi0) && 
            !test3intersect(phi2,phi3,phi0) && 
            !test3intersect(phi3,phi4,phi0) &&
            !test3intersect(phi4,phi1,phi0) &&
            !test3intersect(phi1,phi2,phi0+dphi) && 
            !test3intersect(phi2,phi3,phi0+dphi) && 
            !test3intersect(phi3,phi4,phi0+dphi) &&
            !test3intersect(phi4,phi1,phi0+dphi))
	  continue;
#elif (INT_MODE==ASIM)
	/*For ASIMINT, we already have all the parameters needed to perform
	  TEST1 and TEST2. */
	/*TEST 1: Eliminate pixels, for which the distance of all
	  four corners from the origin is greater than
	  rmax+sqrt(xresol^2+yresol^2). Thus these pixels fall entirely
          outside the given q-range.
	*/
	if (d1>dmax2 && d2>dmax2 && d3>dmax2 && d4>dmax2)
	  continue;
        /*TEST 2: The same as above, except for rmin.*/
    	if (d1<dmin2 && d2<dmin2 && d3<dmin2 && d4<dmin2)
	  continue;
#endif
	/*TASK #4: if we reached here, we should try to fit the pixel
	  into q-ranges.*/
        for (i=0; i<Noutput; i++) /*this is the q-loop, which goes
				    through all points of the independent
				    value (q or angle). The independent
				    value is called "q", even for asimuthal
				    integration. Thus we can use the same
				    lines of code.*/
          {
	    /*TASK #4a: in the current q-bin, we can eliminate other
	      pixels, which were not eliminated before this.*/
#if INT_MODE==RAD || INT_MODE==SECTOR
            /*We perform TEST1 and TEST2 ONLY FOR RADINT and SECTORINT!
	      Because for ASIMINT, it is done outside the q-loop.*/
            
            /*TEST 1: Eliminate pixels, for which the distance of all
    	      four corners from the origin is greater than
    	      rmax+sqrt(xresol^2+yresol^2). Thus these pixels fall entirely
              outside the given q-range.
    	    */
	    
    	    if (d1>dmax2[i] && d2>dmax2[i] && d3>dmax2[i] && d4>dmax2[i])
              continue;
	    
    	    /*TEST 2: The same as above, except for rmin.*/
    	    if (d1<dmin2[i] && d2<dmin2[i] && d3<dmin2[i] && d4<dmin2[i])
    	      continue;
#elif (INT_MODE==ASIM)
            /*for azimuthal integration only, because for sector integration,
	      this has already been carried out outside the q-loop.*/
            /*TEST 3: For sector and asimuthal averaging methods. If neither
              of the lines defining the sector intersects none of the edges
              of the pixel, ignore the pixel. For an edge and a line, the
              condition of intersection is when the following equation is
              true for the angle of the line and one end of the edge (a1),
              the angle of the line and the other end of the edge (a2) and
              the angle of the two ends of the edge (b):
	      a1<b and a2<b
	      By "angle of two objects" I mean the smallest possible
	      positive angle between 0 and pi/2.*/
            if (!test3intersect(phi1,phi2,phi0[i]) && 
                !test3intersect(phi2,phi3,phi0[i]) && 
                !test3intersect(phi3,phi4,phi0[i]) &&
                !test3intersect(phi4,phi1,phi0[i]) &&
                !test3intersect(phi1,phi2,phi0[i]+dphi[i]) && 
                !test3intersect(phi2,phi3,phi0[i]+dphi[i]) && 
                !test3intersect(phi3,phi4,phi0[i]+dphi[i]) &&
                !test3intersect(phi4,phi1,phi0[i]+dphi[i]))
	      continue;
#endif

	    /*TASK #4b: subdividing.*/
    	    n=0; /*this will contain the number of hits, ie. the number of
		   subpixels falling into the current q-bin*/
    	    for (x=x0+0.5*xresol/(double)NSUBDIVX; x<x1;
		 x+=xresol/(double)NSUBDIVX)
    	      for (y=y0+0.5*yresol/(double)NSUBDIVY; y<y1;
		   y+=yresol/(double)NSUBDIVY)
            	{
		  double rr, phi;
		  rr=x*x+y*y; /*the squared distance of the
                                subdivision point from the
                                beam-center*/
		  phi=atan2(y,x); /*the angle of the subdivision
				    point. 0 is the +x axis (pointing
				    down), positive
				    counterclockwise. This phi is in
				    [-pi,pi]*/
		  /*now decide if hit or not. The subdivision point
                    should be counted, if it is between the two
		    circles and:
		    
		    1. for RADINT, no other properties needed
		    
            	    2. in SECTORINT and ASIMINT modes, the angle
		    difference of the point (phi) and the beginning of
		    the sector (phi0) should be less than dphi.*/
#if INT_MODE==RAD
		  if (rr>rmin[i]*rmin[i] && rr<=rmax[i]*rmax[i])
		    n++;
#elif INT_MODE==SECTOR
		  if ((rr>rmin[i]*rmin[i] && rr<=rmax[i]*rmax[i]) && 
		      (fmod(phi-phi0+10*M_PI,2*M_PI)<dphi))
		    n++;
#elif INT_MODE==ASIM
		  if ((rr>rmin*rmin && rr<=rmax*rmax) && 
		      (fmod(phi-phi0[i]+10*M_PI,2*M_PI)<dphi[i]))
		    n++;
#endif
                }

	    /*TASK #4c: add the intensity to the bin*/
            p=n/(double)(NSUBDIVX*NSUBDIVY); /*this is the proportion
					       of the intensity in the
                                               current pixel, which
                                               should be added to the
					       current bin.*/
            A[i]+=p;                         /*count the area. Its
                                     	       dimension is pixels.*/
            I[i]+=data[k*M+j]*p;             /*add that part of intensity*/
            /*the squares of the errors are summed. At the end, a
	      square-root will be taken.*/
            E[i]+=(dataerr[k*M+j]*p)*(dataerr[k*M+j]*p);
	  } /*end of q-loop*/
	/*next pixel*/
      } /*end of double loop for pixels*/

  /*TASK #5: post-processing of the averaged data: normalizing by
    effective area*/
  for (i=0; i<Noutput; i++)
    {
      if (A[i]!=0) /*if the area for this q is not zero, divide, thus
		     making an average from the integral.*/
	{
	  I[i]/=A[i];
	  /*	  E[i]/=A[i]*A[i];*/ /*eliminated on suggestion of Ulla Vainio*/
	  /*	  E[i]=sqrt(E[i]);*/
	  E[i]=sqrt(E[i])/A[i]; /*this is definitely faster. Thanks.*/
	}
    }
  /*TASK #6: cleanup*/
#if INT_MODE==ASIM
  mxFree(phi0);
  mxFree(dphi);
#else /*RAD or SECTOR*/
  mxFree(rmin);
  mxFree(rmax);
  mxFree(dmax2);
  mxFree(dmin2);
#endif
}
