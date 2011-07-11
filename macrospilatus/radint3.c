/*
  radint3.c
  
  Perform radial/sector/asimuthal integration on 2d scattering data.
  This is a mex-c file, for Octave/Matlab. See radint.m, sectorint.m
  or asimint.m for help text, respectively.
  
  Before you can use it, you must compile it with mex.
 
  COMPILING:
     1. Radial integration:
          mex -v -DRADINT radint3.c -output radint
     2. Sector integration:
          mex -v -DSECTORINT radint3.c -output sectorint
     3. Asimuthal integration:
          mex -v -DASIMINT radint3.c -output asimint
  Please take note of the warning messages on the output lines.
 
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
  Edited: 29.6.2009. AW Added counter "proportion_added" which for every pixel,
  counts the sub-pixels which were distributed to q-bins. If this reaches
  NSUBDIVX*NSUBDIVY, the q-loop is terminated.
  Edited: 30.6.2009. AW Calculation of rr and phi for sub-pixels is now done
  before the q-loop begins. This and the last editing improved the speed by
  a bit more than 2.
  Edited: 20.10.2010. AW renamed radint3. Included possibility to calculate and
  return effective mask, averaged q-values and their standard deviation.
  Eliminated subdivision and beam stop radius. STILL UNDER TESTING!!!
  Edited: 24.06.2011. AW tuning for Matlab under Linux (lcc-gcc differences).
  Verbosity can now be controlled by (not) defining VERBOSE at compile time.
  Info mode (i.e. radint3('info')) now prints the date and time of build as
  well. Important parts were not touched.
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
#  define INT_MODE RAD
#  define MODESTRING "radint3"
#elif defined(SECTORINT)
#  define INT_MODE SECTOR
#  define MODESTRING "sectorint3"
#elif defined(ASIMINT)
#  define INT_MODE ASIM
#  define MODESTRING "asimint3"
#else
#  error One of RADINT, SECTORINT, ASIMINT should be defined at compile time!
Die here. /*look above.*/
#endif


#if (MX_API_VER<0x07040000)
            /*Matlab 7 does not yet define mwSize and
		     mwIndex. Octave does, so as Matlab 2007b and above do.*/
#error MX_API_VER
#define mwSize int
#define mwIndex int
#endif
        
