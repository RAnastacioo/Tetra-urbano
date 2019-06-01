function [BS1,BS2,BS3,BS4]=bestBsCoverage(elevation_map,lat_map,lng_map,R)
altAntena=30; %metros
passo=200;
tic
i=1:passo:size(lat_map(:));
% figure;
% mesh(lng_map(1,:), lat_map(:,1), elevation_map);
% hold on
% plot3(lng_map(i),lat_map(i),elevation_map(i),'r.','markersize',10);
% hold off

%% visgrid(:,:,indx)
try
    load (['backup_vigrid_passo_' num2str(passo)]);
catch
    tic
    viewshed(elevation_map,R,lat_map(256),lng_map(256),9999999,1);
    maxVisgridTime=toc;
    s=seconds(round(length(i)*maxVisgridTime));
    s.Format = 'hh:mm:ss';
    fprintf('Maxima duração prevista: %s \n',s);
    for j = i
        visgrid(:,:,find(i==j))=logical(viewshed(elevation_map,R,lat_map(j),lng_map(j),altAntena,1));
    end
    ss=seconds(round(toc));
    ss.Format = 'hh:mm:ss';
    fprintf('Duração real: %s \n',ss);
    save(['backup_vigrid_passo_' num2str(passo)],'visgrid');
end

%% Best BS1
numberOnes(:,1)=sum(sum(visgrid(:,:,:)));
[maax,idxVisgrid]=max(numberOnes);
idxMap=i(idxVisgrid);
BS1=[lng_map(idxMap),lat_map(idxMap),elevation_map(idxMap)];
coverageBS1=(maax/length(lng_map(:)))*100;

%% Best BS2
%obtendo o segundo melhor ponto ignorando pontos de subreposiçao 
j=~and(visgrid(:,:,idxVisgrid),visgrid(:,:,:));
x=and(j,visgrid(:,:,:));
numberOnes2(:,1)=sum(sum(x(:,:,:)));
[maax2,idxVisgrid2]=max(numberOnes2);
idxMap2=i(idxVisgrid2);
BS2=[lng_map(idxMap2),lat_map(idxMap2),elevation_map(idxMap2)];
coverageBS2=(maax2/length(lng_map(:)))*100;

%% Best BS3
%obtendo o segundo melhor ponto ignorando pontos de subreposiçao 
k=or(visgrid(:,:,idxVisgrid2),visgrid(:,:,idxVisgrid));
j=~and(k,visgrid(:,:,:));
x=and(j,visgrid(:,:,:));
numberOnes3(:,1)=sum(sum(x(:,:,:)));
[maax3,idxVisgrid3]=max(numberOnes3);
idxMap3=i(idxVisgrid3);
BS3=[lng_map(idxMap3),lat_map(idxMap3),elevation_map(idxMap3)];
coverageBS3=(maax3/length(lng_map(:)))*100;

%% Best BS4
%obtendo o segundo melhor ponto ignorando pontos de subreposiçao 
k=or(k,visgrid(:,:,idxVisgrid3));
j=~and(k,visgrid(:,:,:));
x=and(j,visgrid(:,:,:));
numberOnes4(:,1)=sum(sum(x(:,:,:)));
[maax4,idxVisgrid4]=max(numberOnes4);
idxMap4=i(idxVisgrid4);
BS4=[lng_map(idxMap4),lat_map(idxMap4),elevation_map(idxMap4)];
coverageBS4=(maax4/length(lng_map(:)))*100;

end
