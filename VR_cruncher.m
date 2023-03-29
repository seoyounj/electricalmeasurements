%% setup. change variables here!!!

% change the filename that you want to read from. this should be an excel
% file
filenamein = 'I_V Sweep Pre_Anneal_(010)_PLD_9-14';
% number of sets of data
sets = [9,10,11,12,13,14];
% number of different distances
dvals = [10,20,30,40,50,60];
distances = length(dvals);

%% import file
numVars = 4;
varNames = {'Var1','Var2','Var3','Var4', 'Var5'};
varTypes = {'char','char','char','char', 'char'} ;
opts = spreadsheetImportOptions('NumVariables',numVars,'VariableNames',...
    varNames,'VariableTypes',varTypes);
  
data = readtable(filenamein, opts);

% find rows with names
namerows = strcmp(data.Var2, 'TestRecord.Remarks');
names = data.Var3(namerows);

index = cellfun(@isempty, names); %replace empty values
names(index) = {'placeholder'}; % all of the empty values will be named placeholder. delete these

% find rows with step values
steprows = strcmp(data.Var1, 'Dimension1');
steps = double(string((cell2mat(data.Var2(steprows)))));

% find rows with data values
datarows = strcmp(data.Var1, 'DataValue');

voltagecell = data.Var4(datarows); % find from the data rows the voltage value rows
voltageplaceholder = voltagecell;
if iscell(voltagecell) == 1 
    voltageplaceholder = str2double(voltagecell);
end

resistancecell = data.Var5(datarows); % find from the data rows the current value rows
resistanceplaceholder = resistancecell;
if iscell(resistancecell) == 1
    resistanceplaceholder = str2double(resistancecell);
end

%% processing the read data into a more readable file
% data storage; name, voltage vector, resistance vector
datacellsize = 3;
datacell = cell(size(names,1), datacellsize);
s = size(names,1);
count = 1;

for c = 1:s
    datacell(c,1)={names(c)};
    datacell(c,2)={voltageplaceholder(count:count+steps(c)-1,1)};
    datacell(c,3)={resistanceplaceholder(count:count+steps(c)-1,1)};
    
    if c~=s
        count = count + steps(c);
    end
end

%% find V, R values and take the specific R value at V = 0.2 
% find every V = 0.2 and the specific R value for it
resistances = zeros(size(datacell,1),1);
for c = 1:size(datacell,1)
    resistancerows = cell2mat(datacell(c,2))==.2;
    holder = cell2mat(datacell(c,3));
    resistances(c) = holder(resistancerows);
end

% sort the found values by their name to have R values by set
t = table(resistances);
t.Properties.RowNames = names;

setsmatrix = zeros(length(sets),distances);
for c = 1:length(sets)
    hasname = contains(names, ['Set',' ', int2str(sets(c))]) | ...
        contains(names, ['Set', int2str(sets(c))]);
    holder = names(hasname);
    resistanceholder = resistances(hasname);
    
    for d = 1:distances
        namefinder = contains(holder, [int2str(d), '0um']);
        setsmatrix(c,d) = resistanceholder(namefinder);
    end
end

%% Graph d vs. R
for c = 1:length(sets)
    % make the figure, fit to a linear model, graph
    r = setsmatrix(c,:);
    mdl = fitlm(dvals, r);
    f=figure
    plot(mdl)
    title(['Set ', int2str(sets(c))]);
    xlabel('Distance (um)');
    ylabel('Calculated resistance (Ohms)');
    
    % display R^2 values, mx+b = y    
    str=['R^2 = ', sprintf('%.2f',mdl.Rsquared.Ordinary),...
    ', y = ',sprintf('%.2f',table2array(mdl.Coefficients(2,1))),...
    'x + ',sprintf('%.2f',table2array(mdl.Coefficients(1,1)))];
    annotation('textbox',[.15 0.9 0 0],'string',str,'FitBoxToText','on','EdgeColor','black')   
    
    % save as png file 
    exportgraphics(gca,['Set ', int2str(sets(c)), ' distance vs. resistance chart.png'],'Resolution',300)
    close(f)
end
