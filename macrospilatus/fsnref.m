function fsnsout = fsnref( projectname, ref, fsns )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

downloaddata(projectname,fsns); % Downloading data
datas = getsamplenamespilatus('org_',fsns,'.header'); pause off 

counter = 1;
counterempty = 0;
lastempty = 0;
for k = 1:length(datas)
   fsnsout(counter) = fsns(k);
   if(strcmp(datas(k).Title,'Empty_beam'))
       counter = counter + 1;
       fsnsout(counter) = ref;
       counterempty = 0;
       lastempty = datas(k).FSN;
   end
   if(counterempty == 5) % Break a long sequence of samples without any emptys in between
       counter = counter + 1;
       fsnsout(counter) = lastempty;
       counter = counter + 1;
       fsnsout(counter) = ref;
       counterempty = 0;
   end
   counter = counter + 1;
   counterempty = counterempty + 1;
end
end

