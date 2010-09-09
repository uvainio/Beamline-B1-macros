function mask = maskgaps(dettype)

%function mask = maskgaps(dettype)
%
% dettype = '300k' or '1M'
%
% Created 9.7.2010 Ulla Vainio

if(strcmp(dettype,'300k'))
    mask = ones(619,487);
    
    mask(1:end,1) = 0; % Edges of the detector
    mask(1:end,end) = 0;
    mask(1,1:end) = 0;
    mask(end,1:end) = 0;
    
    mask(195:213,:) = 0;
    mask(407:425,:) = 0;  
    
end;

if(strcmp(dettype,'1M'))
    mask = ones([1043,981]);
    
    mask(1:end,1) = 0; % Edges of the detector
    mask(1:end,end) = 0;
    mask(1,1:end) = 0;
    mask(end,1:end) = 0;
    
    mask(195:213,:) = 0; % Horizontal edges of the modules
    mask(407:425,:) = 0;  
    mask(619:636,:) = 0;  
    mask(831:848,:) = 0;  

    % Vertical edge in the middle
    mask(:,486:495) = 0;
    
end;