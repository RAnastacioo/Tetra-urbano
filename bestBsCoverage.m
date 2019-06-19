function [BS]=bestBsCoverage(elevation_map,lat_map,lng_map,R,coverageTarget,altAntena)
passo=200;
 
tic
i=1:passo:size(lat_map(:));
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
        visgrid(:,:,find(i==j))=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
    end
    ss=seconds(round(toc));
    ss.Format = 'hh:mm:ss';
    fprintf('Duração real: %s \n',ss);
    save(['backup_vigrid_passo_' num2str(passo)],'visgrid', '-v7.3');
    
end

try
    load(['BS_Coverage' num2str(coverageTarget)]);
catch
    %% Best BS1
    numberOnes(:,1)=sum(sum(visgrid(:,:,:)));
    [maax,idxVisgrid1]=max(numberOnes);
    idxMap=i(idxVisgrid1);
    BS(1,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
    idxVisgrid(1,1)=idxVisgrid1;
    coverage=(maax/length(lng_map(:)))*100;
    
    if(coverage<=coverageTarget)
        %% Best BS2
        %obtendo o segundo melhor ponto ignorando pontos de subreposiçao
        j=~and(visgrid(:,:,idxVisgrid1),visgrid(:,:,:));
        x=and(j,visgrid(:,:,:));
        numberOnes2(:,1)=sum(sum(x(:,:,:)));
        [maax2,idxVisgrid2]=max(numberOnes2);
        idxMap2=i(idxVisgrid2);
        BS(2,:)=[lng_map(idxMap2),lat_map(idxMap2),elevation_map(idxMap2)];
        idxVisgrid(2,1)=idxVisgrid2;
        coverage=coverage+(maax2/length(lng_map(:)))*100;
    end
    
    if(coverage<=coverageTarget)
        %% Best BS3
        %obtendo o segundo melhor ponto ignorando pontos de subreposiçao
        k=or(visgrid(:,:,idxVisgrid2),visgrid(:,:,idxVisgrid1));
        j=~and(k,visgrid(:,:,:));
        x=and(j,visgrid(:,:,:));
        numberOnes3(:,1)=sum(sum(x(:,:,:)));
        [maax3,idxVisgrid3]=max(numberOnes3);
        idxMap3=i(idxVisgrid3);
        BS(3,:)=[lng_map(idxMap3),lat_map(idxMap3),elevation_map(idxMap3)];
        coverage=coverage+(maax3/length(lng_map(:)))*100;
        idxVisgrid(3,1)=idxVisgrid3;
    end
   
    %% Best BS4
    %obtendo o segundo melhor ponto ignorando pontos de subreposiçao
    ii=3;
    while coverage <= coverageTarget
        k=or(k,visgrid(:,:,idxVisgrid(ii,1)));
        ii=ii+1;
        
        j=~and(k,visgrid(:,:,:));
        x=and(j,visgrid(:,:,:));
        numberOnes(:,1)=sum(sum(x(:,:,:)));
        [maax,idxVisgridd]=max(numberOnes);
        idxMap=i(idxVisgridd);
        coveragee=(maax/length(lng_map(:)))*100;
        BS(ii,:)=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
        idxVisgrid(ii,1)=idxVisgridd;
        coverage=coverage+coveragee;
    end
    save(['BS_Coverage' num2str(coverageTarget)],'BS', '-v7.3');
end
end
