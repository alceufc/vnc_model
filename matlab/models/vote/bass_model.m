function [fh_lin, fh_log, x0_fh, lb, ub, typicalX, paramNames, modelName, shiftFit ] = bass_model()
fh_lin = @model_func;
fh_log = @(x, Y) log10(fh_lin(x, Y) + 1);
x0_fh = @initial_param_est;
lb = [0, 0, 0];
ub = [inf, inf, inf];
typicalX = [1, 1, 1];

shiftFit = false;

paramNames = {'N', 'p', 'q'};
modelName = 'Bass';

Nfactor = 1e6;
function [ U ] = model_func( x, T )
    N = x(1);
    bassP = x(2);
    bassQ = x(3);

    U = zeros(numel(T),1);
    NN = N*Nfactor;

    for i = 1:numel(T)
        n = T(i);
        if n == 1
            % Initial conditions.
            U(n) = 0;
        else
            V = sum(U(1:n-1));
            if V > NN
                V = NN;
            end
            U(n) = (NN - V)*V/NN*bassQ + bassP*(NN-V);
        end;
    end;
end

function [ x0 ] = initial_param_est( vol )
    x0 = [(vol + 1)/Nfactor, 0.01, 0.2];
end
end