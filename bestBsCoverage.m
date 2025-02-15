function [BS]=bestBsCoverage(elevation_map,lat_map,lng_map,R,passo,coverageTarget,f,Gtx,Grx,ptx,altAntena,prxMin,model,type,antennaType)
load('Antena400MhzGain13.mat');
Ptxdb = 10*log10(ptx/1e-3); % 100w
tic
i=1:passo:size(lat_map(:));

%% Map Resolution
NumberAntenas=['Antennas considered for study = ',num2str(length(i))];
MapResolution=['Map resolution = ',num2str(round((deg2km(distance(lat_map(1),lng_map(1),lat_map(2),lng_map(2)),'earth')*1000),2)),'metros'];
AntenasResolution=['Antenna resolution = ',num2str(round((deg2km(distance(lat_map(i(1)),lng_map(i(1)),lat_map(i(2)),lng_map(i(2))),'earth')*1000),2)),'metros'];


fig=figure('Name','Antennas considered for study');
fig.WindowState = 'maximized';
mesh(lng_map(1,:), lat_map(:,1), elevation_map);
title({NumberAntenas,MapResolution,AntenasResolution});
xlabel('Latitude (º)');
ylabel('Longitude (º)');
zlabel('Elevation (m)');
hold on
plot3(lng_map(i),lat_map(i),elevation_map(i),'r.','markersize',10);
hold off

%% visgrid(:,:,indx)
try
    load (['backup-' num2str(passo) '-' num2str(altAntena) '-' num2str(prxMin) '-' num2str(Gtx) '-' num2str(Grx)  '-' num2str(ptx) '-' num2str(model) '-' num2str(type) '-' antennaType]);
catch
    
    tic
    viewshed(elevation_map,R,lat_map(256),lng_map(256),9999999,1);
    maxVisgridTime=toc;
    s=seconds(round(length(i)*maxVisgridTime));
    s.Format = 'hh:mm:ss';
    fprintf('Dura��o prevista: %s \n',s);
    for j = i
        %visgrid(:,:,find(i==j))=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
        visgrid(:,:)=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
        % dist
        dist(:,:)=deg2km(distance(lat_map(j),lng_map(j),lat_map,lng_map),'earth');
        LS=NaN(size(dist));
        if model==1
            LS(visgrid(:,:))=PL_free(f,dist(visgrid(:,:)),Gtx,Grx);
        end
        if model==2
            LS(visgrid(:,:)) = PL_Hata_modify(f,dist(visgrid(:,:)).*1000,elevation_map(j)+altAntena,elevation_map(visgrid(:,:)),'URBAN');
        end
        if model==3
            LS(visgrid(:,:))=PL_IEEE80216d(f,dist(visgrid(:,:)).*1000,type,elevation_map(j)+altAntena,elevation_map(visgrid(:,:)),'Okumura','MOD');
        end
        if(isequal(antennaType, 'omni'))
            %% Prx
            Prx_dBm(:,:)=Ptxdb+Gtx+Grx-LS;
        end
        if(isequal(antennaType, 'dir'))
            %% getdirectivityAntenna
            [row,col]=find(lat_map==lat_map(j) & lng_map==lng_map(j) & elevation_map==elevation_map(j));
            [directivityAngle]=getdirectivityAntenna(visgrid,row,col);
            % 3D pattern antena
            %Angle azimuth(lat1,lon1,lat2,lon2)
            [az,elev,~] = geodetic2aer(lat_map,lng_map,elevation_map,lat_map(j),lng_map(j),(elevation_map(j)+altAntena),wgs84Ellipsoid);
            az1 = mod(round(az+directivityAngle), 359);
            elev1 = round(-elev + 90);
            % az=round(az);
            % elev= round(abs(elev-90));
            at = reshape(Antena400MhzGain13.Attenuation, 360, [])';
            Gtx1 = at(elev1 + az1.*181);
            % Prx
            Prx_dBm(:,:)=Ptxdb+Gtx+Gtx1+Grx-LS;
        end
        if(isequal(antennaType, 'dip'))
            % Prx
            load('dipolo.mat')
            [az,elev,~] = geodetic2aer(lat_map,lng_map,elevation_map,lat_map(j),lng_map(j),(elevation_map(j)+altAntena),wgs84Ellipsoid);
            az1 = mod(round(az), 359);
            elev1 = round(-elev + 90);
            Gtx1 = dipolo(elev1 + az1.*181);
            Prx_dBm(:,:)=Ptxdb+Gtx+Gtx1+Grx-LS;
        end
        %Prx_Min
        Prx_MinLogical=zeros(size(dist));
        Prx_MinLogical(Prx_dBm>prxMin)=1;
        %visgridwithPrMin(:,:,find(i==j))=and(A,visgrid(:,:,find(i==j)));
        visgridwithPrMin(:,:,find(i==j))=and(Prx_MinLogical,visgrid(:,:));
    end
    ss=seconds(round(toc));
    ss.Format = 'hh:mm:ss';
    fprintf('Dura��o real: %s \n',ss);
    save(['backup-' num2str(passo) '-' num2str(altAntena) '-' num2str(prxMin) '-' num2str(Gtx) '-' num2str(Grx)  '-' num2str(ptx) '-' num2str(model) '-' num2str(type) '-' antennaType],'visgridwithPrMin', '-v7.3');
    
end

try
    load(['BS_Coverage' num2str(coverageTarget) '-' num2str(passo) '-' num2str(altAntena) '-' num2str(prxMin) '-' num2str(Gtx) '-' num2str(Grx)  '-' num2str(ptx) '-' num2str(model) '-' num2str(type) '-' antennaType]);
catch
    
    %% Best BS1
    numberOnes(:,1)=sum(sum(visgridwithPrMin(:,:,:)));
    [maax,idxVisgrid1]=max(numberOnes);
    idxMap=i(idxVisgrid1);
    BS(1,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
    idxVisgrid(1,1)=idxVisgrid1;
    coverage=(maax/length(lng_map(:)))*100;
    k= visgridwithPrMin(:,:,idxVisgrid(1,1));
    
    %% Best BS
    %obtendo o segundo melhor ponto ignorando pontos de subreposi�ao
    ii=1;
    while coverage <= coverageTarget
        k=or(k,visgridwithPrMin(:,:,idxVisgrid(ii,1)));
        ii=ii+1;
        j=~and(k,visgridwithPrMin(:,:,:));
        x=and(j,visgridwithPrMin(:,:,:));
        numberOnes(:,1)=sum(sum(x(:,:,:)));
        [maax,idxVisgridd]=max(numberOnes);
        idxMap=i(idxVisgridd);
        coveragee=(maax/length(lng_map(:)))*100;
        BS(ii,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
        idxVisgrid(ii,1)=idxVisgridd;
        coverage=coverage+coveragee;
    end
    save(['BS_Coverage' num2str(coverageTarget) '-' num2str(passo) '-' num2str(altAntena) '-' num2str(prxMin) '-' num2str(Gtx) '-' num2str(Grx)  '-' num2str(ptx) '-' num2str(model) '-' num2str(type) '-' antennaType],'BS', '-v7.3');
end
