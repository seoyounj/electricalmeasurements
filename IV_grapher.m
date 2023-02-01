%% The point of this program is to a) graph every IV curve and b) output a file with reverse leakage currents.
%% setup. change variables here!!!
% 

% change the radius of the diodes here in cm
radius = 0.0100/2;

% cutoff for diode measurements of interest. in cm^2
limit = 10^-5;

filenamein = 'Book1';

%% data processing
numVars = 4;
varNames = {'Var1','Var2','Var3','Var4'};
varTypes = {'char','char','char','char'} ;

opts = spreadsheetImportOptions('NumVariables',numVars,'VariableNames',varNames,'VariableTypes',varTypes);
                            
% opts = detectImportOptions(filenamein);
data = readtable(filenamein, opts);

% find rows with names
namerows = strcmp(data.Var2, 'TestRecord.Remarks');
names = data.Var3(namerows);

% find rows with step values
steprows = strcmp(data.Var1, 'Dimension1');
steps = double(string((cell2mat(data.Var2(steprows)))));

% find rows with data values
datarows = strcmp(data.Var1, 'DataValue');

voltagecell = data.Var2(datarows);
voltage = voltagecell;
if iscell(voltagecell) == 1 
    voltage = str2double(voltagecell);
end

currentcell = data.Var3(datarows);
current = currentcell;
if iscell(currentcell) == 1
    current = str2double(currentcell);
end

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
filename = strcat(strrep(filenamein, '.xlsx',''),'_reverseleakage.xlsx');
values = cell(size(names,1),3);
values(1,1:3) = {'diode name', 'reverse leakage @ near -1V', 'below limit?'};
    
for c = 1:s    
    
    voltageplaceholder = cell2mat(datacell(c,2));
    currentplaceholder = cell2mat(datacell(c,3));
    currentdensityplaceholder = cell2mat(datacell(c,4));
    
    % graphing
%     f = grapher(names(c), voltageplaceholder, currentplaceholder);
    
    % find reverse leakage current density (rlcd) at voltage nearest to -1V
    % and write to spreadsheet
    
    if contains(names(c), '_R_')
        r = rlcdcalc(names(c), voltageplaceholder, currentdensityplaceholder);
        values(c+1,1) = {str2double(cell2mat(extractAfter(names(c), '_R_')))};
        values(c+1,2)= {r};
        values(c+1,3) = {abs(r) <= limit};
    end
    
    writecell(values,filename,'Sheet',1,'Range','A1');
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
