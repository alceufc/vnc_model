function [] = doc_figs( )
% DOC_FIGS Generates figures for the documentation.
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');
params = fit_vote_model(@v_and_c, Ucell{1});

figure;
figName = 'vote_model_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
plot_vote_model_fit(@v_and_c, params, Ucell{1});
save_as_png(plot_path, [5.0, 2.3]);

end
