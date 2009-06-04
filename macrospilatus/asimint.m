function [a,I,e,A]=asimint(data,dataerror,energy,distance,res,bcx,bcy,mask,qmin,qmax,a);
% [a,I,e,A]=asimint(data,dataerror,energy,distance,res,bcx,bcy,mask,qmin,qmax,a);
%
% Calculates the asimuthal average of the scattering image in a sector.
%
%
% INPUT:
%    data      : the scattering data, as an N-by-M matrix.
%    dataerror : the error of the scattering matrix.
%    energy    : the beam energy, in eV-s.
%    distance  : the distance of the sample and the detector, in mm-s
%    res       : the size of one pixel in mm-s. If it is a scalar, it is
%                taken for both xres and yres. But one is able to supply
%                [xres,yres].
%    bcx,bcy   : the coordinates of the beam-center, in pixels, starting
%                from 1. bcx is the x coordinate (VERTICAL, in terms of the
%		 Octave/Matlab representation of the data), and bcy is the y
%		 coordinate (HORIZONTAL)
%    mask      : mask matrix, of the same size as data. All elements
%                of data, for which the corresponding element of mask
%                is nonzero, will be excluded.
%    qmin      : the starting q-value of the averaging, in inverse Angstroems.
%    qmax      : the end q-value of the averaging, in inverse Angstroems.
%    a         : [OPTIONAL] if supplied, do averaging on this asimuthal range.
%                If not given, the default scale will be used. DEGREES.
%
% OUTPUT:
%    a       : angle values, in degrees.
%    I       : intensity values
%    e       : errors of the intensity values
%    A       : the area of the q-bins, in pixels.
%
% Created: 6.2.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 10.2.2009 AW (Now RES can be a vector of two).
error('Please build radint1.c by: mex -v -DASIMINT radint1.c -output asimint');