#ifndef __USE_BSD
#define strncasecmp strnicmp   /*lcc of Matlab under Windows does not have
                                strncasecmp. gcc of Octave and Matlab under
                                Linux, however does not have strnicmp. :-(*/
#endif

#ifndef HC
#define HC 12396.4  /*Planck's constant times speed of light, in
		      eV*Angstroem units.*/
#endif

#define MIN(a,b) (((a)>(b))?(b):(a))
#define ABS(a)   (((a)>0)?(a):(-(a)))

void doaveraging(const double *data, const double *dataerr,
const double energy, const double dist,
const double xresol, const double yresol,
const double bcx, const double bcy, const mxLogical *mask,
const double *q, double *I, double *E, double *A,
const mwSize M, const mwSize N, const mwSize Noutput,
const double par1, const double par2,double *qmean,double*qstd,double *maskout);

/*This is the entry point, like main() in non-Matlab(R) C.*/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSize N,M,Noutput; /*sizes*/
    double *data, *dataerr; /*data and error matrices*/
    mxLogical *mask; /*this is the mask. It is always a logical
             matrix. If not, it is converted.*/
    double energy, dist, xresol, yresol, bcx,bcy,resol;
    mxArray *Imx, *qmx, *Emx, *Amx,*qmeanmx,*qstdmx,*maskoutmx; /*mxArrays for the results*/
    double *q, *I, *E, *A; /*these are the Pr fields of the mxArrays above*/
    double par1,par2; /*parameters for sector and asimuthal mode.*/
    int qaindex; /*the index of q or a vectors on the parameter list.*/
    unsigned int retflag;
    double *qmean, *qstd, *maskout;
    mwIndex i;
    
    if (nrhs>0)
        if (mxGetClassID(prhs[0])==mxCHAR_CLASS){
            char *tmp;
            tmp=mxArrayToString(prhs[0]);
            if (!strncasecmp(tmp,"info",4)){
                mexPrintf("radint3.c: general purpose integration routine.\n");
                mexPrintf("Built on: %s %s.\n\tmode : %s\n",
                __DATE__,__TIME__,MODESTRING);
                mexPrintf("\tHC : %lf ev*A\n",(double)HC);
                #ifdef VERBOSE
                mexPrintf("\tVerbose mode: True\n");
                #else
                mexPrintf("\tVerbose mode: False\n");
                #endif
                #ifdef ADVANCED_WEIGHTING
                mexPrintf("%s: Using advanced weights (taking the jacobian dq^2 into account)\n",MODESTRING);
                #endif
            }
            else{
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
    if (mxGetClassID(prhs[2])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[2])!=1){
      /*      mexPrintf("Type of ENERGY is: %d, size of it is: %lu mxDOUBLE_CLASS is: %d\n",mxGetClassID(prhs[2]),mxGetNumberOfElements(prhs[2]),mxDOUBLE_CLASS);*/
        mexErrMsgTxt("ENERGY should be a double precision scalar.");
    }
    if (mxGetClassID(prhs[3])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[3])!=1)
        mexErrMsgTxt("DISTANCE should be a double precision scalar.");
    if (mxGetClassID(prhs[4])==mxDOUBLE_CLASS){
        if (mxGetNumberOfElements(prhs[4])==2){
            xresol=*mxGetPr(prhs[4]);
            yresol=*(mxGetPr(prhs[4])+1);
        }
        else if (mxGetNumberOfElements(prhs[4])==1){
            xresol=yresol=*mxGetPr(prhs[4]);
        }
        else
            mexErrMsgTxt("radint3: RES should have one or two elements.");
    }
    else
        mexErrMsgTxt("radint3: RES should be a double precision scalar or a vector of length 2.");
    if (mxGetClassID(prhs[5])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[5])!=1)
        mexErrMsgTxt("radint3: BCX should be a double precision scalar.");
    if (mxGetClassID(prhs[6])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[6])!=1)
        mexErrMsgTxt("radint3: BCY should be a double precision scalar.");
    
  /*MASK should be treated separately. If it is of type mxLogical,
    simply get the value.*/
    if (mxGetClassID(prhs[7])==mxLOGICAL_CLASS)
        mask=(mxLogical*) mxGetData(prhs[7]);
    else if (mxGetClassID(prhs[7])==mxDOUBLE_CLASS){  /*if not, try double*/
        double *m1;
        mwIndex i;
        mwIndex ne=mxGetNumberOfElements(prhs[7]);
        mask=mxCalloc(ne,sizeof(mxLogical));
#ifdef VERBOSE        
        mexPrintf("radint3: MASK was of type DOUBLE, converting to LOGICAL.\n");
#endif
        m1=mxGetPr(prhs[7]);
        for(i=0; i<ne; i++)
            mask[i]=m1[i];
    }
    else /*if not, fail.*/
        mexErrMsgTxt("radint3: MASK should be a logical or double precision array.");
    
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
    if (mxGetClassID(prhs[8])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[8])!=1)
        mexErrMsgTxt("PHI0 should be a double precision scalar.");
    if (mxGetClassID(prhs[9])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[9])!=1)
        mexErrMsgTxt("DPHI should be a double precision scalar.");
    par1=*mxGetPr(prhs[8])*M_PI/180.0; /*degrees -> radians*/
    par2=*mxGetPr(prhs[9])*M_PI/180.0;
    #elif INT_MODE == ASIM
    if (mxGetClassID(prhs[8])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[8])!=1)
        mexErrMsgTxt("QMIN should be a double precision scalar.");
    if (mxGetClassID(prhs[9])!=mxDOUBLE_CLASS || mxGetNumberOfElements(prhs[9])!=1)
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
        if (((mxGetM(prhs[qaindex])>1) && (mxGetN(prhs[qaindex])>1)) || mxGetClassID(prhs[qaindex])!=mxDOUBLE_CLASS)
            mexErrMsgTxt("The argument for the independent variable should be a double precision vector!");
        
        q1=mxGetPr(prhs[qaindex]); /*get q.*/
        Noutput=mxGetNumberOfElements(prhs[qaindex]); /*length of q. This determines the number of points in the outputs, I, E and A.*/
        /*make a copy of q. It is probably not the best idea to return the same object what was supplied on the parameter list.*/
        qmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
        q=mxGetPr(qmx);
        for (i=0; i<Noutput; i++)
            q[i]=q1[i];
        #if INT_MODE==ASIM
      /*convert degrees to radians*/
        for (i=0; i<Noutput; i++)
            q[i]*=M_PI/180.0;
        #endif
        if (Noutput<2)
            mexErrMsgTxt("At least two values should be supplied for the independent variable.");
    }
    else{  /*q or a was not supplied. In this case, create the default range.*/
        #if (INT_MODE==RAD) || (INT_MODE==SECTOR)
      /*we need a default q-range.*/
        double qmin,qmax,qstep;
        double xc,yc,qc;
        unsigned long j,k;
        mwIndex i;
#ifdef VERBOSE        
        mexPrintf("%s: Calculating default q-range\n",MODESTRING);
#endif
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
        xc=(1-bcx)*xresol;
        yc=(1-bcy)*yresol;
        qmin=qmax=4*M_PI*sin(0.5*atan(sqrt(xc*xc+yc*yc)/dist))*energy/HC;
#ifdef VERBOSE  
        mexPrintf("%s: Going through pixels\n",MODESTRING);
#endif
        for(j=0;j<M; j++)
            for(k=0;k<N; k++){
                if (mask[k*M+j]!=0) /*if the pixel is masked, continue with the next one.*/
                    continue;
                
                xc=(j-(bcx-1))*xresol; /*the coordinates of the center of the pixel.*/
                yc=(k-(bcy-1))*yresol;
                qc=4*M_PI*sin(0.5*atan(sqrt(xc*xc+yc*yc)/dist))*energy/HC;
                if (qc<qmin)
                    qmin=qc;
                if (qc>qmax)
                    qmax=qc;
            }
        qstep=(qmax-qmin)/(Noutput-1);
#ifdef VERBOSE        
        mexPrintf("%s: qmin: %lf\tqmax: %lf\n",MODESTRING,qmin,qmax);
#endif
        for(i=0; i<Noutput; i++)
            q[i]=qmin+i*qstep;
#ifdef VERBOSE
        mexPrintf("%s: Elements of output vector q have been set.\n",MODESTRING);
#endif
        #else /*INT_MODE==ASIM*/
        Noutput=ceil(2*(tan(asin(par2*HC/energy/4/M_PI)*2)*dist/resol));
        qmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
        q=mxGetPr(qmx);
        for(i=0; i<Noutput; i++)
            q[i]=i*2*M_PI/((double)(Noutput)); /*radians*/
        #endif
       /*print a warning message about this, to inform user.*/
#ifdef VERBOSE
        mexPrintf("%s: Independent variable vector has not been supplied, using default scale.\n",MODESTRING);
#endif        
    }
    
  /*At this point, we have qmx, q and Noutput.*/
    Imx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
    Emx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
    Amx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
    retflag=0;
    maskout=NULL;
    qmean=NULL;
    qstd=NULL;
    if (nlhs>4){
        maskoutmx=mxCreateDoubleMatrix(M,N,mxREAL);
        maskout=mxGetPr(maskoutmx);
    }
    if (nlhs>5){
        qmeanmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
        qmean=mxGetPr(qmeanmx);
    }
    if (nlhs>6){
        qstdmx=mxCreateDoubleMatrix(Noutput,1,mxREAL);
        qstd=mxGetPr(qstdmx);
    }
    
    I=mxGetPr(Imx);
    E=mxGetPr(Emx);
    A=mxGetPr(Amx);
  /*now do the averaging. Note that par1 and par2 are supplied, as
    well as mode.*/
