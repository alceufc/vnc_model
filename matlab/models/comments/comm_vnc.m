function [fh, x0_fh, lb, ub, paramNames, modelName] = comm_vnc()

fh = @model_func;
x0_fh = @initial_param_est;
lb = [0, 0];
ub = [54, 5];
paramNames = {'a', 'b'};
modelName = 'VnC';

function [ C ] = model_func( x, V )
    a = x(1);
    b = x(2);
    
    V = V + 1;
    C = a * V .^ b;
end

function [ x0 ] = initial_param_est( )
    x0 = [1, 1];
end

end
