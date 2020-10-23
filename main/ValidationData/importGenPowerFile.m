function generatorPower = importGenPowerFile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  PISOGENERATORPOWER = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the numeric data.
%
%  PISOGENERATORPOWER = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  pisogeneratorPower = importfile("/Users/marcusbecker/Qsync/Masterthesis/FLORIDyn/main/ValidationData/csv/00_piso_generatorPower.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 07-Oct-2020 11:07:28

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["Turbine", "Times", "Var3", "generator"];
opts.SelectedVariableNames = ["Turbine", "Times", "generator"];
opts.VariableTypes = ["double", "double", "string", "double"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "Var3", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var3", "EmptyFieldRule", "auto");

% Import the data
pisogeneratorPower = readtable(filename, opts);

%% Convert to output type
generatorPower = table2array(pisogeneratorPower);
end