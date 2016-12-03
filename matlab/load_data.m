function [ Ucell, Dcell, Ccell, Tsub, Sr, Sr_name, fnames ] = load_data( datasetName, varargin )
% LOAD_DATA Load time-series data.
%
%  Ouput arguments:
%     U, D, C: Nx1 cell arrays, where N is the number of timelines and each entry 
%     is a column vector with up-vote/down-vote/comment time-series of a link.
%
%     Tsub: Nx1 array with the creation time of the submission. The value
%     is the number of minutes after UTC midnight.
%
%     Sr: Nx1 array with the sub-reddit integer ID of a link.
%
%     Sr_name: Cell array where the i-th entry contains the name (string)
%     of the sub-reddit with ID i.
%
%     fnames: Cell array with the time-series fil-ename for each link.

parser = inputParser;
addOptional(parser, 'maxLinks', inf, @isnumeric);
addOptional(parser, 'minUpvotes', 0, @isnumeric);
addOptional(parser, 'minTicks', 100, @isnumeric);
addOptional(parser, 'loadFromMatFile', false, @islogical);

parse(parser, varargin{:});
maxLinks = parser.Results.maxLinks;
minUpvotes = parser.Results.minUpvotes;
minTicks = parser.Results.minTicks;
loadFromMatFile = parser.Results.loadFromMatFile;

settings = load_settings();
datasetPath = settings.datasets.(datasetName);

if loadFromMatFile
    fprintf('\tLoading from .mat file.\n');    
    matVars = {'U', 'D', 'C', 'Tsub', 'Sr', 'Sr_name', 'fnames'};
    matFilePath = fullfile(datasetPath, sprintf('%s.mat', datasetName));
    varStruct = load(matFilePath, matVars{:});
    Ucell = varStruct.U;
    Dcell = varStruct.D;
    Ccell = varStruct.C;
    Tsub = varStruct.Tsub;
    Sr = varStruct.Sr;
    Sr_name = varStruct.Sr_name;
    fnames = varStruct.fnames;
    
    return;
end;

% Get the list of time-series data files.
timeSeriesPath = fullfile(datasetPath, 'time_series');
dataFiles = dir(fullfile(timeSeriesPath, '*.data'));
fnamesAll = cell(numel(dataFiles), 1);
for filePos = 1:numel(dataFiles)
    fileName = dataFiles(filePos).name;
    fnamesAll{filePos} = fileName;
end

% Check how many columns we have in the data files. 
%  1 column: just up-votes.
%  3 columns: up-votes, down-votes and comments.
fileName = fnamesAll{1};
filePath = fullfile(timeSeriesPath, fileName);
fid = fopen(filePath);
fgetl(fid); % Discard the submission-time.
fgetl(fid); % Discard the sub-reddit.
dataLine = fgetl(fid);
numberOfColumns = numel(strfind(dataLine, ',')) + 1;
fclose(fid);


% Pre-allocate space for time-series data.
Ucell = cell(numel(fnamesAll), 1);
if (numberOfColumns > 1)
    fscanfString = '%f, %f, %f';
    Dcell = cell(numel(fnamesAll), 1);
    Ccell = cell(numel(fnamesAll), 1);
else
    fscanfString = '%f';
    Dcell = {};
    Ccell = {};
end;
fnames = cell(numel(fnamesAll), 1);
Tsub = zeros(numel(fnamesAll), 1);
Sr_raw = cell(numel(fnamesAll), 1);

% Store the data from the submissions.
addedSubs = 0;
for idx = 1:numel(fnamesAll)
    fileName = fnamesAll{idx};
    filePath = fullfile(timeSeriesPath, fileName);

    fid = fopen(filePath);
    creationTimeStamp = str2double(fgetl(fid));
    subreddit = fgetl(fid);
    
    F_data = fscanf(fid, fscanfString, [numberOfColumns, inf]);
    F_data = F_data';
    Uts = F_data(:, 1);
    if (numberOfColumns > 1)
        Dts = F_data(:, 2);
        Cts = F_data(:, 3);
    end;
    fclose(fid);
    
    if sum(Uts) >= minUpvotes && numel(Uts) >= minTicks
        addedSubs = addedSubs + 1;
        Ucell{addedSubs} = Uts;
        if (numberOfColumns > 1)
            Dcell{addedSubs} = Dts;
            Ccell{addedSubs} = Cts;
        end;
        fnames{addedSubs} = fileName;
        Sr_raw{addedSubs} = subreddit;
        Tsub(addedSubs) = creationTimeStamp;
        
        if addedSubs >= maxLinks
            break;
        end;
    end;
end;
Ucell = Ucell(1:addedSubs);
if (numberOfColumns > 1)
    Dcell = Dcell(1:addedSubs);
    Ccell = Ccell(1:addedSubs);
end;
fnames = fnames(1:addedSubs);
Sr_raw = Sr_raw(1:addedSubs);
Tsub = Tsub(1:addedSubs);

% Pre-processing required by datasets.
switch datasetName
case 'reddit'
    % Tsub is in EST (US East Coast time zone). 
    % Fix EST to UTC:
    Tsub = Tsub + 5*60;
    Tsub(Tsub > 24*60) = Tsub(Tsub > 24*60) - 24*60;
case 'digg'
    timeTickLen = 20; % min.
    for subPos = 1:numel(Ucell)
        Ucell{subPos} = timeTickLen .* Ucell{subPos};
    end;
    
end;

% Generate Sr and Sr_name.
map = containers.Map('KeyType', 'char', 'ValueType', 'int32');
keyCount = 1;
Sr = zeros(addedSubs, 1);
Sr_name = cell(addedSubs, 1);
for idx = 1:numel(Sr_raw)
    subreddit = Sr_raw{idx};
    if ~isKey(map, subreddit)
        map(subreddit) = keyCount;
        Sr_name{keyCount} = subreddit;
        keyCount = keyCount + 1;
    end;

    Sr(idx) = map(subreddit);
end;
Sr_name = Sr_name(1:keyCount - 1);


end