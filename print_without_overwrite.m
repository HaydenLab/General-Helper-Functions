% check if test.eps exist as a file in the folder
% if not, print the specified format
function print_without_overwrite(fig,filedir,filename,fileformat)
    if ~exist(fullfile(filedir,filename),'file')
%         fileformat = ['-d',filename(strfind(filename,'.')+1:end)];        
        fullfilename = fullfile(filedir,filename);
        print(fig,fullfilename,fileformat);
    end
end