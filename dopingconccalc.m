%% setup. change variables here!!!

% change the radius of the diodes here in cm
radius = 0.0500/2;

% just for file naming later down the road
type = 'preanneal';


filenamein = 'pre_anneal_500um_C-V.xlsx';
opts = detectImportOptions(filenamein);
opts = setvartype(opts, 'string');  %or 'char' if you prefer
data = readtable(filenamein, opts);

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

capacitancecell = data.Var3(datarows);
capacitance = str2double(capacitancecell);

%%
%data storage; name, voltage vector, capacitance vector
datacell = cell(size(names,1), 3);
s = size(names,1);
count = 1;
for c = 1:s
    datacell(c,1)={names(c)};
    datacell(c,2)={voltage(count:count+31-1,1)};
    datacell(c,3)={capacitance(count:count+31-1,1)};
    
    if c~=s
        count = count + steps(c);
    end
end

%% calculations and outputs
%output file name
filename = strcat(strrep(filenamein, '.xlsx',''),'_dopingconcentrations.xlsx');
values = cell(size(names,1),2);
values(1,1:2) = {'diode name', 'doping concentration'};


%for loop where we find the doping concentration of each C-V curve.
for c = 1:s    
    % graphing
    voltageplaceholder = cell2mat(datacell(c,2));
    capacitanceplaceholder = cell2mat(datacell(c,3));
    
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
    
    % Calc doping concentration and write to spreadsheet
    values(c+1,1) = {names(c)};
    values(c+1,2)= {dopingconc(voltageplaceholder, capacitanceplaceholder, radius)};
    
    writecell(values,filename,'Sheet',1,'Range','A1');
end


function doping = dopingconc(voltage, capacitance, r)
    p = polyfit(voltage, 1./((capacitance).^2), 1);
    
%     csquared = 1./(capacitance.^2);
%     b = voltage\csquared
    
    % constants
    q = 1.6*10^(-19);
    es = 10;
    eo = 8.85*10^(-14);
    A = pi*r^2;
    
    doping = (1/p(1))*(2/(q*A^2*es*eo));
end

