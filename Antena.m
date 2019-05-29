function [Prx_dBm,visgrid] = Antena(FigName,Title,PointLong,PointLat,PointAlt,elevation_map,lat_map,lng_map,R)
%%Variaveis
f= 400e6; %Hz
c=3e8; %m/s
lambda=c/f;%m
Gtx=1; %db
Grx=1; % dB
Ptx=50; %dBm 100w
altAntena=30; %metros
load('Antena400MhzGain13.mat');

[visgrid,~]=viewshed_nova(elevation_map,R,PointLat,PointLong,altAntena,1);
visgrid=logical(visgrid);

%dist
dist=deg2km(distance(PointLat,PointLong,lat_map,lng_map),'earth');
%disTerrestre=dist;
dist=sqrt(abs((PointAlt-dist)).^2+(dist.*1000).^2)/1000;

%HATA
LFS=NaN(size(dist));
LFS(visgrid)=PL_Hata_modify(f,dist(visgrid).*1000,PointAlt,elevation_map(visgrid),'URBAN');

%Angle azimuth(lat1,lon1,lat2,lon2)
%wgs84Ellipsoid;
[az,elev,~] = geodetic2aer(lat_map,lng_map,elevation_map,PointLat,PointLong,(PointAlt+altAntena),wgs84Ellipsoid);
az=round(az);
elev=elev+90;
elev=round(elev);


%3D pattern antena
 LFSssss=NaN(size(dist));
tic
 for i=1:512
    for j=1:512
   dd=ismember(Antena400MhzGain13.Vert_Angle,elev(j,i)) & ismember(Antena400MhzGain13.Hor_Angle,az(j,i));
   if(find(dd==1))
     LFSssss(j,i)= Antena400MhzGain13.Attenuation(find(dd==1));
   end
    end
 end
toc

% LFSssss=LFSssss(:);
% tic
%  for i=1:512*512
%    dd=ismember(Antena400MhzGain13.Vert_Angle,elev(i)) & ismember(Antena400MhzGain13.Hor_Angle,az(i));
%    if(find(dd==1))
%      LFSssss(i)= Antena400MhzGain13.Attenuation(find(dd==1));
%    end
%  end
% 
% LFSssss=reshape(LFSssss,[512,512]);
% toc


%ang.hotizontal
% figure;
% mesh(lng_map(1,:), lat_map(:,1), az);

%ang.verical
% figure;
% mesh(lng_map(1,:), lat_map(:,1), elev);

%Prx
% Prx_dBm=Ptx+Gtx+Grx-LFS;
Prx_dBm=Ptx+LFSssss+Gtx+Grx-LFS;

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

