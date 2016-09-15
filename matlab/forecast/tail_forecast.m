function [ Uforecast, params ] = tail_forecast( Utrain, model, forecastSize, varargin )
% TAIL_FORECAST Votes time-series forecast.
%
%  Input arguments:
%     U: array with the up-vote time-series that will be used to train the 
%     model.
%
%     model: function handle to a model function. 
%
%     forecastSize: number of time-ticks of the output (forecasted)
%     time-series: numel(Uforecast) = forecastSize.
%
%  Optional input arguments:
%     nStartVals: Some models (including VnC) have an integer parameter 
%     that corresponds to the time-tick when a submission starts receiving
%     votes. The fitting algorithm will select the value in the nStartVals
%     that minimizes the fitting error.
%
%     diffMinChange: minimum step of the optimset fitting algorithm.
%
%  Output arguments:
%     Uforecast: forecasted time-series.
%
%     params: estimated parameters for the forecasted time-series.

parser = inputParser;
addParamValue(parser, 'diffMinChange', 0, @isnumeric);
addParamValue(parser, 'nStartVals', 1:5:30, @isnumeric);

parse(parser, varargin{:});
diffMinChange = parser.Results.diffMinChange;
nStartVals = parser.Results.nStartVals;


params = fit_vote_model(model, Utrain, ...
                        'nStartVals', nStartVals, ...
                        'diffMinChange', diffMinChange);
fh = model();
Uforecast = fh(params, 1:forecastSize);

end