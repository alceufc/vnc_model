function [ hFit, hData, hLeg ] = plot_vote_model_fit( model, params, U, varargin )
% PLOT_VOTE_MODE_FIT Compares the data to the fitted time-series.
%
%  Input arguments:
%     model: function handle to a model function. For example, pass 
%     @v_and_c to fit the VnC model.
%
%     U: array with the up-vote time-series (data).
%
%     params: estimated parameters. Use FIT_VOTE_MODEL to estimate
%     parameters for a model.
%
%  Optional input arguments:
%     tickLen: number of minutes between two time ticks (defaults to
%     20 min).
%


MINUTES_IN_HOUR = 60;

% Parse optional arguments.
parser = inputParser;
addParamValue(parser, 'yLabelStr', 'Votes', @isstr);
addParamValue(parser, 'tickLen', 20, @isnumeric);

parse(parser, varargin{:});
yLabelStr = parser.Results.yLabelStr;
tickLen = parser.Results.tickLen;
     
[fh, ~, ~, ~, ~, ~, ~, modelName] = model();
T = 1:numel(U);
Thour = T * tickLen / MINUTES_IN_HOUR;

% Plot data.
hData = scatter(Thour, U, ...
                'o', 'filled', ...
                'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
                'MarkerFaceColor', [0.1, 0.1, 0.1]);
set(hData, 'SizeData', 7);
hold on;

% Plot fitted curve.
Ufit = fh(params, T);
hFit = plot(Thour, Ufit, '-b', 'lineWidth', 1.2);

hLeg = legend('Data', modelName);
set(hLeg, 'Box', 'off');
set(hLeg, 'Color', 'none');

ylabel(yLabelStr);
xlabel('Time after submission (h)');

maxY = max([U; Ufit]);
set(gca, 'Ylim', [-maxY/10, maxY * 1.1]);

xMinHours = 1 * tickLen / MINUTES_IN_HOUR;
xMaxHours = numel(T) * tickLen / MINUTES_IN_HOUR;
set(gca, 'Xlim', [xMinHours, xMaxHours]);
box on;

end