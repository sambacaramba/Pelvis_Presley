%Script for analysing pelvic landmark distances from µCT data.

clear all 
close all 

voxelsize = 51.423000;
folders = uipickfiles('FilterSpec','C:\','Output','struct','Prompt', 'Choose folders for analysis')

savepath = fileparts(folders(1).name);
savepath = [savepath '\3Dresults\'];

A = exist(savepath);
if A == 0
mkdir(savepath);
else 
end  


% Randomize order of files
size_folders = length(folders);
p = randperm(size_folders);

for i = 1:size_folders
    folders(i).rndnum = p(i);
end

results = struct();
for KK = 1:length(folders)
     

    
    rndnum = folders(KK).rndnum;
    fname = folders(rndnum).name ;

selpath = (folders(rndnum).name);

binning = 0;
datatype = '*.bmp'
flipH = 0; 
%Load volume using volumeloader
[vol, ~, real_size_XY] = Universal_volumeloader_0234(selpath,binning,KK,length(folders),datatype,flipH);

pos = strfind( fname,'\');
fname =  fname((max(pos)+1:end));

vol = flip(vol, 3);

[xs ys zs] = size(vol);


filename = [fname '.png'];

vol = double(vol);
thresholds = multithresh(vol(:), 2);
Thresh=thresholds(2);

vol = imbinarize(vol,Thresh);
vol =  CleanVolume3D(vol);


clear markedPoints distances
global markedPoints
markedPoints = MarkPoints3D(vol,savepath, filename);

distances = NaN(1,13);
   distances = [
                norm([markedPoints(1, :) - markedPoints(5, :)]); % 1 to 5, INL hip bone length
                norm([markedPoints(3, :) - markedPoints(4, :)]); % 3 to 4, SPL symphysis length
                norm([markedPoints(3, :) - markedPoints(6, :)]); % 3 to 6, APL
                norm([markedPoints(2, :) - markedPoints(3, :)]); % 2 to 3
                norm([markedPoints(4, :) - markedPoints(5, :)]); % 4 to 5, IPL
                norm([markedPoints(5, :) - markedPoints(6, :)]); % 5 to 6, AIL
                norm([markedPoints(5, :) - markedPoints(9, :)]); % 5 to 9, ISW
                norm([markedPoints(7, :) - markedPoints(8, :)]); % 7 to 8, obturator foramen length
                norm([markedPoints(5, :) - markedPoints(11, :)]); % 5 to 11, IT2IT, iscial tuberosity to iscial tuberosity
                norm([markedPoints(8, :) - markedPoints(10, :)]); % 8 to 10, OF2OF, foramen to foramen
            ]';

distances_um = distances*voxelsize;

results(KK).sample = fname
results(KK).INL_1to5 = distances_um(1)
results(KK).SPL_3to4 = distances_um(2)
results(KK).APL_3to6 = distances_um(3)
results(KK).dist2to3 = distances_um(4)
results(KK).IPL_4to5 = distances_um(5)
results(KK).AIL_5to6 = distances_um(6)
results(KK).ISW_5to9 = distances_um(7)
results(KK).OFL_7to8 = distances_um(8)
results(KK).IT2IT_5to11 = distances_um(9)
results(KK).OF2OF_8to10 = distances_um(10)

end
save([savepath 'Results.mat'],"results");
resultsTable = struct2table(results);
currentTimestamp = datestr(now, 'yymmdd_HHMM');
savename = ['Results_' currentTimestamp '.xlsx'];
writetable(resultsTable, [savepath savename]);

disp(['Analysis finished, resuls are saved to: ', savepath]);
