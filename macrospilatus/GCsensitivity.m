function [sens,errorsens] = GCsensitivity(fsns,samplename,thickness,mask,energymeas,energycalib,pri)

sens = ones(619,487);
errorsens = zeros(size(sens));
B1normintallpilatus([fsns],thickness,sens,errorsens,mask,energymeas,energycalib,0,pri,0,0);

As = sens; Aerrs2 = sens;

counter=0;
for i=1:length(fsns)
    tmp=readlogfilepilatus(sprintf('intnorm%d.log',fsns(i)));
    if isstruct(tmp)
        if(tmp.Dist == sddistance & strcmp(tmp.Title,samplename)) % Added restriction that only one distance is loaded, UV 16.7.2009
           counter=counter+1;
           params(counter)=tmp;
           [A,Aerr]=read2dintfilepilatus(params(i).FSN);
           As = As + A;
           Aerrs2 = Aerrs2 + Aerr.^2;
        end;
    end
end
Aerrs = sqrt(Aerrs2);


% Make mask for areas that are not included in the sensitivity
As = (1-mask).*As;

cor = imageint(As,[orix oriy],mask);
plot(cor);
ylabel('Intensity');
xlabel('Pixels');
title(sprintf('%s',samplename));
pause

ss = size(A);
for(k = 1:ss(1))
    for(l = 1:ss(2))
        C(k,l) = As(k,l)*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
        Cerr(k,l) = Aerrs(k,l)*cor(1+round(sqrt((k-orix)^2+(l-oriy)^2)));
    end;
end;

cc = imageint(C,[orix oriy],mask);
plot(cc);
title('This should be flat');
pause

sens = C/mean(cc(70:120)); % Normalising to 1
errorsens = Cerr/mean(cc(70:120));
% Taking care of zeros
for(k = 1:ssA(1))
    for(l = 1:ssA(2))
        if(sens(k,l)==0)
            sens(k,l) = 1;
            errorsens(k,l) = 0;
        end;
    end;
end;

imagesc(sens);colorbar
title('Final sensitivity')
axis equal

