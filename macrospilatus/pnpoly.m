function inside=pnpoly(mat,x,y)
%function inside=pnpoly(mat,x,y)
%
% Decide if the points of a matrix fall inside a polygon.
%
% Inputs:
%     mat: the matrix. Only its shape is used.
%     x: x (column) coordinates of the vertices
%     y: y (row) coordinates of the vertices
%
% Output:
%     inside: a matrix of the same shape as mat. Its elements are 1s for
%          included, 0 for excluded points
%
% Notes:
%     uses the algorithm PNPOLY from Wm. Randolph Franklin.
%
%First working version: 12.11.2010, Andras Wacha (awacha at gmail dot com)
%

% Copyright notice from the original version:
% Based on the work of Wm. Randolph Franklin (http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html).
%
% Copyright (c) 1970-2003, Wm. Randolph Franklin
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimers.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice in the documentation and/or other materials provided with
%      the distribution.
%   3. The name of W. Randolph Franklin may not be used to endorse or
%      promote products derived from this Software without specific prior
%      written permission. 
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%

[R,C]=ndgrid(1:size(mat,1),1:size(mat,2));
inside=zeros(size(mat));

if ~(x(end)==x(1) && (y(end)==y(1)))
    x(end+1)=x(1);
    y(end+1)=y(1);
end

for i=1:(numel(x)-1)
    j=i+1;
    flipinside=(((y(i)-R).*(y(j)-R))<0) & (C < (x(j)-x(i))*(R-y(i))/(y(j)-y(i)) + x(i));
    inside=inside+flipinside;
end

inside=mod(inside,2);
