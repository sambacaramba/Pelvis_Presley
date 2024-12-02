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

pos = strfind(folders(KK).name,'\');
fname = folders(KK).name((max(pos)+1:end));

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
                norm([markedPoints(1, :) - markedPoints(5, :)]); % 1 to 7, INL hip bone length
                norm([markedPoints(3, :) - markedPoints(4, :)]); % 5 to 6, SPL symphysis length
                norm([markedPoints(3, :) - markedPoints(6, :)]); % 5 to 8, APL
                norm([markedPoints(2, :) - markedPoints(3, :)]); % 4 to 5
                norm([markedPoints(4, :) - markedPoints(5, :)]); % 6 to 7, IPL
                norm([markedPoints(5, :) - markedPoints(6, :)]); % 8 to 7, AIL
                norm([markedPoints(5, :) - markedPoints(9, :)]); % 11 to 7, ISW
                norm([markedPoints(7, :) - markedPoints(8, :)]); % 9 to 10, obturator foramen length
                norm([markedPoints(5, :) - markedPoints(11, :)]); % 13 to 7, TTT, iscial tuberosity to iscial tuberosity
                norm([markedPoints(8, :) - markedPoints(10, :)]); % 12 to 10, FTF, foramen to foramen
            ]';

distances_um = distances*voxelsize;

results(KK).sample = fname
results(KK).INL = distances_um(1)
results(KK).SPL = distances_um(2)
results(KK).APL = distances_um(3)
results(KK).two2three = distances_um(4)
results(KK).IPL = distances_um(5)
results(KK).AIL = distances_um(6)
results(KK).ISW = distances_um(7)
results(KK).OFL = distances_um(8)
results(KK).IT2IT = distances_um(9)
results(KK).OF2OF = distances_um(10)

end
save([savepath 'Results.mat'],"results");
resultsTable = struct2table(results);
currentTimestamp = datestr(now, 'yymmdd_HHMM');
savename = ['Results_' currentTimestamp '.xlsx'];
writetable(resultsTable, [savepath savename]);

disp(['Analysis finished, resuls are saved to: ', savepath]);
