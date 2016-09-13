function [ x, r2 ] = fit_votes_vs_comments( model, Utl, Dtl, Ctl, varargin )

parser = inputParser;
addOptional(parser, 'logFit', false, @islogical);
addOptional(parser, 'verbose', false, @islogical);

parse(parser, varargin{:});
logFit = parser.Results.logFit;
verbose = parser.Results.verbose;

Vcum = cumsum(Utl + Dtl);
Ccum = cumsum(Ctl);
[fh_lin, x0_fh, lb, ub, paramNames] = model();

% Find the parameter.
options = optimset('Algorithm','trust-region-reflective',...
                   'MaxFunEvals', 6000,...
                   'MaxIter', 2000, ...
                   'Display', 'off');

if logFit
    fh = @(x, V) log(fh_lin(x, V) + 1);
else
    fh = fh_lin;
end;

x0 = x0_fh();

if logFit
    [x, rss] = lsqcurvefit(fh, x0, Vcum, log(Ccum+1), lb, ub, options);
else
    [x, rss] = lsqcurvefit(fh, x0, Vcum, Ccum, lb, ub, options);
end

% tss = TSS (Total Sum of Squares)
tss = sum((Ccum - mean(Ccum)).^2);
rmse = sqrt(rss / numel(Ccum));
r2 = 1 - rss/tss;

if verbose
    for i = 1:numel(paramNames)
        paramName = paramNames{i};
        paramVal = x(i);
        fprintf('%s = %f\n', paramName, paramVal);
    end

    fprintf('RSS = %.2f\n', rss);
    fprintf('TSS = %.2f\n', tss);
    fprintf('RMSE = %.2f\n', rmse);
    fprintf('R2 = %.4f\n', r2);
end;

end