function [q,I,e,A]=sectorint(data,dataerror,energy,distance,res,bcx,bcy,mask,phi0,dphi,q);
% [q,I,e,A]=sectorint(data,dataerror,energy,distance,res,bcx,bcy,mask,phi0,dphi,q);
%
% Calculates the radial average of the scattering image in a sector.
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
%    phi0      : the starting angle of the averaging. Zero direction is [1,0],
%		 positive counterclockwise. Expected in DEGREES.
%    dphi      : the width of the averaging region, in DEGREES.
%    q         : [OPTIONAL] if supplied, do averaging on this q-range.
%                If not given, the default q-scale will be used. 
%
% OUTPUT:
%    q       : q values
%    I       : intensity values
%    e       : errors of the intensity values
%    A       : the area of the q-bins, in pixels.
%
% Created: 6.2.2009 Andras Wacha (awacha at gmail dot com)
% Edited: 10.2.2009 AW (Now RES can be a vector of two)

error('Please build radint1.c by: mex -v -DSECTORINT radint1.c -output sectorint');
