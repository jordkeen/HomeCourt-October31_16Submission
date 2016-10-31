%set home directory
cd('K:\Research\Projects\HomeCourt');

%direct to Matlab directory
cd Matlab

%read in data exported from STATA
%2016 season - fixed effects model
clear;
data = readtable('winProbData.xlsx');

%generates figure X
data.winProbNeutral = 1 - normcdf(0,data.predMarginNeutral,data.stdf);
data.winProbHome = 1 - normcdf(0,data.predMarginNeutral + data.teamHomeCoef,data.stdf);
data.winProbChange = data.winProbHome - data.winProbNeutral;

figure1 = figure;
scatter(data.predMarginNeutral,data.winProbChange,'.');
xlabel({'Predicted Margin - Neutral Site'});
ylabel({'Change in Win Probability - Home'});

saveas(figure1,'winProbChangeFigure.png');

%generate table 3
avgStdf = mean(data.stdf);
teamHome = mean(data.teamHomeCoef);
predMarginNeutral = zeros(41,1);
index = -20;
for xx = 1:size(predMarginNeutral)
    predMarginNeutral(xx,:) = index;
    index = index + 1;
end

winProbNeutral = 1 - normcdf(0,predMarginNeutral,avgStdf);
winProbHome = 1 - normcdf(0,predMarginNeutral+teamHome,avgStdf);
changeWinProb = winProbHome - winProbNeutral;

table3 = [predMarginNeutral,winProbNeutral,winProbHome,changeWinProb];
