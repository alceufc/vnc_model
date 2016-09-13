function [ params, rss, res, r2 ] = fit_vote_model( model, U, varargin )
% FIT_VOTE_MODEL Fit an up-vote or down-vote time-series.
%
%  Input arguments:
%     model: function handle to a model function. For example, pass 
%     @v_and_c to fit the VnC model.
%
%     U: array with the up-vote time-series.
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
%     params: estimated parameters.
%     

% Parse optional arguments.
parser = inputParser;
addParamValue(parser, 'verbose', false, @islogical);
addParamValue(parser, 'nStartVals', 1:3:50, @isnumeric);
addParamValue(parser, 'diffMinChange', 0, @isnumeric);

parse(parser, varargin{:});
verbose = parser.Results.verbose;
nStartVals = parser.Results.nStartVals;
diffMinChange = parser.Results.diffMinChange;

[fh, ~, x0_fh, lb, ub, ~, paramNames, ~, shiftFit] = model();
% Set the initial N parameter as the timeline volume.
vol = sum(U);
x0_mat = x0_fh(vol);

% Find the parameters
xdata = 1:numel(U);
options = optimset('Algorithm','trust-region-reflective',...
                   'Display', 'off', ...
                   'DiffMinChange', diffMinChange);

if shiftFit
    nStartVals = nStartVals(nStartVals < numel(U));
    for idxStartVal = 1:numel(nStartVals);
        nstart = nStartVals(idxStartVal);
        
        for idxX0 = 1:size(x0_mat, 1)
            x0 = x0_mat(idxX0, :);
            [x_temp, rss_temp, res_temp] = lsqcurvefit(@(x,T) fh([x, nstart], T), ...
                                                       x0(1:end-1), ...
                                                       xdata, ...
                                                       U, ...
                                                       lb(1:end-1), ...
                                                       ub(1:end-1), ...
                                                       options);

            if (idxX0 == 1 && idxStartVal == 1)  || (rss_temp < rss)
                params = [x_temp, nstart];
                rss = rss_temp;
                res = res_temp;
            end;
        end;
    end;
else
    for idxX0 = 1:size(x0_mat, 1)
        x0 = x0_mat(idxX0, :);
        [x_temp, rss_temp, res_temp] = lsqcurvefit(fh, x0, xdata, U, lb, ub, options);

        if idxX0 == 1 || rss_temp < rss
            params = x_temp;
            rss = rss_temp;
            res = res_temp;
        end;
    end;
end;

% tss = TSS (Total Sum of Squares)
tss = sum((U - mean(U)).^2);
rmse = sqrt(rss / numel(U));
r2 = 1 - rss/tss;

if verbose
    for i = 1:numel(paramNames)
        paramName = paramNames{i};
        paramVal = params(i);
        fprintf('%s = %f\n', paramName, paramVal);
    end
    fprintf('RSS = %.2f\n', rss);
    fprintf('TSS = %.2f\n', tss);
    fprintf('RMSE = %.2f\n', rmse);
    fprintf('R2 = %.4f\n', r2);
end;

end
