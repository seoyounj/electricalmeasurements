%% The point of this program is to a) graph every IV curve and b) output a file with reverse leakage currents.
%% setup. change variables here!!!
% 

% change the filename that you want to read from. this should be an excel
% file
filenamein = 'I_V Sweep Pre_Anneal_(010)_PLD';

% change if you want this program to graph every IV curve in the given
% excel file. this slows the program down and makes a bunch of files
% usually so I only run the program with this once. You may want to turn
% this off for subsequent runs
graphingon = false; %true or false, if you're not familiar with matlab

% change if you want to calculate the reverse leakage currents or not. This
% is really only relevant for Schottky diodes. If you want to calculate
% reverse leakage current then the next variable (radius) is also needed.
rlcd = false; 
% change the radius of the diodes here in cm
radius = 0.0125/2;
% if finding reverse leakage current, this can be a limit number that will
% create a column that is true or false depending on if the calculated
% reverse leakage current is lower than the given limit number
limit = 10^-5;

%% Takes file exported from EasyExpert and stores values for processing.
numVars = 4;
varNames = {'Var1','Var2','Var3','Var4'};
varTypes = {'char','char','char','char'} ;
opts = spreadsheetImportOptions('NumVariables',numVars,'VariableNames',varNames,'VariableTypes',varTypes);
  
data = readtable(filenamein, opts);

% find rows with names
namerows = strcmp(data.Var2, 'TestRecord.Remarks');
names = data.Var3(namerows);

% find rows with step values
steprows = strcmp(data.Var1, 'Dimension1');
steps = double(string((cell2mat(data.Var2(steprows)))));

% find rows with data values
datarows = strcmp(data.Var1, 'DataValue');

voltagecell = data.Var2(datarows); % find from the data rows the voltage value rows
voltageplaceholder = voltagecell;
if iscell(voltagecell) == 1 
    voltageplaceholder = str2double(voltagecell);
end

currentcell = data.Var3(datarows); % find from the data rows the current value rows
currentplaceholder = currentcell;
if iscell(currentcell) == 1
    currentplaceholder = str2double(currentcell);
end

%% processing the read data into a more readable file
% data storage; name, voltage vector, current vector, and reverse leakage
% current density if appropriate

if rlcd
    datacellsize = 4;
else
    datacellsize = 3;
end

datacell = cell(size(names,1), datacellsize);
s = size(names,1);
count = 1;

for c = 1:s
    datacell(c,1)={names(c)};
    datacell(c,2)={voltageplaceholder(count:count+steps(c)-1,1)};
    datacell(c,3)={currentplaceholder(count:count+steps(c)-1,1)};
    
    % reverse leakage current density
    if rlcd
        datacell(c,4)={(currentplaceholder(count:count+steps(c)-1,1))./(pi()*radius^2)};
    end
    
    if c~=s
        count = count + steps(c);
    end
end

%% calculations and outputs
% for loop in which we graph every I-V curve with its name, then find
% reverse leakage current density at value closest to -1 V. Find any reverse
% leakage currents that are below set limit
filename = strrep(filenamein, '.xlsx','');
values = cell(size(names,1),3);
values(1,1:3) = {'diode name', 'reverse leakage @ near -1V', 'below limit?'};
    
for c = 1:s    
    
    voltage = cell2mat(datacell(c,2));
    current = cell2mat(datacell(c,3));
    
    if rlcd
        currentdensityplaceholder = cell2mat(datacell(c,4));
    end
    
    % graphing
    if graphingon
        f = grapher(names(c), voltage, current);
    end
    
    % find reverse leakage current density (rlcd) at voltage nearest to -1V
    % and write to spreadsheet
    if rlcd
        if contains(names(c), '_R_') % this tries to catch only reverse current measurements if the naming scheme has it. otherwise ignore
            r = rlcdcalc(names(c), voltage, currentdensityplaceholder);
            values(c+1,1) = {str2double(cell2mat(extractAfter(names(c), '_R_')))};
    %         values(c+1,1) = names(c);
            values(c+1,2)= {r};
            values(c+1,3) = {abs(r) <= limit};
        end
        
        writecell(values,strcat(strrep(filenamein, '.xlsx',''),'_reverseleakage.xlsx'),'Sheet',1,'Range','A1');
    end
    
    T = table(voltage, current);
    filenameout = strcat(char(names(c)), '_IVdata.xlsx');
    writetable(T, filenameout,'Sheet',1,'Range','A1', 'WriteRowNames',true);
    
end

function g = grapher(name, voltage, current)
    g = plot(voltage, current);
    title('I-V measurement curves');
    xlabel('voltage (V)');
    ylabel('current (Amps)');
    
    if isempty(char(name))
        saveas(gcf,'placeholder.png');
    else
    saveas(gcf,char(strcat(name,'.png')));
    end
end

function r = rlcdcalc(name, voltage, reversecurrentdata)

%first take out all values that are forward voltage; this depends on the
%comment having '_R_' in it but this can be changed to be more context
%relevant.
    if contains(name, '_R_')
        [~,index]=min(abs(voltage--1));
        r = reversecurrentdata(index);
    end

end
