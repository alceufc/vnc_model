function [ hForecast, hDataTrain, hDataTail, hLeg ] = plot_tail_forecast(model, U, Uforecast, trainSize, varargin )
% PLOT_TAIL_FORECAST Comapares the forecast to the actual data.
%
%  Input arguments:
%     model: function handle to a model function. Use the same model 
%     function that was used with TAIL_FORECAST.
%
%     U: array with the up-vote time-series (data).
%
%     Uforecast: array with the forecasted up-vote time-series. Use
%     TAIL_FORECAST to obtain Uforecast.
%
%     trainSize: number of time-ticks that was used to train the model when
%     forecasting.
%
%  Optional input arguments:
%     tickLen: number of minutes between two time ticks (defaults to
%     20 min).
%
%     timeTicksToForecast: determines how many time-ticks will be
%     forecasted. By default, PLOT_TAIL_FORECAST shows the forecast for
%     trainSize time-ticks.
%

MINUTES_IN_HOUR = 60;

% Parse optional arguments.
parser = inputParser;
addParamValue(parser, 'timeTicksToForecast', -1, @isnumeric);
addParamValue(parser, 'plotBeforeCutoff', false, @islogical);
addParamValue(parser, 'showLegend', true, @islogical);
addParamValue(parser, 'yLogScale', true, @islogical);
addParamValue(parser, 'tickLen', 20, @isnumeric);

parse(parser, varargin{:});
timeTicksToForecast = parser.Results.timeTicksToForecast;
plotBeforeCutoff = parser.Results.plotBeforeCutoff;
showLegend = parser.Results.showLegend;
yLogScale = parser.Results.yLogScale;
tickLen = parser.Results.tickLen;

if timeTicksToForecast <= 0
    % By default, forecast the same number of time-ticks that was used to
    % train.
    timeTicksToForecast = trainSize;
end;

if yLogScale
    U(U <= 0) = 1;
    Uforecast(Uforecast <= 0) = 1;
end;

T = 1:numel(U);
Thours = T * tickLen / MINUTES_IN_HOUR;
cutoffHours = trainSize * tickLen / MINUTES_IN_HOUR;    

% Plot the training part of the data.
hDataTrain = plot(Thours(1:trainSize), U(1:trainSize), '-k');
hold on;

% Plot the tail part of the data.
Utail = U(trainSize+1:end);
tailDataColor = [.5 .5 .5];
hDataTail = plot(Thours(trainSize+1:end), Utail, '-o',...
                 'Color', tailDataColor, ...
                 'MarkerSize', 3, ...
                 'MarkerEdgeColor', 'none', ...
                 'MarkerFaceColor', tailDataColor);

[~, ~, ~, ~, ~, ~, ~, modelName] = model();

if plotBeforeCutoff
    plot(Thours(1:trainSize), Uforecast(1:trainSize), '-b', ...
         'LineWidth', 1.0);
end;
forecastTailLen = min(numel(Thours), numel(Uforecast));
hForecast = plot(Thours(trainSize+1:forecastTailLen), ...
                 Uforecast(trainSize+1:forecastTailLen), ...
                 '-b', 'LineWidth', 1.3);
ylims = ylim;
line([cutoffHours, cutoffHours], [1, ylims(2)], ...
     'LineStyle', '--', 'Color', 'k'); 
hold off;

if yLogScale
    set(gca,'YScale','log');
end;

set(gca, 'Ylim', [1, ylims(2)]);

xMinTicks = 1;
xMaxTicks = trainSize + timeTicksToForecast;

xMinHours = xMinTicks * 20 / 60;
xMaxHours = xMaxTicks * 20 / 60;
set(gca, 'Xlim', [xMinHours, xMaxHours]);

ylabel('Up-votes');
xlabel('Time (h)');
    
if showLegend
    hLeg = legend('Data', modelName);
    set(hLeg, 'Box', 'off');
    set(hLeg, 'Color', 'none');
    set(hLeg, 'Location', 'NorthWest');
end;

end
