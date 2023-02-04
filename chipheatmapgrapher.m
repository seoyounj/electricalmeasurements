%% setup. change variables here!!!
% we're assuming that we take a total of 288 steps for data points. But
% because matlab counts starting from 1, the number of steps should be +1
% the actual number. i tried extracting values from the actual spreadsheet
% but because of rounding it's not actually useful sad

% change the radius of the diodes here in cm
diam = 125;
radius = diam*.0001/2;

% just for file naming later down the road
type = '125um_preanneal';

% text header for items of interest
header = '125um_preanneal';

filename = '125um_preanneal.xlsx';
opts = detectImportOptions(filename);
data = readtable(filename, opts);

%% data processing

% find rows with names
names = data.diodeName;

% find rows with data values
reversevolt = data.reverseLeakage_Near_1V;
reversevolt(isnan(reversevolt))=0;
dopingconc = data.dopingConcentration;
dopingconc(isnan(dopingconc))=0;

%% graphing
fig = chipheatmap(names, reversevolt, diam);
saveas(fig,char(strcat(type, num2str(diam),'reversevoltagemap.png')))

fig = chipheatmap(names, dopingconc, diam);
saveas(fig,char(strcat(type, num2str(diam),'dopingconcmap.png')))

%% functions

function c = chipheatmap(names, var, radius)
    % assign names to different parts on the chip
    if radius == 100
        matrixX = 8;
        matrixY = 8;
    elseif radius == 125
        matrixX = 8;
        matrixY = 7; 
    elseif radius == 250
        matrixX = 8; 
        matrixY = 9;
    elseif radius == 500
        matrixX = 8;
        matrixY = 6;
    end

    valuematrix = zeros(matrixY, matrixX);

    for i = 1:size(names,1)
        if mod(names(i), matrixX)==0 %divisible by length (edge cases)
            y = names(i)/matrixX;
            if mod(floor(names(i)/matrixX), 2) == 0 %even case
                x = 1;
            else %odd case
                x = matrixX;
            end

        else
            y = floor(names(i)/matrixX)+1; %nonedge cases
            if mod(floor(names(i)/matrixX), 2) == 0 %even case
                x = mod(names(i), matrixX);
            else %odd case

                x = matrixX+1-mod(names(i), matrixX);
            end
        end

       valuematrix(y,x) = var(i);
    end
    
    c = heatmap(valuematrix);
end

