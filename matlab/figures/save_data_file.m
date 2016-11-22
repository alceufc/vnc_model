function [ ] = save_data_file( filePath, Data, ColumnNames, varargin )

MINUTES_IN_HOUR = 60;

parser = inputParser;
addOptional(parser, 'addTimestampCol', false, @islogical);
addParamValue(parser, 'tickLen', 20, @isnumeric);

parse(parser, varargin{:});
addTimestampCol = parser.Results.addTimestampCol;
tickLen = parser.Results.tickLen;

if addTimestampCol
    T = 1:size(Data, 1);
    Thour = T * tickLen / MINUTES_IN_HOUR;
    Data = [Data, Thour'];
    ColumnNames = [ColumnNames, 'Time'];
end;

formatSpec = '';
for col = 1:numel(ColumnNames)
    formatSpec = [formatSpec, '%.3f'];
    if col < numel(ColumnNames)
        formatSpec = [formatSpec, ' '];
    else
        formatSpec = [formatSpec, '\n'];
    end;
end;

fileID = fopen(filePath, 'w');
fprintf(fileID, '%s\n', strjoin(ColumnNames));
fprintf(fileID, formatSpec, Data');
fclose(fileID);

end