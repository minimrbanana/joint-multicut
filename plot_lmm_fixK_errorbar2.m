%Plot all the output embeddings in one figure
%
clear all;
close all;

s1=42;
s2=37;
lw=12;
ms=14;

figpath = './';

lmm='LMM';
sje='SJE';

K=[1 2 3 4 5 6];
xticks = {'1', '2', '4', '6','8','10'};

%% CUB
% cont 
% acc1 = [48.1 50.7 48.2 42.4 46.5];
% acc2 = [46.9 45.6 47.1 40.2 44];
% acc4 = [44 46 45.3 40.2 42.7];
% acc6 = [45 47 43.4 41.3 47.2];
% acc8 = [45.1 45 42.8 41.3 43.3];
% acc10 = [43.3 40.1 42.7 40.8 44.3];
% acc = [acc1' acc2' acc4' acc6' acc8' acc10'];
% acc_sje = 49.5;
% 
% f =figure(1);
% h1 = errorbar(mean(acc), std(acc) / sqrt(5), 'k-*','LineWidth',lw, 'MarkerSize',ms);
% hold on 
% word2vec
acc1 = [32 32.6 27.4 33.1 38.6];
acc2 = [32.2 31.7 26.9 35.4 40.2];
acc4 = [32.8 32.8 28.4 36.2 38.8];
acc6 = [33.4 33.9 28.7 37.5 38.2];
acc8 = [33.3 33.5 28.1 36.2 38.9];
acc10 = [31.7 32.4 27.5 36.5 38.4];
acc = [acc1' acc2' acc4' acc6' acc8' acc10'];
acc_sje = 27.7;

f =figure(1);
hold on 
h1 = errorbar(mean(acc), std(acc)/ sqrt(5), 'g-*','LineWidth',lw, 'MarkerSize',ms);

% glove
acc1 = [30.2 24.7 22 30.4 32.5];
acc2 = [31.1 27.1 23.9 30.1 33.2];
acc4 = [30.5 28.7 24.5 31.9 33.4];
acc6 = [31.2 28.7 25.3 31.4 36.2];
acc8 = [31.4 29.1 25 32.8 37.4];
acc10 = [32.1 30.4 24.1 33.8 37.4];
acc = [acc1' acc2' acc4' acc6' acc8' acc10'];
acc_sje = 24.8;

h2 = errorbar(mean(acc), std(acc) / sqrt(5), 'r-*','LineWidth',lw, 'MarkerSize',ms);


% wordnet
acc1 = [23 21.1 18.7 29.2 25.2];
acc2 = [22.2 23.1 20.5 29.9 24.4];
acc4 = [22.5 21.3 20 28.3 24.4];
acc6 = [22.3 21 20.6 27.5 25.9];
acc8 = [22.4 20.4 19.9 27.4 25.9];
acc10 = [21.6 21.6 19.7 27.6 28.3];
acc = [acc1' acc2' acc4' acc6' acc8' acc10'];
acc_sje = 21.4;

h3 = errorbar(mean(acc), std(acc)/ sqrt(5), 'b-*','LineWidth',lw, 'MarkerSize',ms);



set(gca, 'xtick', K, 'FontSize',  s2);
set(gca, 'xticklabel', xticks, 'FontSize',  s1);
set(ylabel('Top-1 Acc. (in %)'), 'FontSize',  s1);
set(xlabel('K'), 'FontSize',  s1);
xlim([0.5 6.5]);
ylim([12 40]);
grid on;

legend([h1(1);h2(1);h3(1);],{'word2vec','glove','wordnet'}, 'FontSize', s2, 'Location','southeast');
set(f,'PaperUnits','normalized');
set(f,'PaperPosition', [0 0 1 1]);
set(f,'PaperOrientation','landscape');
print(1,'-dpdf',[figpath 'cub_fixK']);