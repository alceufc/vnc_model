function [] = gen_presentation_data( )
% PRESENTATION_FIGS Generates data for the presentation figures.
MINUTES_IN_HOUR = 60;
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(settings.pres_data_dir);
warning('on', 'MATLAB:MKDIR:DirectoryExists');


fileName = 'data_example.dat';
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 1;
save_data_file(filePath, ...
               [Ucell{pos}, Dcell{pos}.*2, Ccell{pos}.*20], ...
               {'Up-votes', 'Down-votes', 'Comments'}, ...
               'addTimestampCol', true);

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

end