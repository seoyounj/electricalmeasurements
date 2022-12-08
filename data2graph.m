%% setup. change variables here!!!
% we're assuming that we take a total of 288 steps for data points. But
% because matlab counts starting from 1, the number of steps should be +1
% the actual number. i tried extracting values from the actual spreadsheet
% but because of rounding it's not actually useful sad

% change the radius of the diodes here in cm
radius = 0.0250/2;

% just for file naming later down the road
type = 'preanneal';

% cutoff for diode measurements of interest. in cm^2
limit = 10^-5;

filename = 'Pre_anneal_250um_IV_52-63_diode.xlsx';
opts = detectImportOptions(filename);
data = readtable(filename, opts);

%% data processing

data.Properties.VariableNames{1} = 'Var1';
data.Properties.VariableNames{2} = 'Var2';
data.Properties.VariableNames{3} = 'Var3';
data.Properties.VariableNames{4} = 'Var4';

% find rows with names
namerows = strcmp(data.Var2, 'TestRecord.Remarks');
names = data.Var3(namerows);

% find rows with step values
steprows = strcmp(data.Var1, 'Dimension1');
steps = double(string((cell2mat(data.Var2(steprows)))));

% find rows with data values
datarows = strcmp(data.Var1, 'DataValue');
voltagecell = data.Var2(datarows);
voltage = str2double(voltagecell);

currentcell = data.Var3(datarows);
current = str2double(currentcell);

%%
%data storage; name, voltage vector, current vector
datacell = cell(size(names,1), 4);
s = size(names,1);
count = 1;
for c = 1:s
    datacell(c,1)={names(c)};
    datacell(c,2)={voltage(count:count+steps(c)-1,1)};
    datacell(c,3)={current(count:count+steps(c)-1,1)};
    
    % reverse leakage current density
    datacell(c,4)={(current(count:count+steps(c)-1,1))./(pi()*radius^2)};
    
    if c~=s
        count = count + steps(c);
    end
end

%% calculations and outputs
%for loop in which we graph every I-V curve with its name, then find
%reverse leakage current density at -0.9931 V. Find any reverse leakage
%currents that are below set limit 
filename = strcat(type, string(radius),'b.xlsx');
values = cell(size(names,1),3);
values(1,1:3) = {'diode name', 'reverse leakage @ near -1V', 'below limit?'};
    
for c = 1:s    
    % graphing
    voltageplaceholder = cell2mat(datacell(c,2));
    currentplaceholder = cell2mat(datacell(c,3));
    currentdensityplaceholder = cell2mat(datacell(c,4));
    
%     f = plot(voltageplaceholder, currentplaceholder);
%     title('I-V measurement curves');
%     xlabel('voltage (V)');
%     ylabel('current (Amps)');
%     
%     if isempty(char(names(c)))
%         saveas(gcf,'placeholder.png');
%     else
%     saveas(gcf,char(strcat(names(c),'.png')));
%     end
    
    % find reverse leakage current density (rlcd) at voltage nearest to -1V
    % and write to spreadsheet
    [val,index]=min(abs(voltageplaceholder--1));
    
    if val == 1
        rlcd = 1;
    else
        rlcd = currentdensityplaceholder(index);
    end
    
    values(c+1,1) = names(c);
    values(c+1,2)= {rlcd};
    values(c+1,3) = {abs(rlcd) <= limit};
    
    writecell(values,filename,'Sheet',1,'Range','A1');
end
