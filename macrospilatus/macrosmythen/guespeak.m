function newlam = guespeak(data,axv,axh)

% function newlam = guespeak(data,axv,axh)
%
% NOTE: Used by macro gauspeak.m and qrange.m!
%
% Author: Ulla Vainio, ulla.vainio@helsinki.fi (Univ. of Helsinki)
%         Edited: 2.9.2003

newlam(1) = max(axv)-min(axv);
newlam(2) = (max(axh)-min(axh))/2+min(axh);
newlam(3) = (max(axh)-min(axh))/6;
newlam(4) = (data(max(axh))-data(min(axh)))/(max(axh)-min(axh));
newlam(5) = axv(1) - newlam(4)*axh(1);
