function [remainingTime] = timeEst( timeMeasured, numOfOperationsLeft,varargin )
% Gets a measured time and adds it to a set of already measured times
% Returns a string that estimates how long the program will need to finish

%Options
sizeTimeArray=10;

if nargin>2
    %varargin is used
    for i=1:2:length(varargin)
        %go through varargin which is build in pairs and assign variable
        %stored in the first entry with the value stored in the second
        %entry.
        if isnumeric(varargin{i+1})
            %Value is a number -> for 'eval' a string is needed, so convert
            %num2str
            eval([varargin{i} '=' num2str(varargin{i+1}) ';']);
        else
            %Value is a string, can be used as expected
            stringVar=varargin{i+1};
            eval([varargin{i} '= stringVar;']);
            clear stringVar
        end
    end
end

% get array with saved times
persistent MeasuredTimes;

% if the array is empty or no input argument was given the array is set to
% zeros
if nargin==0||isempty(MeasuredTimes)
    MeasuredTimes=zeros(sizeTimeArray,1);
    % if there is no input, MeasuredTimes is supposed to be reset
    if nargin==0
        %Mind that when resetting timeEst it will automatically use 
        % sizeTimeArray=10;
        remainingTime=0;
        return
    end
end

%create an array A for shifting the values in 'MeasuredTimes'
A=zeros(sizeTimeArray);
A(2:end,1:end-1)=eye(sizeTimeArray-1);

%Shift the values
MeasuredTimes=A*MeasuredTimes;

%Save the new measurement
MeasuredTimes(1,1)=timeMeasured;

%Calculate mean of saved times
meanTime=mean(MeasuredTimes);

%multiply the number of operations left with the mean time to get the
%remaining time
restTime=meanTime*numOfOperationsLeft;

%Change the format of the remaining time to a string and return the string
remainingTime=datestr(restTime/86400, 'HH:MM:SS');
end