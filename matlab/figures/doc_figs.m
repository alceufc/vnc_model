function [] = doc_figs( )
% DOC_FIGS Generates figures for the documentation.
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');

figure;
params = fit_vote_model(@v_and_c, Ucell{1});
figName = 'vote_model_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
plot_vote_model_fit(@v_and_c, params, Ucell{1});
save_as_png(plot_path, [5.0, 2.3]);

figure;
[params_up, params_down] = fit_up_vs_downvote(Ucell{1}, Dcell{1});
figName = 'up_vs_downvote_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
plot_up_vs_downvote_fit(params_up, params_down, Ucell{1}, Dcell{1});
save_as_png(plot_path, [5.0, 2.3]);

end
