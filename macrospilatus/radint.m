function [q,I,e,A]=radint(data,dataerror,energy,distance,res,bcx,bcy,mask,q);
% [q,I,e,A]=radint(data,dataerror,energy,distance,res,bcx,bcy,mask,q);
%
% Calculates the radial average of the scattering image.
%
%
% INPUT:
%    data      : the scattering data, as an N-by-M matrix.
%    dataerror : the error of the scattering matrix.
%    energy    : the beam energy, in eV-s.
%    distance  : the distance of the sample and the detector, in mm-s
%    res       : the size of one pixel in mm-s. If it is a scalar, it is
%		 taken for both xres and yres. But one is able to supply
%		 [xres,yres].
%    bcx,bcy   : the coordinates of the beam-center, in pixels, starting
%                from 1. bcx is the x coordinate (VERTICAL, in terms of the
%		 Octave/Matlab representation of the data), and bcy is the y
%		 coordinate (HORIZONTAL)
%    mask      : mask matrix, of the same size as data. All elements
%                of data, for which the corresponding element of mask
%                is nonzero, will be excluded.
%    q         : [OPTIONAL] if supplied, do averaging on this q-range.
%                If not given, the default q-scale will be used. 
%
% OUTPUT:
%    q       : q values
%    I       : intensity values
%    e       : errors of the intensity values
%    A	     : the area of the q-bins, in pixels.
%
% Created: 6.2.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 10.2.2009 AW (Now RES can be a vector of two)
error('Executing the Matlab script! Please build radint2.c by: "mex -v -DRADINT radint2.c -output radint" if you want to use the mex version');

