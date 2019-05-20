clearvars;clc;close all;

SAMPLES = 512;
API_KEY = 'AIzaSyDisRmwIXn8JXJpqTVUDcHa7M9LGsEcT2w';   % Read https://developers.google.com/maps/documentation/elevation/get-api-key

Coord1 = [41.294517, -8.717167]; 
Coord2 = [41.032861, -8.382944];

load(['backup_' num2str(SAMPLES)]);
disp('Displaying Data');

%% Max Elevation Point
[~,index] = max(elevation_map(:));
maxElevation=[lng_map(index),lat_map(index),elevation_map(index)];

%% Points
points = maxElevation;
% points(2,:)= minElevation;

%% All Line-of-sight visibility points in terrain
 latlim = [min(lat_map(:)), max(lat_map(:))];
 lonlim = [min(lng_map(:)), max(lng_map(:))];
 rasterSize = size(elevation_map);
 R = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');

[visgrid,~]=viewshed(elevation_map,R,points(1,2),points(1,1),30,1);
visgrid=logical(visgrid);

%dist
dist=deg2km(distance(points(1,2),points(1,1),lat_map,lng_map),'earth');
disTerrestre=dist;
dist=sqrt(abs((points(1,3)-min(dist))).^2+(dist.*1000).^2)/1000;

%% Atenuação em espaço livre  [visgrid-->lineOfsight]
f= 400e6; %Hz
c=3e8; %m/s
lambda=c/f;%m
Gtx=1;
Grx=1; % dB
Ptx=50; %dBm 100w

% Atenuação em espaço livre  [visgrid-->lineOfsight]
LFS=NaN(size(dist));
LFS(visgrid)=PL_Hata_modify(f,dist(visgrid).*1000,points(1,3),elevation_map(visgrid),'URBAN');

%Prx
Prx_dBm=Ptx+Gtx+Grx-LFS;

%% color devision  
signalColor=colorLegend(Prx_dBm);

figure('name','BS1');
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(1,1),points(1,2),points(1,3),'filled','v','r','SizeData',200);
hold off


%% BS2 
points(2,:)=[-8.41172240000000,41.0963930000000,394.334533700000];

[visgrid2,~]=viewshed(elevation_map,R,points(2,2),points(2,1),30,1);
visgrid2=logical(visgrid2);
%intrecção pontos de visibilidade 
Sub=NaN(size(visgrid2));
Sub=and(visgrid,visgrid2);

%dist
dist=deg2km(distance(points(2,2),points(2,1),lat_map,lng_map),'earth');
disTerrestre=dist;
dist=sqrt(abs((points(2,3)-min(dist))).^2+(dist.*1000).^2)/1000;

LFSBS2=NaN(size(LFS));
LFSBS2(visgrid2)=PL_Hata_modify(f,dist(visgrid2).*1000,points(2,3),elevation_map(visgrid2),'URBAN');
LFS(visgrid2)=PL_Hata_modify(f,dist(visgrid2).*1000,points(2,3),elevation_map(visgrid2),'URBAN');

%Prx
Prx_dBm2=Ptx+Gtx+Grx-LFSBS2;

% color devision  
signalColor2=colorLegend(Prx_dBm2);

figure('name','BS2');
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor2);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(2,1),points(2,2),points(2,3),'filled','v','r','SizeData',200);
hold off


%% BS3
points(3,:)=[-8.58700970000000,41.1077348000000,232.853225700000];

[visgrid3,~]=viewshed(elevation_map,R,points(3,2),points(3,1),30,1);
visgrid3=logical(visgrid3);
%intrecção pontos de visibilidade 
Sub2=and(Sub,visgrid3);

LFSBS3=NaN(size(LFS));
%dist
dist=deg2km(distance(points(3,2),points(3,1),lat_map,lng_map),'earth');
disTerrestre=dist;
dist=sqrt(abs((points(3,3)-min(dist))).^2+(dist.*1000).^2)/1000;

LFSBS3(visgrid3)=PL_Hata_modify(f,dist(visgrid3).*1000,points(3,3),elevation_map(visgrid3),'URBAN');
LFS(visgrid3)=PL_Hata_modify(f,dist(visgrid3).*1000,points(3,3),elevation_map(visgrid3),'URBAN');

%Prx
Prx_dBm3=Ptx+Gtx+Grx-LFSBS3;

% color devision  
signalColor3=colorLegend(Prx_dBm3);

figure('name','BS3');
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor3);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(3,1),points(3,2),points(3,3),'filled','v','r','SizeData',200);
hold off

%% power image display
% subplot(2,2,[3,4]);
% imagesc(signalColor,[0 255]);


%%Prx
Prx_dBm=Ptx+Gtx+Grx-LFS;
%% color devision  
signalColor4=colorLegend(Prx_dBm);
%% Displays the data
figure('Name','BS1+BS2+BS3');
subplot(1,2,1);
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor4);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(1,1),points(1,2),points(1,3),'filled','v','r','SizeData',200);
scatter3(points(2,1),points(2,2),points(2,3),'filled','v','r','SizeData',200);
scatter3(points(3,1),points(3,2),points(3,3),'filled','v','r','SizeData',200);
plot3(lng_map(Sub),lat_map(Sub),elevation_map(Sub),'w.','markersize',5);
plot3(lng_map(Sub2),lat_map(Sub2),elevation_map(Sub2),'w.','markersize',5);
hold off
subplot(1,2,2);
imshow('z_Legend.jpg');


%% KML file
AA_func(lat_map(1),lat_map(end),lng_map(1),lng_map(end),Prx_dBm,'Coverage_map');
 
