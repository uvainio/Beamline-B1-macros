function mask=makemask2(mask,A,maxvalue)
%function mask=makemask2(mask,A,maxvalue)
%
%A more intuitive tool to create mask matrices
%
%Inputs:
%   mask: the mask matrix. 0 means masked, 1 means non-masked.
%   A: background image. Should be of the same size as mask.
%   maxvalue: elements of A larger than this will replaced by the largest
%       of the elements of A, which are smaller than this.
%
%Output:
%   the mask matrix
%
%Usage:
%   After the figure is plotted press the buttons accordingly. The tooltips
%   should help.
%
%Created: [29:30].6.2009 by Andras Wacha (awacha at gmail dot com)
%Edited: [21:25].9.2009 by AW. Added "pixel hunting", "forget selection"
%  and "help, get me out of here" functionality. The auto-unzooming
%  "feature" was removed.
%Edited: 11.5.2010 by AW. Added debug messages to various points of the
%  macro, because of errors. It turned out however, that the errors were
%  caused by Matlab itself (eg. the plotting did not work correctly).
%  Restarting Matlab solved the problems.
%Edited: 24.3.2012 by AW. Added histogram masking method.

flagdebug=0; % set this to nonzero to enable debug messages on the console

% this is for callback mechanism. It is a bit tricky, I know. If the first
% argument of this function (which is called "mask") is a string, that
% subroutine gets called with the UserData property of the current figure.
if ischar(mask)
    handles=get(gcf,'UserData');
    mask=[mask,'(handles,flagdebug)'];
    eval(mask);
    return
end

%normal calling style begins here.
original_matrix=A; %save this for the histogramming
if nargin>2
    A(A>=maxvalue)=max(max(A(A<=maxvalue)));
end
A(A<=0)=min(min(A(A>0))); % remove zeroes. After this it is safe to take log(A)

% these are simply icon bitmaps. Skip these...

