%% Incremental Site Assessment (ISA) Costings
close all; clear; clc; Start = tic;
disp('%%% ISA Costings %%%'); 
disp('J.McDowell 04/04/2020'); 

%% USER INPUTS (Number of Potential Sites to Assess) 
IN.NumberPotentialSites2Assess = 1:1:10;

%% USER INPUTS (Success Rates)
IN.DESKTOP.SuccessRate  = 0.5;
IN.INITIAL.SuccessRate  = 0.5;
IN.DETAILED.SuccessRate = 0.5;

IN.CONSTANT.SuccessRate = 0.1:0.1:1;

%% Input Checks
validateattributes(IN.NumberPotentialSites2Assess,...
    {'numeric'},{'row','positive','integer','nonempty','nonnan','finite'});                                        

validateattributes(IN.DESKTOP.SuccessRate,...
    {'numeric'},{'scalar','positive','<=',1,'nonempty','nonnan','finite'});    

validateattributes(IN.INITIAL.SuccessRate,...
    {'numeric'},{'scalar','positive','<=',1,'nonempty','nonnan','finite'});    

validateattributes(IN.DETAILED.SuccessRate,...
    {'numeric'},{'scalar','positive','<=',1,'nonempty','nonnan','finite'});    

validateattributes(IN.CONSTANT.SuccessRate,...
    {'numeric'},{'row','positive','<=',1,'nonempty','nonnan','finite'});    

%% Assumptions (Desktop Survey) 
% Baseline
DESKTOP.Baseline.Cost_AnalysisSoftwareSubscriptions = 1600 + 400;           % MATLAB + GlobalMapper

% Per Site
DESKTOP.PerSite.Cost_Charts             = 150;                              % ADMIRALTY / Navionics high resolution charts.
DESKTOP.PerSite.Cost_MetoceanDataPortal = 65;                               % DHI metocean data + TideTimes tide data.

%% Assumptions (Initial Survey) 
% Baseline
INITIAL.BaseLine.Number_DriftersBuilt    = 4;
INITIAL.BaseLine.Cost_IndividualDrifter  = 60 + 40;                         % Materials + GPS tracker.
INITIAL.Baseline.Cost_SonarBuoy          = 0;                               % Deeper/Fishhunter
INITIAL.Baseline.Cost_CTDSonde           = 0;
INITIAL.Baseline.Cost_SchmidtHammer      = 200;
INITIAL.Baseline.Cost_SingleBeamMFSonar  = 2500 + 1500;                     % Hondex + GPS
INITIAL.Baseline.Cost_HandheldAnemometer = 50;                              % Proster

% Per Site
INITIAL.PerSite.Survey_Duration_D   = 2;
INITIAL.PerSite.Cost_VesselHire_pD  = 1000;
INITIAL.PerSite.Cost_DropCamHire_pD = 150;

%% Assumptions (Detailed Survey Costs) 
% Baseline
% Assumed no equipment bought as too expensive, all hired on per site basis

% Per Site
DETAILED.PerSite.Survey_Duration_D                   = 4;
DETAILED.PerSite.Cost_VesselHire_pD                  = 2000;
DETAILED.PerSite.Cost_BottomMountedADCPSurvey        = 18000;
DETAILED.PerSite.Cost_FullSwatheMultiBeamBathySurvey = 9000;
DETAILED.PerSite.Cost_SubBottomProfilerBedSurvey     = 9000;

%% Total Costs (Variable Success Rates)
disp('Calculating total costs at each stage of the ISA (variable success rates)...');
% Desktop
COSTS1.DESKTOP.NumberSites2Assess...
    = IN.NumberPotentialSites2Assess;

COSTS1.DESKTOP.Total = DESKTOP.Baseline.Cost_AnalysisSoftwareSubscriptions...
                    + (COSTS1.DESKTOP.NumberSites2Assess .*...
                      (DESKTOP.PerSite.Cost_Charts + DESKTOP.PerSite.Cost_MetoceanDataPortal));
           
