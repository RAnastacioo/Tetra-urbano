function [Prx_dBm,visgrid] = Antena(FigName,Title,PointLong,PointLat,PointAlt,elevation_map,lat_map,lng_map,R)
%%Variaveis
f= 400e6; %Hz
c=3e8; %m/s
lambda=c/f;%m
Gtx=1;
Grx=1; % dB
Ptx=50; %dBm 100w

[visgrid,~]=viewshed(elevation_map,R,PointLat,PointLong,30,1);
visgrid=logical(visgrid);

%dist
dist=deg2km(distance(PointLat,PointLong,lat_map,lng_map),'earth');
% disTerrestre=dist;
dist=sqrt(abs((PointAlt-dist)).^2+(dist.*1000).^2)/1000;

%HATA
LFS=NaN(size(dist));
LFS(visgrid)=PL_Hata_modify(f,dist(visgrid).*1000,PointAlt,elevation_map(visgrid),'URBAN');

%Prx
Prx_dBm=Ptx+Gtx+Grx-LFS;

%color devision  
signalColor=colorLegend(Prx_dBm);

figure('Name',FigName);
subplot(1,2,1);
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
hold on
title(Title);
xlabel('Latitude (º)');
ylabel('Longitude (º)');
zlabel('Elevation (m)');
scatter3(PointLong,PointLat,PointAlt,'filled','v','r','SizeData',200);
subplot(1,2,2);
imshow('z_Legend.jpg');
hold off
end