#ifdef VERBOSE
    mexPrintf("%s: Calling doaveraging...\n",MODESTRING);
#endif
    doaveraging(data, dataerr, energy, dist, xresol, yresol, bcx, bcy, mask,
    q, I, E, A, M, N, Noutput,par1,par2,qmean,qstd,maskout);
#ifdef VERBOSE
    mexPrintf("%s: Returned from doaveraging.\n",MODESTRING);
#endif
  /*doaveraging updated I,E,A. Now we update the left-hand-side.*/
    
  /*but before it, we convert q-scale from radians to degrees, if we
    are in ASIMUTHAL mode.*/
    #if INT_MODE==ASIM
    for (i=0; i<Noutput; i++)
        q[i]*=180.0/M_PI;  /*radians -> degrees*/
    #endif
    if (nlhs==1) /*only I requested*/
        plhs[0]=Imx;
    if (nlhs==2){
        plhs[0]=qmx;
        plhs[1]=Imx;
    }
    if (nlhs==3){
        plhs[0]=qmx;
        plhs[1]=Imx;
        plhs[2]=Emx;
    }
    if (nlhs==4){
        plhs[0]=qmx;
        plhs[1]=Imx;
        plhs[2]=Emx;
        plhs[3]=Amx;
    }
    if (nlhs==5){
        plhs[0]=qmx;
        plhs[1]=Imx;
        plhs[2]=Emx;
        plhs[3]=Amx;
        plhs[4]=maskoutmx;
    }
    if (nlhs==6){
        plhs[0]=qmx;
        plhs[1]=Imx;
        plhs[2]=Emx;
        plhs[3]=Amx;
        plhs[4]=maskoutmx;
        plhs[5]=qmeanmx;
    }
    if (nlhs==7){
        plhs[0]=qmx;
        plhs[1]=Imx;
        plhs[2]=Emx;
        plhs[3]=Amx;
        plhs[4]=maskoutmx;
        plhs[5]=qmeanmx;
        plhs[6]=qstdmx;
    }