% Initial
COSTS1.INITIAL.NumberSites2Assess...
    = ceil(COSTS1.DESKTOP.NumberSites2Assess...
    .* (1 - IN.DESKTOP.SuccessRate));

COSTS1.INITIAL.NumberSites2Assess(COSTS1.INITIAL.NumberSites2Assess == 0) = 1;

COSTS1.INITIAL.Total = (INITIAL.BaseLine.Number_DriftersBuilt * INITIAL.BaseLine.Cost_IndividualDrifter)...
                    + INITIAL.Baseline.Cost_SonarBuoy...
                    + INITIAL.Baseline.Cost_CTDSonde...
                    + INITIAL.Baseline.Cost_SchmidtHammer...
                    + INITIAL.Baseline.Cost_SingleBeamMFSonar...
                    + INITIAL.Baseline.Cost_HandheldAnemometer...
                    + (COSTS1.INITIAL.NumberSites2Assess .*...
                      (INITIAL.PerSite.Survey_Duration_D * (INITIAL.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD)));

% Detailed
COSTS1.DETAILED.NumberSites2Assess...
    = ceil(COSTS1.INITIAL.NumberSites2Assess...
    .* (1 - IN.INITIAL.SuccessRate));

COSTS1.DETAILED.NumberSites2Assess(COSTS1.DETAILED.NumberSites2Assess == 0) = 1;

COSTS1.DETAILED.Total = COSTS1.DETAILED.NumberSites2Assess .*...
                       ((DETAILED.PerSite.Survey_Duration_D * (DETAILED.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD))...
                       + DETAILED.PerSite.Cost_BottomMountedADCPSurvey...
                       + DETAILED.PerSite.Cost_FullSwatheMultiBeamBathySurvey...
                       + DETAILED.PerSite.Cost_SubBottomProfilerBedSurvey);

% ISA
COSTS1.ISA.NumberSitesRemaining...
    = ceil(COSTS1.DETAILED.NumberSites2Assess...
    .* (1 - IN.DETAILED.SuccessRate));


COSTS1.ISA.Total = COSTS1.DESKTOP.Total...
                  + COSTS1.INITIAL.Total...
                  + COSTS1.DETAILED.Total;
              
% Standard
COSTS1.STANDARD.NumberSitesRemaining...
    = ceil(IN.NumberPotentialSites2Assess...
    .* (1 - IN.DETAILED.SuccessRate));

COSTS1.STANDARD.Total = IN.NumberPotentialSites2Assess .* ...
        ((DETAILED.PerSite.Survey_Duration_D * (DETAILED.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD))...
                       + DETAILED.PerSite.Cost_BottomMountedADCPSurvey...
                       + DETAILED.PerSite.Cost_FullSwatheMultiBeamBathySurvey...
                       + DETAILED.PerSite.Cost_SubBottomProfilerBedSurvey);
       
%% Total Costs (Constant Success Rate)
disp('Calculating total costs at each stage of the ISA (constant success rate)...');
% Desktop
COSTS2.DESKTOP.NumberSites2Assess...
    = IN.NumberPotentialSites2Assess;

COSTS2.DESKTOP.Total = DESKTOP.Baseline.Cost_AnalysisSoftwareSubscriptions...
                    + (COSTS2.DESKTOP.NumberSites2Assess .*...
                      (DESKTOP.PerSite.Cost_Charts + DESKTOP.PerSite.Cost_MetoceanDataPortal));
           
