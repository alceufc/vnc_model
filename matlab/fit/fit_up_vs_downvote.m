function [ params_up, params_down, r2_up, r2_down ] = fit_up_vs_downvote( U, D, varargin )
% FIT_VOTE_MODEL Fits the up-vote vs. down-vote curve using VnC.
%
%     U: array with the up-vote time-series.
%
%     D: array with the down-vote time-series.
%
%  Optional input arguments:
%     verbose: If True, will print the parameter values and fitting
%     accuracy metrics (defaults to false).
%
%     nStartVals: Some models (including VnC) have an integer parameter 
%     that corresponds to the time-tick when a submission starts receiving
%     votes. The fitting algorithm will select the value in the nStartVals
%     that minimizes the fitting error.
%
%     diffMinChange: minimum step of the optimset fitting algorithm.
%
%  Ouput arguments:
%     params_up: estimated parameters for the up-vote time-series.
%
%     params_down: estimated parameters for the down-vote time-series.
%     

% Parse optional arguments.
parser = inputParser;
addParamValue(parser, 'verbose', false, @islogical);
addParamValue(parser, 'nStartVals', 1:3:21, @isnumeric);
addParamValue(parser, 'diffMinChange', 0, @isnumeric);

parse(parser, varargin{:});
verbose = parser.Results.verbose;
nStartVals = parser.Results.nStartVals;
diffMinChange = parser.Results.diffMinChange;

model = @v_and_c;
[fh, ~, ~, lb, ub, ~, paramNames] = model();
[params_up, ~, ~, r2_up] = fit_vote_model(model, U, ...
                                          'nStartVals', nStartVals, ...
                                          'diffMinChange', diffMinChange);
                                      
% Get the shared parameters.
reactionAlphaParam = params_up(4);
reactionBetaParam = params_up(5);
nstartParam = params_up(6);

% Find the parameters
ticks = 1:numel(D);
options = optimset('Algorithm','trust-region-reflective',...
                   'Display', 'off', ...
                   'DiffMinChange', diffMinChange);
objfunc = @(x,T) fh([x(1), x(2), x(3), reactionAlphaParam, reactionBetaParam, nstartParam], T);

NonSharedParamsIdxs = [1,2,3];
% Use the up-vote fit as the starting point.
x0 = params_up(NonSharedParamsIdxs);  
% Constrain the down-vote shared parameters.
lbD = lb(NonSharedParamsIdxs); 
ubD = ub(NonSharedParamsIdxs);
[params_temp, rss_temp ] = lsqcurvefit(objfunc, x0, ticks, D, lbD, ubD, ...
                                  options);
params_down = [params_temp(1), params_temp(2), params_temp(3), reactionAlphaParam, reactionBetaParam, nstartParam];
rssD = rss_temp;
tssD = sum((D - mean(D)).^2);
r2_down = 1 - rssD/tssD;

if verbose
    fprintf('Up-vote parameters\n');
    for pos = 1:numel(paramNames)
        paramName = paramNames{pos};
        paramVal = params_up(pos);
        fprintf('\t%s = %f\n', paramName, paramVal);
    end
    
    fprintf('Down-vote parameters\n');
    for pos = 1:numel(paramNames)
        paramName = paramNames{pos};
        paramVal = params_down(pos);
        fprintf('\t%s = %f\n', paramName, paramVal);
    end
end;

end