#ifdef VERBOSE
    mexPrintf("%s: returning from mex routine\n",MODESTRING);
#endif
}

/*this function does the job of averaging.*/
void doaveraging(const double *data, const double *dataerr,
const double energy, const double dist,
const double xresol, const double yresol,
const double bcx, const double bcy, const mxLogical *mask,
const double *q, double *I, double *E, double *A,
const mwSize M, const mwSize N, const mwSize Noutput,
const double par1, const double par2,
double *qmean, double *qstd, double *maskout)

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
  double qmin, qmax;
  double *phi0, *dphi;
  #else /*for both RAD and SECTOR*/
  double *qmin; /*rmin and rmax: distances from the origin
            corresponding to the current q-ring*/
  #  if INT_MODE==SECTOR
  double phi0, dphi; /*phi0 is the beginning angle of the sector, dphi is
               the length of it. Both are expressed in radians.*/
  #  endif
  #endif

  /*"decode" par1 and par2*/
  #if INT_MODE==ASIM
  /*these are the distances from the origin, corresponding to the lower and
    high bounds of the q-ring for azimuthal averaging.*/
  qmin=par1;
  qmax=par2;
  phi0=mxMalloc(sizeof(double)*Noutput);
  dphi=mxMalloc(sizeof(double)*Noutput);
  #else /*RAD or SECTOR*/
  qmin=mxMalloc(sizeof(double)*Noutput);
  #  if INT_MODE==SECTOR
  phi0=par1;  /*these are now in radians*/
  dphi=par2;
  #  endif /*INT_MODE==SECTOR*/
  #endif /*INT_MODE==ASIM*/
  
  if (maskout){
#ifdef VERBOSE
      mexPrintf("%s: Initializing maskout\n",MODESTRING);
#endif
      for (i=0;i<M;i++)
          for(j=0;j<N;j++)
              maskout[i+j*M]=1; /*set every pixel MASKED. Will unmask pixels if integrated.*/
  }
#ifdef VERBOSE  
  mexPrintf("%s: Initializing integration bins\n",MODESTRING);
#endif
  for (i=0; i<Noutput; i++){ /*this loop cleans all the q-bins and initializes
                             rmin,rmax or phi0,dphi depending on the mode.
                             The initialization of those array seems to
                             be a better idea than calculating these
                             values in every q-bin, as this is done
                             once, that would be done about M*N
                             times. Think about a 1024x1024 matrix...*/
      double q1,q2; /*the left and right hand side of the i-th q-bin.*/
      A[i]=0; /*clear the bin*/
      I[i]=0;
      E[i]=0;
      if (qmean)
          qmean[i]=0;
      if (qstd)
          qstd[i]=0;
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
      dphi[i]=fmod((q2-q1)+10*M_PI,2*M_PI); /*add 10*pi to avoid the sillyness of fmod below zero.*/
      /*rmin, rmax, dmax2 and dmin2 are already defined, and they are SCALARS.*/
      #else /*RADINT and SECTORINT*/
      /*find the minimal and the maximal radius for the given q-bin.
    For ASIMINT, it was done outside the q-loop*/
      /*phi0 and dphi is already defined for SECTORINT, as scalars. They are
    not used for RADINT*/
      qmin[i]=q1;
      #endif
  }