polyicon=[ 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 0 1 0 1 1 1 1 1 1 1 1 1;...
 1 1 1 0 1 1 0 1 1 1 1 1 1 1 1 1;...
 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1;...
 1 1 0 1 1 1 1 0 1 1 0 0 0 1 1 1;...
 1 0 1 1 1 1 1 1 0 0 1 1 0 1 1 1;...
 1 0 1 1 1 1 1 1 0 1 1 1 0 1 1 1;...
 1 0 1 1 1 1 1 1 1 1 1 1 0 1 1 1;...
 1 0 1 1 0 1 1 1 1 1 1 1 0 1 1 1;...
 1 0 1 0 0 1 1 1 1 1 1 1 0 1 1 1;...
 1 0 0 1 0 1 1 1 1 1 1 1 0 1 1 1;...
 1 0 0 1 1 0 1 1 1 1 1 1 0 1 1 1;...
 1 0 1 1 1 0 0 0 0 0 0 0 0 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
polyicon(:,:,2)=polyicon(:,:,1);
polyicon(:,:,3)=polyicon(:,:,1);


forgeticon=[
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
 1 1 1 1 1 0 0 1 1 1 1 0 0 1 0 1;...
 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1;...
 1 0 1 1 1 1 1 1 1 1 1 1 0 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 0 1 1 1 0 1;...
 1 1 1 1 1 1 1 1 1 0 1 1 1 1 0 1;...
 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
 1 0 1 1 1 1 1 0 1 1 1 1 1 1 1 1;...
 1 0 1 1 1 1 0 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 0 1 1 1 1 1 1 1 1 1 0 1;...
 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1;...
 1 1 0 0 0 1 1 1 1 0 0 1 1 1 1 1;...
 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
forgeticon(:,:,2)=forgeticon(:,:,1);
forgeticon(:,:,3)=forgeticon(:,:,1);

escapeicon=[
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
 1 1 1 1 1 1 0 0 0 0 0 1 1 1 0 1;...
 1 1 1 1 0 0 1 1 1 1 1 0 0 0 1 1;...
 1 1 1 0 1 1 1 1 1 1 1 1 0 0 1 1;...
 1 1 0 1 1 1 1 1 1 1 1 0 1 1 0 1;...
 1 1 0 1 1 1 1 1 1 1 0 1 1 1 0 1;...
 1 0 1 1 1 1 1 1 1 0 1 1 1 1 1 0;...
 1 0 1 1 1 1 1 1 0 1 1 1 1 1 1 0;...
 1 0 1 1 1 1 1 0 1 1 1 1 1 1 1 0;...
 1 0 1 1 1 1 0 1 1 1 1 1 1 1 1 0;...
 1 1 0 1 1 0 1 1 1 1 1 1 1 1 0 1;...
 1 1 0 1 0 1 1 1 1 1 1 1 1 1 0 1;...
 1 1 1 0 1 1 1 1 1 1 1 1 1 0 1 1;...
 1 1 0 1 0 0 1 1 1 1 1 0 0 1 1 1;...
 1 0 1 1 1 1 0 0 0 0 0 1 1 1 1 1;...
 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
escapeicon(:,:,2)=escapeicon(:,:,1);
escapeicon(:,:,3)=escapeicon(:,:,1);

pixelhunticon=[
 1, 1, 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;...
 1 1 1 1 1 0 0 1 0 1 0 0 1 1 1 1;...
 1 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1;...
 1 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1;...
 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1;...
 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;...
 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1;...
 1 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1;...
 1 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1;...
 1 1 1 1 1 0 0 1 0 1 0 0 1 1 1 1;...
 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
 
pixelhunticon(:,:,2)=pixelhunticon(:,:,1);
pixelhunticon(:,:,3)=pixelhunticon(:,:,1);

rectangleicon=[
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 0 0 0 0 0 0 0 0 0 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 0 0 0 0 0 0 0 0 0 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
rectangleicon(:,:,2)=rectangleicon(:,:,1);
rectangleicon(:,:,3)=rectangleicon(:,:,1);

triangleicon=[
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1;...
   1 1 1 1 1 1 1 1 1 0 0 1 0 1 1 1;...
   1 1 1 1 1 1 1 0 0 1 1 0 0 1 1 1;...
   1 1 1 1 1 0 0 1 1 1 1 0 1 1 1 1;...
   1 1 1 0 0 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 0 1 1 1 1 1;...
   1 1 1 0 1 1 1 1 1 1 0 1 1 1 1 1;...
   1 1 1 1 0 1 1 1 1 0 1 1 1 1 1 1;...
   1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1;...
   1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
triangleicon(:,:,2)=triangleicon(:,:,1);
triangleicon(:,:,3)=triangleicon(:,:,1);

circleicon=[
   1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1;...
   1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 0 0 1 1 1 1 1 1 1 1 0 0 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 1;...
   1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1;...
   0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
   0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
   0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0;...
   0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0;...
   0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
   0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
   1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1;...
   1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 1;...
   1 1 0 0 1 1 1 1 1 1 1 1 0 0 1 1;...
   1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1];
circleicon(:,:,2)=circleicon(:,:,1);
circleicon(:,:,3)=circleicon(:,:,1);

maskicon=[
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
   1 1 0 0 1 1 1 1 1 1 0 0 0 1 1 1;...
   1 1 0 1 0 1 1 1 1 1 0 1 0 1 1 1;...
   1 1 0 1 0 0 0 0 0 0 1 1 0 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1;...
   1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1;...
   1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1;...
   1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1;...
   1 1 0 1 1 0 1 1 1 0 1 1 0 1 1 1;...
   1 1 1 0 1 0 0 0 0 0 1 0 0 1 1 1;...
   1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 1;...
   1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1;...
   1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1;...
   1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
maskicon(:,:,2)=maskicon(:,:,1);
maskicon(:,:,3)=maskicon(:,:,1);

unmaskicon=[ 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
 0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0;...
 1 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1;...
 1 1 0 0 0 1 1 1 1 1 0 1 0 0 1 1;...
 1 1 0 0 0 0 0 0 0 0 1 0 0 1 1 1;...
 1 1 0 1 0 0 1 1 1 1 0 0 0 1 1 1;...
 1 1 0 1 0 0 0 1 1 0 0 1 0 1 1 1;...
 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1;...
 1 1 0 1 1 1 1 0 0 1 1 1 0 1 1 1;...
 1 1 0 1 1 1 0 0 0 0 1 1 0 1 1 1;...
 1 1 0 1 1 0 0 1 1 0 0 1 0 1 1 1;...
 1 1 1 0 0 0 0 0 0 0 0 0 0 1 1 1;...
 1 1 1 0 0 1 1 1 1 1 1 0 0 1 1 1;...
 1 1 0 0 1 0 1 1 1 1 1 0 0 0 1 1;...
 0 0 0 1 1 1 0 0 0 0 0 0 1 0 0 1;...
 0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0];
unmaskicon(:,:,2)=unmaskicon(:,:,1);
unmaskicon(:,:,3)=unmaskicon(:,:,1);

flipmaskicon=[ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0;...
 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0;...
 1 1 0 1 0 1 1 1 1 1 0 1 1 0 0 0;...
 1 1 0 1 0 0 0 0 0 0 1 0 1 0 0 0;...
 1 1 0 1 1 1 1 1 1 1 0 0 1 0 0 0;...
 1 1 0 1 0 0 1 1 1 1 1 0 1 0 0 0;...
 1 1 0 1 0 0 1 1 0 1 1 0 1 0 0 0;...
 1 1 0 1 1 1 1 0 0 0 0 0 1 0 0 0;...
 1 1 0 1 1 1 0 0 0 0 0 0 1 0 0 0;...
 1 1 0 1 1 1 0 0 0 1 0 0 1 0 0 0;...
 1 1 1 0 0 1 1 1 1 1 0 1 1 0 0 0;...
 1 1 1 0 1 0 0 0 0 0 0 1 0 0 0 0;...
 1 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0;...
 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0;...
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
flipmaskicon(:,:,2)=flipmaskicon(:,:,1);
flipmaskicon(:,:,3)=flipmaskicon(:,:,1);

doneicon=[ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0;...
 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1;...
 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1;...
 1 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1;...
 1 0 0 1 1 1 1 1 0 0 0 1 1 1 1 1;...
 1 0 0 0 1 1 1 1 0 0 1 1 1 1 1 1;...
 1 1 0 0 0 1 1 0 0 1 1 1 1 1 1 1;...
 1 1 1 0 0 1 0 0 0 1 1 1 1 1 1 1;...
 1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1;...
 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
doneicon(:,:,2)=doneicon(:,:,1);
doneicon(:,:,3)=doneicon(:,:,1);

histogramicon = [ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 0 0 0 0 1 1 1 1 1 1 1;...
 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1;...
 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1;...
 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1;...
 1 1 1 0 0 0 0 0 0 0 0 1 1 0 0 1;...
 1 1 1 0 0 0 0 0 0 0 0 0 1 0 0 1;...
 1 1 0 0 0 0 0 0 0 0 0 0 1 0 0 1;...
 1 1 0 0 0 0 0 0 0 0 0 0 1 0 0 1;...
 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1;...
 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1;...
 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;...
 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
histogramicon(:,:,2)=histogramicon(:,:,1);
histogramicon(:,:,3)=histogramicon(:,:,1);


invertmaskicon=ones(16,16);
[x,y]=meshgrid(1:16,1:16);
invertmaskicon(x+y>16)=0;
invertmaskicon(:,:,2)=invertmaskicon(:,:,1);
invertmaskicon(:,:,3)=invertmaskicon(:,:,1);
%end of icon bitmaps.

% here we build the toolbar.
handles=struct(); % these are the global variables. Note that the name is a
                  %bit misleading. It does not only contain the handles of
                  %the GUI elements, but other properties like the current
                  %mask as well.
handles.toolbar=uitoolbar();
handles.rectangletool=uipushtool(handles.toolbar,'CData',rectangleicon,'TooltipString','Select rectangle','ClickedCallback','makemask2(''selectrectangle'');');
handles.triangletool=uipushtool(handles.toolbar,'CData',triangleicon,'TooltipString','Select triangle','ClickedCallback','makemask2(''selecttriangle'');');
handles.circletool=uipushtool(handles.toolbar,'CData',circleicon,'TooltipString','Select circle','ClickedCallback','makemask2(''selectcircle'');');
handles.polytool=uipushtool(handles.toolbar,'CData',polyicon,'TooltipString','Select polygon','ClickedCallback','makemask2(''selectpoly'');');
handles.pixelhunttool=uipushtool(handles.toolbar,'Cdata',pixelhunticon,'TooltipString','Pixel hunting','ClickedCallback','makemask2(''gopixelhunting'');');
handles.histogramtool=uipushtool(handles.toolbar,'Cdata',histogramicon,'TooltipString','Masking by intensity histogram','ClickedCallback','makemask2(''selectbyhistogram'');');
handles.inverttool=uipushtool(handles.toolbar,'CData',invertmaskicon,'TooltipString','Invert mask','Separator','on','ClickedCallback','makemask2(''invertmask'');');
handles.masktool=uipushtool(handles.toolbar,'CData',maskicon,'TooltipString','Mask area','Separator','on','ClickedCallback','makemask2(''maskit'');');
handles.unmasktool=uipushtool(handles.toolbar,'CData',unmaskicon,'TooltipString','Unmask area','ClickedCallback','makemask2(''unmaskit'');');
handles.flipmasktool=uipushtool(handles.toolbar,'CData',flipmaskicon,'TooltipString','Flip mask on area','ClickedCallback','makemask2(''flipmask'');');
handles.forgettool=uipushtool(handles.toolbar,'CData',forgeticon,'TooltipString','Forget selection and redraw','ClickedCallback','makemask2(''forgetselection'');');
handles.donetool=uipushtool(handles.toolbar,'CData',doneicon,'TooltipString','Done','Separator','on','UserData',0,'ClickedCallback','makemask2(''doneclicked'');');
handles.escapetool=uipushtool(handles.toolbar,'CData',escapeicon,'TooltipString','Get me out of here!','Separator','on','UserData',0,'ClickedCallback','makemask2(''escapeclicked'');');


handles.redrawneeded=1; % this signals if redraw is needed in the main loop
handles.mask=mask; %the mask
handles.origmask=mask; % backup copy of the mask, this is returned when escapetool is pushed.
handles.pointstomask=[]; %the currently selected pixels
handles.done=0; % this signals the main loop to end.
handles.pixelhunting=0; % pixel hunting mode is on or off
handles.scatteringmatrix=original_matrix;
set(gcf,'UserData',handles); %"handles" is stored as the UserData field of the current figure

% the main loop
handles.firstdraw=1; % if this is the first time we draw the image.
while handles.done==0
    if flagdebug
       disp('Returned from uiwait')
    end
    if handles.redrawneeded % if redraw is needed
        hold off
        if handles.firstdraw==0
            ax=axis; % save the current zoom
            cla;
        end
        imagesc(log(A));
        hold on;
        % plot the mask semitransparently
        maskwhite=ones(size(A,1),size(A,2),3);
        h=imagesc(maskwhite);
        set(h,'AlphaData',(handles.mask==0)*0.7);
        handles.redrawneeded=0; % redraw is not needed, as it is already done.
        set(gcf,'UserData',handles); %update handles
        if handles.firstdraw==0
            axis(ax); % re-zoom to the saved position.
        end
        handles.firstdraw=0;
        drawnow;
    end
    if handles.pixelhunting
        dopixelhunt(handles,flagdebug)
    else
       if flagdebug
          disp('Uiwait...')
       end
       uiwait % wait for user interaction (pressing toolbar buttons). Execution
              % returns here when uiresume is called (at the end of each callback
              % function)
    end
    %fetch the possibly updated version of handles.
    handles=get(gcf,'UserData');
end
% we reach this point when handles.done becomes nonzero.
delete(handles.toolbar); %remove toolbar from figure
set(gcf,'UserData',[]); %remove our data
mask=handles.mask;
return %this is not needed, only for clarity

% here come the callback routines.

function escapeclicked(handles,flagdebug)
   if flagdebug
      disp('escapeclicked')
   end
   handles.done=1; % signalling an exit to the main loop
   handles.mask=handles.origmask; % reverting to the older version of the mask
   set(gcf,'UserData',handles); %updating handles
   uiresume
   
function doneclicked(handles,flagdebug) % this is called when the done button is clicked.
   if flagdebug
      disp('doneclicked')
   end
   handles.done=1; % signalling exit to the main loop
   set(gcf,'UserData',handles);
   %delete(handles.toolbar); %remove toolbar from figure
   %set(gcf,'UserData',[]); %remove our data
   %mask=handles.mask;
   %return
   uiresume
    
function selectrectangle(handles,flagdebug)
   if flagdebug
      disp('selectrectangle')
   end
   title('Select two opposite corners of the rectangle by two mouseclicks!')
   [gx,gy,gb]=ginput(2); % two mouse clicks
   % find the real corners of the rectangle
   x0=max([ceil(min(gx)) 1]);
   y0=max([ceil(min(gy)) 1]);
   x1=min([floor(max(gx)) size(handles.mask,2)]);
   y1=min([floor(max(gy)) size(handles.mask,1)]);
   %set selection
   handles.pointstomask=zeros(size(handles.mask));
   handles.pointstomask(y0:y1,x0:x1)=1;
   h=line([x0 x1 x1 x0 x0],[y0 y0 y1 y1 y0]); % draw rectangle
   set(h,'Color','white');
   title('Now mask/unmask/flip it if you want.');
   set(gcf,'UserData',handles); % update handles structure.
   uiresume % return from uiwait in main loop.

function selectpoly(handles,flagdebug)
   if flagdebug
      disp('selectrectangle')
   end
   title({'Select corners of the polygon by left clicks.';'Finish with right click (poly will be closed automatically).'})
   x=[];
   y=[];
   [gx,gy,gb]=ginput(1);
   while gb==1;
       x(end+1)=gx;
       y(end+1)=gy;
       h=plot([x(end)],[y(end)],'o');
       set(h,'MarkerFaceColor','white')
       if numel(x)>1
           h=line([x(end-1) x(end)],[y(end-1) y(end)]); % draw line segment
           set(h,'Color','white');
       end
       [gx,gy,gb]=ginput(1); % two mouse clicks
   end;
   if numel(x)<3;
       title('Next time, please select three or more points!');
       uiresume
       return
   end
   h=line([x(end) x(1)],[y(end) y(1)]); % draw line segment
   set(h,'Color','white');
   title('Calculating inside points. This may take awhile. Please be patient...')
   handles.pointstomask=pnpoly(zeros(size(handles.mask)),x,y);
   title('Now mask/unmask/flip it if you want.');
   set(gcf,'UserData',handles); % update handles structure.
   uiresume % return from uiwait in main loop.
   
   
function selecttriangle(handles,flagdebug) %select a triangle
   if flagdebug
      disp('selecttriangle')
   end
    title('Select three corners of the triangle!')
    [gx(1),gy(1)]=ginput(1); % corner C
    [gx(2),gy(2)]=ginput(1); % corner A
    h=line(gx,gy); set(h,'Color','white');
    [gx(3),gy(3)]=ginput(1); % corner B
    h=line(gx(2:3),gy(2:3)); set(h,'Color','white');
    h=line(gx([3 1]),gy([3 1])); set(h,'Color','white');
    %
    % The triangle:
    % 
    %        B
    %        .
    %        ..
    %       .  ..
    %       .    .. c
    %       .      ..
    %    a .         ..
    %      .          .. A
    %      .      ....
    %     .   ....
    %     ....   b
    %    C(x0,y0)
    x0=gx(1); y0=gy(1); v1x=gx(2)-gx(1); v1y=gy(2)-gy(1); v2x=gx(3)-gx(1); v2y=gy(3)-gy(1);
    % now we express every point of the matrix with the v1 and v2 vectors (sides a and b of the triangle),
    % with respect to the origin x0,y0 (corner C)
    [X,Y]=meshgrid(1:size(handles.mask,2),1:size(handles.mask,1));
    X=X-x0; % x coordinate for each pixel (column)
    Y=Y-y0; % y coordinate for each pixel (row)
    i1=v2y/(v1x*v2y-v2x*v1y); % the 1st component of the unit vector i. (with respect to v1)
    i2=-v1y/(v1x*v2y-v2x*v1y); % the 2nd component of the unit vector i. (with respect to v2)
    j1=v2x/(v2x*v1y-v1x*v2y); % the same as above, but for j.
    j2=-v1x/(v2x*v1y-v1x*v2y);
    A1=X*i1+Y*j1; % the coefficients for v1 for each point.
    A2=X*i2+Y*j2; % the coefficients for v2 for each point.
    
    title('Now mask/unmask/flip it if you want.')
    handles.pointstomask=zeros(size(handles.mask));
    % select pixels if both A1 and A2 is greater than 0 (the pixel lies
    % between v1 and v2) and (A1+A2)<1 (the pixel is not over side c)
    handles.pointstomask((A1>0) &(A2>0) & (A1+A2<1))=1;
    set(gcf,'UserData',handles);
    uiresume

    
function selectcircle(handles,flagdebug)
   if flagdebug
       disp('selectcircle')
   end
    title('Select circle center with left button')
    [gx,gy]=ginput(1); %origin
    title('Select circle radius with right button')
    [rx,ry]=ginput(1);
    radius=sqrt((rx-gx)^2+(ry-gy)^2);
    x=cos((0:0.01:2)*pi)*radius+gx; % x values for circle points
    y=sin((0:0.01:2)*pi)*radius+gy; % y values for circle points
    plot(x,y,'w-','LineWidth',1); % draw a circle
    title('Now mask/unmask/flip it if you want.')
    [C,R]=meshgrid(1:size(handles.mask,2),1:size(handles.mask,1));
    D=sqrt((C-gx).^2+(R-gy).^2); % distance of pixels from the origin
    handles.pointstomask=(D<radius); %do selection
    set(gcf,'UserData',handles);
    uiresume

function selectbyhistogram(handles,flagdebug)
   if flagdebug
       disp('selectbyhistogram');
   end
   hold off; cla;
   intensities=handles.scatteringmatrix(handles.mask==1);
   min(intensities(:))
   max(intensities(:))
   hist(intensities(:),100);
   xlabel('Intensity (counts)');
   ylabel('Frequency among pixels');
   title('Zoom to a range on the histogram of unmasked intensities and press ENTER!')
   axis tight
   drawnow
   oldpause=pause('on');
   pause
   pause(oldpause);
   ax=axis;
   handles.pointstomask=(handles.scatteringmatrix>=ax(1))&(handles.scatteringmatrix<=ax(2))&(handles.mask);
   handles.redrawneeded=1;
   handles.firstdraw=1;
   set(gcf,'UserData',handles);
   uiresume
    
function gopixelhunting(handles,flagdebug)
   if flagdebug
      disp('gopixelhunting')
   end
   handles.pixelhunting=1; % start pixel hunting
   set(gcf,'UserData',handles);
   uiresume
   
function returnfrompixelhunting(handles,flagdebug)
   if flagdebug
      disp('returnfrompixelhunting')
   end
   title('');
   handles.pixelhunting=0;
   set(gcf,'UserData',handles);
   uiresume
   
function dopixelhunt(handles,flagdebug)
   if flagdebug
      disp('dopixelhunt')
   end
   title('Select pixels to flip the mask over. Right button to end.')
   [gx,gy,gb]=ginput(1);
   handles=get(gcf,'UserData'); % we need this because returnfrompixelhunting can be called during ginput().
   if gb>1
       title('');
       handles.pixelhunting=0;
   end
   if handles.pixelhunting
      handles.mask(floor(gy+.5),floor(gx+.5))=1-handles.mask(floor(gy+.5),floor(gx+.5));
   end
   handles.redrawneeded=1;
   set(gcf,'UserData',handles);
   
function maskit(handles,flagdebug) % mask selected points
   if flagdebug
       disp('maskit')
   end
    if ~isempty(handles.pointstomask)
        handles.mask=handles.mask & ~handles.pointstomask;
        handles.pointstomask=[];
        handles.redrawneeded=1;
    else
        title('Select something first!');
    end
    set(gcf,'UserData',handles);
    uiresume
    
function unmaskit(handles,flagdebug) %unmask selected points
   if flagdebug
       disp('unmaskit')
   end
    if ~isempty(handles.pointstomask)
        handles.mask=handles.mask | handles.pointstomask;
        handles.pointstomask=[];
        handles.redrawneeded=1;
    else
        title('Select something first!');
    end
    set(gcf,'UserData',handles);
    uiresume
    
function flipmask(handles,flagdebug) %flip masked state of selected points
   if flagdebug
       disp('flipmask')
   end
    if ~isempty(handles.pointstomask)
        handles.mask=xor(handles.mask,handles.pointstomask);
        handles.pointstomask=[];
        handles.redrawneeded=1;
    else
        title('Select something first!');
    end
    set(gcf,'UserData',handles);
    uiresume

function invertmask(handles,flagdebug) % invert the whole mask
   if flagdebug
       disp('invertmask')
   end
    handles.mask=(handles.mask==0);
    handles.redrawneeded=1;
    set(gcf,'UserData',handles);
    uiresume;

function forgetselection(handles,flagdebug) % forget what is selected and redraw
   if flagdebug
       disp('forgetselection')
   end
    handles.pointstomask=[];
    handles.redrawneeded=1;
    set(gcf,'UserData',handles);
    uiresume;

  