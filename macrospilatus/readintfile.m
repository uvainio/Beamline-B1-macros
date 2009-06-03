function int1 = readintfile(filename)

% function int1 = readintfile(filename)
%
%
% Created: 17.9.2007 UV

fid = fopen(filename,'r');
if(fid == -1)
%  disp(sprintf('Could not find file %s.',filename))
  int1 = 0;
  return
else
   temp = fscanf(fid,'%e %e %e\n',[3,inf]);
   fclose(fid);
   int1 = struct('q',temp(1,:)','Intensity',temp(2,:)','Error',temp(3,:)');
end;
