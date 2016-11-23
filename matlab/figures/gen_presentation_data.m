function [] = gen_presentation_data( )
% PRESENTATION_FIGS Generates data for the presentation figures.
MINUTES_IN_HOUR = 60;
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(settings.pres_data_dir);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

if false
%-------------------------------------------------------------------------
fileName = 'data_example.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 1;
save_data_file(filePath, ...
               [Ucell{pos}, Dcell{pos}.*2, Ccell{pos}.*20], ...
               {'Up-votes', 'Down-votes', 'Comments'}, ...
               'addTimestampCol', true);

%-------------------------------------------------------------------------
fileName = 'upvotes_fit.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
fh = v_and_c();
params = fit_vote_model(@v_and_c, U);
T = 1:numel(U);
Ufit = fh(params, T);
save_data_file(filePath, ...
               [U, Ufit], ...
               {'Up-votes', 'VnC'}, ...
               'addTimestampCol', true);

%-------------------------------------------------------------------------
fileName = 'up_vs_down_fit_example.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
D = Dcell{pos};
fh = v_and_c();
[params_up, params_down] = fit_up_vs_downvote(Ucell{pos}, Dcell{pos});

T = 1:numel(U);
Ufit = fh(params_up, T);
Dfit = fh(params_down, T);

save_data_file(filePath, ...
               [cumsum(U), cumsum(D), cumsum(Ufit), cumsum(Dfit)], ...
               {'Up-data', 'Down-data', 'Up-VnC', 'Down-VnC'}, ...
               'addTimestampCol', false);

           
%-------------------------------------------------------------------------
fileName = 'votes_vs_comm_fit_example.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
D = Dcell{pos};
C = Ccell{pos};
Vcum = cumsum(U + D);
Ccum = cumsum(C);

[vnc_params] = fit_votes_vs_comments(@comm_vnc, U, D, C);
[lin_params] = fit_votes_vs_comments(@comm_lin_model, U, D, C);

fhVnc = comm_vnc();
CcumVncFit = fhVnc(vnc_params, Vcum);

fhLin = comm_lin_model();
CcumLinFit = fhLin(lin_params, Vcum);

save_data_file(filePath, ...
               [Vcum, Ccum, CcumVncFit, CcumLinFit], ...
               {'Votes', 'Data', 'VnC', 'Linear'}, ...
               'addTimestampCol', false);
end;

%-------------------------------------------------------------------------
fileName = 'tail_decay.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 3;
U = Ucell{pos};
T = 1:numel(U);
modelList = {@v_and_c, @bass_model, @si_model, @spike_m};
modelNames = {'VnC', 'Bass', 'SI', 'Spike-M'};

Data = zeros(numel(U), 1 + numel(modelList));
Data(:, 1) = U;
for modelPos = 1:numel(modelList)
    model = modelList{modelPos};
    fh = model();
    params = fit_vote_model(model, U);
    Ufit = fh(params, T);
    Data(:, modelPos + 1) = Ufit;
end;

save_data_file(filePath, Data, ...
               ['Data', modelNames], ...
               'addTimestampCol', true);
end;
           
end