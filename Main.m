clearvars;clc;close all;
SAMPLES = 512;
alturaAntena=30;
load('backup_512.mat');
disp('Displaying Data');

%% All Line-of-sight visibility points in terrain
latlim = [min(lat_map(:)), max(lat_map(:))];
lonlim = [min(lng_map(:)), max(lng_map(:))];
rasterSize = size(elevation_map);
%GEOREFCELLS Reference raster cells to geographic coordinates
R = georefpostings(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');

%% BestBSCoverage
coverageTarget=70;
[BS]=bestBsCoverage(elevation_map,lat_map,lng_map,R,coverageTarget,alturaAntena);

Prx_dBmBS=NaN(size(lat_map));
visgridBS=NaN(size(lat_map));
for i=1:length (BS(:,1))
    [Prx_dBmBS(:,:,i),visgridBS(:,:,i)]=Antena(['BS',num2str(i)],['BS',num2str(i)],BS(i,:),elevation_map,lat_map,lng_map,R);
end
visgridBS=logical(visgridBS);

%% PRX
Prx_dBm=Prx_dBmBS(:,:,1);
imax=length (BS(:,1));
%i=sort(1:imax,'descend')
for i=1:length (BS(:,1))
    auxPrx=Prx_dBmBS(:,:,i);
    auxVisgrid=visgridBS(:,:,i);
    Prx_dBm(auxVisgrid)=auxPrx(auxVisgrid);
end
%% pontos de intrecção
Sub=NaN(size(visgridBS(:,:,1)));
inter=NaN(size(visgridBS(:,:,1)));
for i=1:length (BS(:,1))
    for j=1:length (BS(:,1))
        if(j~=i)
            Sub=and(visgridBS(:,:,i),visgridBS(:,:,j));
        end
    end
   inter(:,:,i)=Sub;
end

%% Coverage Area
coverageTotal=Prx_dBm;
coverageTotal(isnan(coverageTotal))=0;
coverageTotal=logical(coverageTotal);
numberOnes(:,1)=sum(sum(coverageTotal));
coverageTotal=round((max(numberOnes/length(lng_map(:)))*100));

%% color devision
signalColor=colorLegend(Prx_dBm);

%% Displays the data
figure('Name','Todas as BS');
%subplot(1,2,1);
axis tight
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
hold on
title(strcat(['Coverage map : ',num2str(coverageTotal),'%']));
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
for i=1:length (BS(:,1))
    scatter3(BS(i,1),BS(i,2),BS(i,3)+10,'filled','v','m','SizeData',200);
end
for i=1:length (Sub(1,1,:))
    auxInter=logical(inter(:,:,i));
    plot3(lng_map(auxInter(:)),lat_map(auxInter(:)),elevation_map(auxInter(:)),'o','markersize',1);
end

hold off
%subplot(1,2,2);
%imshow('z_Legend.jpg');

%% Antenna Patern Atenuação 3d
load('Antena400MhzGain13.mat');
figure('Name','Antenna Patern Atenuação 3D');
patternCustom(Antena400MhzGain13.Attenuation,Antena400MhzGain13.Vert_Angle,Antena400MhzGain13.Hor_Angle);

%% KML file
AA_func(lat_map(1),lat_map(SAMPLES,SAMPLES),lng_map(1),lng_map(SAMPLES,SAMPLES),Prx_dBm,'Coverage_map');

%% power image display
% imagesc(signalColor,[0 255]);