#ifdef VERBOSE  
  mexPrintf("%s: Starting pixel loop\n",MODESTRING);
#endif
  /*go through the pixels.*/
  for(j=0; j<M; j++) /*rows*/
      for(k=0; k<N; k++){ /*columns*/
          double xc,yc,qc,w1,rho;
          #if (INT_MODE==ASIM) || (INT_MODE==SECTOR)
          double phic;
          #endif
          if (mask[k*M+j]) /*if the pixel is masked, continue with the next one.*/
              continue;
         /*if the pixel data or error is NaN or infinite, disregard it.*/
          if (!mxIsFinite(data[k*M+j]) || !mxIsFinite(dataerr[k*M+j]))
              continue;
   	     /*real-space pixel center coordinates, relative to the beam-center!*/
          xc=(j-(bcx-1))*xresol;
          yc=(k-(bcy-1))*yresol;
          rho=sqrt(xc*xc+yc*yc)/dist;
/*          qc=4*M_PI*sin(0.5*atan(rho))*energy/HC;

           * q can be calculated from rho as q=4*pi*sin(0.5*atan(rho))*energy/HC.
           * this latter can be re-formulated by eliminating the trigonometric
           * functions (ie. finding sin(phi) if tan(2phi) is given, an equation of
           * the fourth order, which can be solved relatively easily.
           * Ie. if x=sin(phi), then the equation rho=2*x*sqrt(1-x^2)/(1-2*x^2) is 
           * to be solved for x. */
          qc=4*M_PI*sqrt((rho*rho+1-sqrt(rho*rho+1))/(2*(rho*rho+1) ))*energy/HC;
          #if INT_MODE==ASIM
          if ((qc<qmin) || (qc>qmax)) continue;
          #endif
          
          # if ((INT_MODE==SECTOR) || (INT_MODE==ASIM))
          phic=atan2(yc,xc);
          #endif
          #if (INT_MODE==SECTOR)
          if (fmod(phic-phi0+10*M_PI,2*M_PI)>dphi) continue;
          #endif
          #ifdef ADVANCED_WEIGHTING
          /*calculate the jacobian for this q. It can be calculated as follows:
           * rho is the reduced distance of the detector element from the beam
           * center, ie. the real-space distance divided by the sample-detector
           * distance.
           *
           */
          w1=(2*M_PI*energy/HC/dist)*(2*M_PI*energy/HC/dist)*(2+rho*rho+2*sqrt(1+rho*rho))/( (1+rho*rho+sqrt(1+rho*rho))*1+rho*rho+sqrt(1+rho*rho))*sqrt(1+rho*rho);
          #else
          w1=1;
          #endif
          for (i=Noutput-1; i>=0; i--){ /*this is the q-loop, which goes through 
                                      all points of the independent value 
                                      (q or angle). The independent value is 
                                      called "q", even for asimuthal integration. 
                                      This way we can use the same lines of code.*/
              
              /*check if the current pixel belongs to the current q (angle) bin.
               An UGLY TRICK is done here with conditional compilation!!!!*/
              #if INT_MODE==ASIM
              if (fmod(phic-phi0[i]+10*M_PI,2*M_PI)<=dphi[i])
              #else
              if (qc>=qmin[i]) /*max is not tested, because this loop will be broken after the correct q-bin has been found*/
              #endif
              {
                  A[i]+=w1; 
                  I[i]+=data[k*M+j]*w1;
                  E[i]+=dataerr[k*M+j]*dataerr[k*M+j]*w1*w1;
                  if (qmean)
                      qmean[i]+=qc*w1;
                  if (maskout)
                      maskout[k*M+j]=0; /*unmask this pixel in the effective mask, as it has been used*/
                  break; /*break the q-loop, go to the next pixel*/
              }
          } /*end of q-loop*/
      /*take the next pixel in column*/
      } /*take the next column*/
  /*end of double loop for pixels*/
  
  /*calculate standard deviation of q-s, if needed.*/
  if (qstd){
#ifdef VERBOSE
      mexPrintf("%s: Restarting pixel loop for QSTD\n",MODESTRING);
#endif
  /*go through the pixels once again.*/
      for(j=0; j<M; j++) /*rows*/
          for(k=0; k<N; k++){ /*columns*/
              double xc,yc,qc,w1,rho;
              #if ((INT_MODE==SECTOR) ||(INT_MODE==ASIM))
              double phic;
              #endif
              if (maskout)
                  if (maskout[k*M+j]!=0) continue; /*we may safely check maskout instead of mask, as if qstd is requested, maskout is requested as well.*/
              else
                  if (mask[k*M+j]) continue;
              if (!mxIsFinite(data[k*M+j]) || !mxIsFinite(dataerr[k*M+j])) continue;
              xc=(j-(bcx-1))*xresol;
              yc=(k-(bcy-1))*yresol;
              rho=sqrt(xc*xc+yc*yc)/dist;
/*          qc=4*M_PI*sin(0.5*atan(rho))*energy/HC;
 
 * q can be calculated from rho as q=4*pi*sin(0.5*atan(rho))*energy/HC.
 * this latter can be re-formulated by eliminating the trigonometric
 * functions (ie. finding sin(phi) if tan(2phi) is given, an equation of
 * the fourth order, which can be solved relatively easily.
 * Ie. if x=sin(phi), then the equation rho=2*x*sqrt(1-x^2)/(1-2*x^2) is
 * to be solved for x. */
              qc=4*M_PI*sin(0.5*atan(sqrt(xc*xc+yc*yc)/dist))*energy/HC;
              # if ((INT_MODE==SECTOR) || (INT_MODE==ASIM))
              phic=atan2(yc,xc);
              #endif
              #if (INT_MODE==SECTOR)
              if (fmod(phic-phi0+10*M_PI,2*M_PI)>dphi) continue;
              #elif (INT_MODE==ASIM)
              if ((qc<qmin) || (qc>qmax)) continue;
              #endif
              #ifdef ADVANCED_WEIGHTING
          /*calculate the jacobian for this q. It can be calculated as follows:
           * rho is the reduced distance of the detector element from the beam
           * center, ie. the real-space distance divided by the sample-detector
           * distance.
           *
          
           
           */
              w1=(2*M_PI*energy/HC/dist)*(2*M_PI*energy/HC/dist)*(2+rho*rho+2*sqrt(1+rho*rho))/( (1+rho*rho+sqrt(1+rho*rho))*1+rho*rho+sqrt(1+rho*rho))*sqrt(1+rho*rho);
              #else
              w1=1;
              #endif
              for (i=Noutput-1; i>=0; i--){
                  if (A[i]==0) continue; /*nothing was found in the previous run, why would we search once more?*/
                  #if INT_MODE==ASIM
                  if (fmod(phic-phi0[i]+10*M_PI,2*M_PI)<dphi[i])
                  #else
                  if (qc>=qmin[i])
                  #endif
                  {
                      qstd[i]+=(qc-qmean[i])*(qc-qmean[i])*w1;
                      break; /*break the q-loop, go to the next pixel*/
                  }
              } /*end of q-loop*/
      /*take the next pixel in column*/
          } /*take the next column*/
  /*end of double loop for pixels*/
  }