% Initial
COSTS2.INITIAL.NumberSites2Assess...
    = ceil(COSTS2.DESKTOP.NumberSites2Assess...
    .* (1 - IN.CONSTANT.SuccessRate'));

COSTS2.INITIAL.NumberSites2Assess(COSTS2.INITIAL.NumberSites2Assess == 0) = 1;

COSTS2.INITIAL.Total = (INITIAL.BaseLine.Number_DriftersBuilt * INITIAL.BaseLine.Cost_IndividualDrifter)...
                    + INITIAL.Baseline.Cost_SonarBuoy...
                    + INITIAL.Baseline.Cost_CTDSonde...
                    + INITIAL.Baseline.Cost_SchmidtHammer...
                    + (COSTS2.INITIAL.NumberSites2Assess .*...
                      (INITIAL.PerSite.Survey_Duration_D * (INITIAL.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD)));

% Detailed
COSTS2.DETAILED.NumberSites2Assess...
    = ceil(COSTS2.INITIAL.NumberSites2Assess...
    .* (1 - IN.CONSTANT.SuccessRate'));

COSTS2.DETAILED.NumberSites2Assess(COSTS2.DETAILED.NumberSites2Assess == 0) = 1;

COSTS2.DETAILED.Total = COSTS2.DETAILED.NumberSites2Assess .*...
                       ((DETAILED.PerSite.Survey_Duration_D * (DETAILED.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD))...
                       + DETAILED.PerSite.Cost_BottomMountedADCPSurvey...
                       + DETAILED.PerSite.Cost_FullSwatheMultiBeamBathySurvey...
                       + DETAILED.PerSite.Cost_SubBottomProfilerBedSurvey);

% ISA
COSTS2.ISA.NumberSitesRemaining...
    = ceil(COSTS2.DETAILED.NumberSites2Assess...
    .* (1 - IN.DETAILED.SuccessRate'));


COSTS2.ISA.Total = COSTS2.DESKTOP.Total...
                 + COSTS2.INITIAL.Total...
                 + COSTS2.DETAILED.Total;
              
% Standard
COSTS2.STANDARD.NumberSitesRemaining...
    = ceil(IN.NumberPotentialSites2Assess...
    .* (1 - IN.CONSTANT.SuccessRate'));

COSTS2.STANDARD.Total = IN.NumberPotentialSites2Assess .* ...
        ((DETAILED.PerSite.Survey_Duration_D * (DETAILED.PerSite.Cost_VesselHire_pD + INITIAL.PerSite.Cost_DropCamHire_pD))...
                       + DETAILED.PerSite.Cost_BottomMountedADCPSurvey...
                       + DETAILED.PerSite.Cost_FullSwatheMultiBeamBathySurvey...
                       + DETAILED.PerSite.Cost_SubBottomProfilerBedSurvey);                         
                   
%% Plot Settings
disp('Plotting results...');
FontSize_Axes   = 24;
FontSize_Title  = 24;
FontSize_Legend = 20;

%% ISA PColor
figure;
pcolor(IN.NumberPotentialSites2Assess,...
       IN.CONSTANT.SuccessRate'.*100,...
       COSTS2.ISA.Total);
   
% Color map/bar  
c1 = colorbar; colormap(flipud(autumn));
set(gca,'FontSize',FontSize_Axes); c1.FontSize = FontSize_Axes; 

% Labels
xlabel('Number of Potential Sites to Assess','FontSize',FontSize_Axes);
ylabel('Survey Stage Success Rate [%]','FontSize',FontSize_Axes);
c1.Label.String = 'Site Assessment Cost [£]'; c1.Label.FontSize = FontSize_Axes;
title('Incremental Site Assessment Procedure - Total Costs','FontSize',FontSize_Title);

% Ticks
c1.Limits = [round2(min(COSTS2.ISA.Total,[],'all'),max(diff(c1.Ticks)/2)) ...
            round2(max(COSTS2.ISA.Total,[],'all'),max(diff(c1.Ticks)/2))];

fig2fullscreen; pause(1);

c1.TickLabels = cell(size(c1.Ticks,2),1);
for T = 1:size(c1.Ticks,2)
    c1.TickLabels{T} = num2bank(c1.Ticks(T));
end

%% Standard Site Assessment Procedure PColor
figure;
pcolor(IN.NumberPotentialSites2Assess,...
       IN.CONSTANT.SuccessRate'.*100,...
       COSTS2.STANDARD.Total.*ones(size(IN.CONSTANT.SuccessRate,2),1));
 
% Color map/bar  
c2 = colorbar; colormap(flipud(autumn));
set(gca,'FontSize',FontSize_Axes); c2.FontSize = FontSize_Axes; 

% Labels
xlabel('Number of Potential Sites to Assess','FontSize',FontSize_Axes);
ylabel('Survey Stage Success Rate [%]','FontSize',FontSize_Axes);
c2.Label.String = 'Site Assessment Cost [£]'; c2.Label.FontSize = FontSize_Axes;
title('Standard Site Assessment Procedure - Total Costs','FontSize',FontSize_Title);

% Ticks
c2.Limits = [round2(min(COSTS2.ISA.Total,[],'all'),max(diff(c2.Ticks)/2)) ...
            round2(max(COSTS2.ISA.Total,[],'all'),max(diff(c2.Ticks)/2))];

fig2fullscreen; pause(1);

c2.TickLabels = cell(size(c2.Ticks,2),1);
for T = 1:size(c2.Ticks,2)
    c2.TickLabels{T} = num2bank(c2.Ticks(T));
end

%% ISA vs Standard Surface
figure;
S1 = surf(IN.NumberPotentialSites2Assess,...
       IN.CONSTANT.SuccessRate'.*100,...
       COSTS2.ISA.Total); hold on;
S2 = surf(IN.NumberPotentialSites2Assess,...
       IN.CONSTANT.SuccessRate'.*100,...
       COSTS2.STANDARD.Total.*ones(size(IN.CONSTANT.SuccessRate,2),1)); 
   
% Color map/bar   
colormap(flipud(autumn));
set(S2,'facealpha',0.25);
set(gca,'FontSize',FontSize_Axes);

% Labels
xlabel('Number of Potential Sites to Assess','FontSize',FontSize_Axes);
ylabel('Survey Stage Success Rate [%]','FontSize',FontSize_Axes);
zlabel('Site Assessment Cost [£]','FontSize',FontSize_Axes);
title('Incremental vs Standard Site Assessment Procedure - Total Costs','FontSize',FontSize_Title);

% Ticks
fig2fullscreen; pause(1); view([-124 9.5]); pause(1); 

ZTicksLabel = cell(size(zticks,2),1);
ZTicks = 0:...
    (max(diff(zticks))/2):...
    round2(max(COSTS2.ISA.Total,[],'all'),max(diff(zticks))/2);

for T = 1:size(ZTicks,2)
    ZTicksLabel{T} = num2bank(ZTicks(T));
end

set(gca,'xtick',IN.NumberPotentialSites2Assess);
set(gca,'ytick',IN.CONSTANT.SuccessRate'.*100);
set(gca,'ztick',ZTicks);
set(gca,'zticklabels',ZTicksLabel);

%% ISA vs Standard Plot (50% Success Rate)
figure;
plot(IN.NumberPotentialSites2Assess,...
     COSTS2.ISA.Total((IN.CONSTANT.SuccessRate == 0.5),:),'-o'); hold on;
plot(IN.NumberPotentialSites2Assess,...
     COSTS2.STANDARD.Total,'-o'); 
 
% Labels
xlabel('Number of Potential Sites to Assess','FontSize',FontSize_Axes);
ylabel('Site Assessment Cost [£]','FontSize',FontSize_Axes);
title('Incremental vs Standard Site Assessment Procedure - Total Costs','FontSize',FontSize_Title); 
legend('ISA (50% Success Rate)','Standard Procedure','Location','northwest');

% Ticks
fig2fullscreen; pause(1); 
YTicksLabel = cell(size(yticks,2),1);
YTicks = yticks;

for T = 1:size(YTicks,2)
    YTicksLabel{T} = num2bank(YTicks(T));
end

set(gca,'xtick',IN.NumberPotentialSites2Assess);
set(gca,'yticklabels',YTicksLabel);
set(gca,'FontSize',FontSize_Axes);

%% Finalise
Stop = toc(Start);                                                          
disp(['Script finished normally. Total Time Elapsed: ',num2str(round2(Stop,0.01)),' seconds.']); 
clearvars Start Stop c1 c2 S1 S2 T YTicks YTicksLabel ZTicks ZTicksLabel FontSize_Axes FontSize_Legend FontSize_Title; 
wssize;
