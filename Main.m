clearvars;clc;close all;
%% Variaveis
f= 400e6; %Hz
c=3e8; %m/s
lambda=c/f;%m
Gtx=1;
Grx=1; % dB
Ptx=50; %dBm 100w

SAMPLES = 512;
API_KEY = 'AIzaSyDisRmwIXn8JXJpqTVUDcHa7M9LGsEcT2w';   % Read https://developers.google.com/maps/documentation/elevation/get-api-key

load(['backup_' num2str(SAMPLES)]);
disp('Displaying Data');

%%------- Max Elevation Point
[~,index] = max(elevation_map(:));
maxElevation=[lng_map(index),lat_map(index),elevation_map(index)];

%%------- Points
points = maxElevation;
points(2,:)=[-8.41172240000000,41.0963930000000,394.334533700000];
points(3,:)=[-8.58700970000000,41.1077348000000,232.853225700000];

%% All Line-of-sight visibility points in terrain
 latlim = [min(lat_map(:)), max(lat_map(:))];
 lonlim = [min(lng_map(:)), max(lng_map(:))];
 rasterSize = size(elevation_map);
 %GEOREFCELLS Reference raster cells to geographic coordinates

 R = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');

%% BS1
[Prx_dBmBS1,visgridBS1]=Antena('BS1','Coverage Map - BS1',points(1,1),points(1,2),points(1,3),elevation_map,lat_map,lng_map,R);
%% BS2 
[Prx_dBmBS2,visgridBS2]=Antena('BS2','Coverage Map - BS2',points(2,1),points(2,2),points(2,3),elevation_map,lat_map,lng_map,R);
%% BS3
[Prx_dBmBS3,visgridBS3]=Antena('BS3','Coverage Map - BS3',points(3,1),points(3,2),points(3,3),elevation_map,lat_map,lng_map,R);

%% PRX
Prx_dBm=NaN(SAMPLES,SAMPLES);
Prx_dBm=Prx_dBmBS1;
Prx_dBm(visgridBS2)=Prx_dBmBS2(visgridBS2);
Prx_dBm(visgridBS3)=Prx_dBmBS3(visgridBS3);

%% intrecção pontos de visibilidade 
Sub=NaN(size(visgridBS1));
Sub=and(visgridBS1,visgridBS2);
Sub2=and(visgridBS1,visgridBS3);
Sub3=and(visgridBS2,visgridBS3);
%% color devision  
signalColor=colorLegend(Prx_dBm);
% mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
%% Displays the data
figure('Name','BS1+BS2+BS3');
subplot(1,2,1);
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor); 
hold on
title('Coverage Map - BS1 & BS2 & BS3');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(1,1),points(1,2),points(1,3),'filled','v','r','SizeData',200);
scatter3(points(2,1),points(2,2),points(2,3),'filled','v','r','SizeData',200);
scatter3(points(3,1),points(3,2),points(3,3),'filled','v','r','SizeData',200);
plot3(lng_map(Sub),lat_map(Sub),elevation_map(Sub),'w.','markersize',5);
plot3(lng_map(Sub2),lat_map(Sub2),elevation_map(Sub2),'w.','markersize',5);
plot3(lng_map(Sub3),lat_map(Sub3),elevation_map(Sub3),'w.','markersize',5);
hold off
subplot(1,2,2);
imshow('z_Legend.jpg');

%% KML file
AA_func(lat_map(1),lat_map(SAMPLES,SAMPLES),lng_map(1),lng_map(SAMPLES,SAMPLES),Prx_dBm,'Coverage_map');
 
%% power image display
% imagesc(signalColor,[0 255]);