#ifdef VERBOSE
  mexPrintf("%s: Normalizing bins\n",MODESTRING);
#endif
  /*post-processing of the averaged data: normalizing by effective area*/
  for (i=0; i<Noutput; i++){
      if (A[i]!=0){
          I[i]/=A[i];
      /*	  E[i]/=A[i]*A[i];*/ /*eliminated on suggestion of Ulla Vainio*/
      /*	  E[i]=sqrt(E[i]);*/
          E[i]=sqrt(E[i])/A[i]; /*this is definitely faster. Thanks.*/
          if (qmean)
              qmean[i]/=A[i];
          if (qstd){
              if (A[i]>1)
                  qstd[i]=sqrt(qstd[i])/(A[i]-1);
              else
                  qstd[i]=0;
          }
      }
      else{
          I[i]=0;
          E[i]=0;
          if (qmean)
              qmean[i]=0;
          if (qstd)
              qstd[i]=0;
      }          
  }
#ifdef VERBOSE
  mexPrintf("%s: Cleaning up\n",MODESTRING);
#endif  
  /*cleanup*/
#if INT_MODE==ASIM
  mxFree(phi0);
  mxFree(dphi);
#else /*RAD or SECTOR*/
  mxFree(qmin);
#endif
#ifdef VERBOSE
  mexPrintf("%s: Returning from doaveraging.\n",MODESTRING);
#endif
}
