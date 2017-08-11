
clear all;  close all;  clc;

own_ft_setpath_rest;
data_folder = 'J:\MEG_Research\tSSS_efficiency';
addpath('C:\Program Files\MATLAB\R2012b\toolbox_add_on\tSSS_chk');
cd(data_folder);

filenames      = dir('*.fif');
for loop = 1: length(filenames)
    file_sub(loop) = {filenames(loop).name};
end

file_sub = reshape(file_sub, 2, []);
file_sub = file_sub';

%%
for typeLoop = 1:2 
    for fileLoop = 1:4
        
        % Import file
        cfg                         = [];
        cfg.dataset                 = filenames(typeLoop,fileLoop).name;%filenames(condLoop).name;
        proc.data_import            = ft_preprocessing(cfg);
        
        time_tot    = floor(proc.data_import.time{1}(end));
        fs          = proc.data_import.fsample;
        sample_tot  = time_tot*fs;
        trl         = [];
        trl         = [[0:fs:sample_tot-fs]' [fs:fs:sample_tot]'];
        trl(:,1)    = trl(:,1)+1;
        trl(:,3)    = 0;    % [fs.*size(trl,1)]';

        cfg                         = [];
        cfg.lpfilter                = 'yes';
        cfg.lpfreq                  =  100;
        cfg.hpfilter                = 'yes';
        cfg.hpfreq                  =  1;
        cfg.dftfilter               = 'yes';
        cfg.channel                 =  {'MEG'};
        cfg.detrend                 = 'yes';
        proc.preproc_data           = ft_preprocessing(cfg, proc.data_import);
        
        cfg = [];
        cfg.trl = trl;
        proc.data_epoched = ft_redefinetrial(cfg, proc.preproc_data);
        
        % Pow
        cfg                         = [];
        cfg.method                  = 'mtmfft';
        cfg.pad                     = 2;
        cfg.taper                   = 'dpss';
        cfg.keeptrials              = 'yes';
        cfg.jackknife               = 'yes';
        cfg.channelcmb              = {'MEG*'};
        cfg.channel                 = {'MEG*'};
        cfg.foi                     = 1:2:200;
        cfg.tapsmofrq               = 3;
        cfg.output                  = 'pow';
        pow_csd{typeLoop,fileLoop}  = ft_freqanalysis(cfg, proc.data_epoched);
 
    end
end

%% Power plots

clrOp1 = rgb('dodgerBlue');%[0.7 0.2 0.2];
clrOp2 = rgb('Black');%[0.4 0.4 0.4];
clrOp3 = rgb('Crimson');
clrOp4 = rgb('Olive');
lw=3;

hFig = figure(1)
set(hFig, 'Position', [10 80 1596 1024]);

for loop=1:3
    
   
    [a b c]     =   fileparts(pow{1,loop}.filename)
    subplot(1,3,loop)
    semilogy(pow_new{1,loop}.freq, mean(pow_new{1,loop}.powspctrm), 'color',clrOp1,'linewidth', lw), hold on
    semilogy(pow{1,loop}.freq, mean(pow{1,loop}.powspctrm),'-', 'color',clrOp3,'linewidth', lw);
    % semilogy(pow{3}.freq, mean(pow{3}.powspctrm),'-', 'color',clrOp3,'linewidth', lw);
    % semilogy(pow{4}.freq, mean(pow{4}.powspctrm),'-', 'color',clrOp4,'linewidth', lw);
%     hlegend = legend({'DBS OFF','DBS ON'});
axis([0 100 10e-25 40-20])

    % hlegend = legend({'UPDRS III'},'Interpreter','latex');
%     set(hlegend,'Fontsize',18);
%     set(hlegend,'Fontname','Helvetica');
%     set(hlegend,'Location','Northeast');
%     legend boxoff
%     box off
    % xlim([0 45])
%     set(gca,'XTick',[0:50:200]);
%     set(gca,'Fontsize', 18)
%     set(gca,'Fontweight','bold');
%     set(gca,'Fontname','Helvetica');

%     hxlabel = xlabel('Frequency Hz');
    % set(hxlabel,'Fontsize',24);
    % set(hxlabel,'FontWeight','bold');
    % set(hxlabel,'Fontname','Helvetica');
%     title(b(1:3))
%     hylabel = ylabel(['Spectral density']);%  fT/cm- $$\sqrt{Hz}$$'],'Interpreter', 'latex');
%     export_fig( gcf, ['PowPlot-',b(1:3)],'-transparent', ...
%             '-painters','-pdf', '-r250' ); 


end

%%
set(gcf, 'Color', 'None'); % white bckgr
set(gca, 'Color', 'None'); % white bckgr
export_fig( gcf, 'SEF-DBSON-topo130Hz','-transparent', ...
        '-painters','-pdf', '-r250' ); 
    
%%    

cfg_sel = [];
cfg_sel.trials = [240];
trlData{1,1} = ft_selectdata(cfg_sel, dat_fT{1,1}.dataArtRej);
trlData{1,2} = ft_selectdata(cfg_sel, dat_fT{1,2}.dataArtRej);


%%
cfg                 = [];
cfg.layout          = 'neuromag306cmb.lay';
% cfg.channel         = 'MEGGRAD';
% cfg.hlim            = [-0.1 0.2];
% cfg.vlim            = [-2000 2000];
figure,
ft_multiplotER(cfg,ft_combineplanar([],pow{2}));

%%
hlegend = legend({'tSSS', 'no tSSS'});
set(hlegend,'Fontsize',18);
set(hlegend,'Fontname','Helvetica');
set(hlegend,'Location','Northeast');
legend boxoff
box off

export_fig( gcf, 'multiER-full-LH','-transparent', ...
        '-painters','-pdf', '-r250' ); 

%% Timelock analysis

cfgtlck = [];
cfgtlck.channel = 'MEGGRAD';
cfgtlck.removemean = 'yes';

for loop = 1:2
    tlck{loop}     = ft_timelockanalysis(cfgtlck,dat_fT{loop}.dataArtRej);
    tlckCmb{loop}  = ft_combineplanar([], tlck{loop});
end

%% TFR 














