clearvars;clc;close all;

SAMPLES = 512;
API_KEY = 'AIzaSyDisRmwIXn8JXJpqTVUDcHa7M9LGsEcT2w';   % Read https://developers.google.com/maps/documentation/elevation/get-api-key

Coord1 = [39.5440818,-8.8233585]; %pedreiras da minha terra
Coord2 = [39.7540405,-8.8759987];

load(['backup_' num2str(SAMPLES)]);
disp('Displaying Data');

%% Max and Min Elevation Point
[~,index] = max(elevation_map(:));
maxElevation=[lng_map(index),lat_map(index),elevation_map(index)];
[~,index] = min(elevation_map(:));
minElevation=[lng_map(index),lat_map(index),elevation_map(index)];

%% Points
points = maxElevation;
points(2,:)= minElevation;

%% dist between 2 points
distTerrestre=distance(points(1,2),points(1,1),points(2,2),points(2,1));
distTerrestre=deg2km(distTerrestre,'earth');
distLink=sqrt((max(points(:,3))-min(points(:,3)))^2+(distTerrestre*1000)^2)/1000;
fprintf('distTerrestre: %f\ndistLink: %f\n',distTerrestre,distLink);

%% Line-of-sight visibility between two points in terrain
% latlim = [min(lat_map(:)), max(lat_map(:))];
% lonlim = [min(lng_map(:)), max(lng_map(:))];
% rasterSize = size(elevation_map);
% R = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');
% [vis,visprofile,distance2points,h,lattrk,lontrk] = los2(elevation_map,R,points(1,2),points(1,1),points(2,2),points(2,1),10,10);
% plot3(lontrk(visprofile),lattrk(visprofile),h(visprofile),'g.','markersize',20);
% plot3(lontrk(~visprofile),lattrk(~visprofile),h(~visprofile),'r.','markersize',20);

%% All Line-of-sight visibility points in terrain
 latlim = [min(lat_map(:)), max(lat_map(:))];
 lonlim = [min(lng_map(:)), max(lng_map(:))];
 rasterSize = size(elevation_map);
 R = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');

[visgrid,~]=viewshed_nova(elevation_map,R,points(1,2),points(1,1),30,1);
visgrid=logical(visgrid);

%dist
dist=deg2km(distance(points(1,2),points(1,1),lat_map,lng_map),'earth');
disTerrestre=dist;
dist=sqrt(abs((max(points(:,3))-min(dist))).^2+(dist.*1000).^2)/1000;

%Cut Radius
cutRadius=true;
radius=6; %km
mask4=ones(size(disTerrestre));
if(cutRadius)
mask4= disTerrestre <=radius;
end
 
%% Atenuação em espaço livre  [visgrid-->lineOfsight]
f= 380e6; %Hz
c=3e8; %m/s
lambda=c/f;%m
Gtx=1;
Grx=1; % dB
Ptx=1; %dB

% Atenuação em espaço livre  [visgrid-->lineOfsight]
LFS=NaN(size(dist));
LFS(visgrid)=PL_free(f,dist(visgrid).*1000,Gtx,Grx);

% Atenuação com modelo para ~visgrid
LFS(~visgrid)=PL_Hata_modify(f,dist(~visgrid).*1000,maxElevation(1,3),elevation_map(~visgrid),'URBAN');
% LFS(~visgrid)=PL_IEEE80216d_modify(f,dist(~visgrid).*1000,'B',maxElevation(1,3),elevation_map(~visgrid),'Okumura');

%Prx
Prx_dBm=Ptx+Gtx+Grx-LFS;

if(cutRadius)
Prx_dBm_radius=NaN(size(dist));
Prx_dBm_radius(mask4)=Prx_dBm(mask4);
end

%% color devision  
signalColor=colorLegend(Prx_dBm);
%% Displays the data
figure('Name','Elevation');
subplot(1,2,1);
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
scatter3(points(1,1),points(1,2),points(1,3),'filled','v','k','SizeData',200);
% scatter3(points(2,1),points(2,2),points(2,3),'filled','SizeData',200);
hold off
subplot(1,2,2);
imshow('z_Legend.jpg');



 
%% power image display
% subplot(2,2,[3,4]);
%  imagesc(signalColor,[0 255]);


%% SelectBaseStation 
%find best Prx_dbm in det range with best elevation_map




%% KML file
 AA_func(lat_map(1),lat_map(end),lng_map(1),lng_map(end),Prx_dBm,'Coverage_map');
 if(cutRadius)
 AA_func(lat_map(1),lat_map(end),lng_map(1),lng_map(end),Prx_dBm_radius,'Coverage_map_radius');
 end

