function [fh_lin, fh_log, x0_fh, lb, ub, typicalX, paramNames, modelName, shiftFit ] = si_model()
fh_lin = @model_func;
fh_log = @(x, Y) log10(fh_lin(x, Y) + 1);
x0_fh = @initial_param_est;
lb = [0, -inf, -inf];
ub = [inf, inf, inf];
typicalX = [1, 1, 1];

shiftFit = false;

paramNames = {'N', 'logBeta', 'log10v0'};
modelName = 'SI';
paramFactors = [1e3, 1, 1];

function [ U ] = model_func( x, T )
    N = x(1) * paramFactors(1);
    beta = 10^x(2) * paramFactors(2);
    v0 = 10^x(3) * paramFactors(3);

    U = zeros(numel(T),1);
    for i = 1:numel(T)
        n = T(i);
        if n == 1
            % Initial conditions.
            U(n) = v0;
        else
            V = sum(U(1:n-1));
            if V > N
                V = N;
            end
            U(n) = (N - V)*V*beta;
        end;
    end;
end

function [ x0 ] = initial_param_est( vol )
    x0 = [(vol+1)/paramFactors(1), -4, -1];
end
end