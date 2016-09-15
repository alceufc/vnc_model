function [ params, r2 ] = fit_votes_vs_comments( model, U, D, C, varargin )
% FIT_VOTES_VS_COMMENTS Fits the votes vs. comments curve.
%
%     U: array with the up-vote time-series.
%
%     D: array with the down-vote time-series.
%
%     C: array with the comments time-series.
%
%  Optional input arguments:
%     verbose: If True, will print the parameter values and fitting
%     accuracy metrics (defaults to false).

parser = inputParser;
addOptional(parser, 'verbose', false, @islogical);

parse(parser, varargin{:});
verbose = parser.Results.verbose;

Vcum = cumsum(U + D);
Ccum = cumsum(C);
[fh, x0_fh, lb, ub, paramNames] = model();
x0 = x0_fh();
% Find the parameter.
options = optimset('Algorithm','trust-region-reflective',...
                   'MaxFunEvals', 6000,...
                   'MaxIter', 2000, ...
                   'Display', 'off');
[params, rss] = lsqcurvefit(fh, x0, Vcum, Ccum, lb, ub, options);

% tss = TSS (Total Sum of Squares)
tss = sum((Ccum - mean(Ccum)).^2);
rmse = sqrt(rss / numel(Ccum));
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