function [BS]=bestBsCoverage(elevation_map,lat_map,lng_map,R,coverageTarget)
%%Variaveis
f= 400e6; %Hz
Gtx=1; %db
Grx=1; % dB
Ptx = 10*log10(100/1e-3); % 100w
altAntena=30; %metros
prxMin=-100;

load('Antena400MhzGain13.mat');

passo=2000;
tic
i=1:passo:size(lat_map(:));
%% Map Resolution
fprintf('Resolution of possible antennas = %.2fkm \n',deg2km(distance(lat_map(i(1)),lng_map(i(1)),lat_map(i(2)),lng_map(i(2))),'earth'));
%% visgrid(:,:,indx)
try
    load (['backup_vigrid_passo_' num2str(passo)]);
catch
    figure;
    mesh(lng_map(1,:), lat_map(:,1), elevation_map);
    hold on
    plot3(lng_map(i),lat_map(i),elevation_map(i),'r.','markersize',10);
    hold off
    pause(2);
    tic
    viewshed(elevation_map,R,lat_map(256),lng_map(256),9999999,1);
    maxVisgridTime=toc;
    s=seconds(round(length(i)*maxVisgridTime));
    s.Format = 'hh:mm:ss';
    fprintf('Duração prevista: %s \n',s);
    for j = i
        %visgrid(:,:,find(i==j))=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
        visgrid(:,:)=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
        % dist
        dist(:,:)=deg2km(distance(lat_map(j),lng_map(j),lat_map,lng_map),'earth');
        % HATA
        LS=NaN(size(dist));
        %LS(visgrid(:,:,find(i==j))) = PL_Hata_modify(f,dist(visgrid(:,:,find(i==j))).*1000,elevation_map(j)+altAntena,elevation_map(visgrid(:,:,find(i==j))),'URBAN');
        LS(visgrid(:,:)) = PL_Hata_modify(f,dist(visgrid(:,:)).*1000,elevation_map(j)+altAntena,elevation_map(visgrid(:,:)),'URBAN');
        
        %% 3D pattern antena
        %Angle azimuth(lat1,lon1,lat2,lon2)
        [az,elev,~] = geodetic2aer(lat_map,lng_map,elevation_map,lat_map(j),lng_map(j),(elevation_map(j)+altAntena),wgs84Ellipsoid);
        az1 = mod(round(az), 359);
        elev1 = round(-elev + 90);
        % az=round(az);
        % elev= round(abs(elev-90));
        at = reshape(Antena400MhzGain13.Attenuation, 360, [])';
        Gtx = at(elev1 + az1.*181);  
        % Prx
        Prx_dBm(:,:)=Ptx+Gtx+Grx-LS;
        %Prx_Min
        Prx_MinLogical=zeros(size(dist));
        Prx_MinLogical(Prx_dBm>prxMin)=1;
        %visgridwithPrMin(:,:,find(i==j))=and(A,visgrid(:,:,find(i==j)));
        visgridwithPrMin(:,:,find(i==j))=and(Prx_MinLogical,visgrid(:,:));
    end
    ss=seconds(round(toc));
    ss.Format = 'hh:mm:ss';
    fprintf('Duração real: %s \n',ss);
    save(['backup_vigrid_passo_' num2str(passo)],'visgridwithPrMin', '-v7.3');
    
end

try
    load(['BS_Coverage' num2str(coverageTarget)]);
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
    %obtendo o segundo melhor ponto ignorando pontos de subreposiçao
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
    
    
    %     %% Best BS1
    %     numberOnes(:,1)=sum(sum(visgrid(:,:,:)));
    %     [maax,idxVisgrid1]=max(numberOnes);
    %     idxMap=i(idxVisgrid1);
    %     BS(1,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
    %     idxVisgrid(1,1)=idxVisgrid1;
    %     coverage=(maax/length(lng_map(:)))*100;
    %     k= visgrid(:,:,idxVisgrid(1,1));
    %
    %     %% Best BS
    %     %obtendo o segundo melhor ponto ignorando pontos de subreposiçao
    %     ii=1;
    %     while coverage <= coverageTarget
    %         k=or(k,visgrid(:,:,idxVisgrid(ii,1)));
    %         ii=ii+1;
    %         j=~and(k,visgrid(:,:,:));
    %         x=and(j,visgrid(:,:,:));
    %         numberOnes(:,1)=sum(sum(x(:,:,:)));
    %         [maax,idxVisgridd]=max(numberOnes);
    %         idxMap=i(idxVisgridd);
    %         coveragee=(maax/length(lng_map(:)))*100;
    %         BS(ii,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
    %         idxVisgrid(ii,1)=idxVisgridd;
    %         coverage=coverage+coveragee;
    %     end
    save(['BS_Coverage' num2str(coverageTarget)],'BS', '-v7.3');
end
