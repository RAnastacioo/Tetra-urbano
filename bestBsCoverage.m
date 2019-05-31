function BS1=bestBsCoverage(elevation_map,lat_map,lng_map,R)
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
[maax,idx]=max(numberOnes);
idx1=i(idx);
BS1=[lng_map(idx1),lat_map(idx1),elevation_map(idx1)];
coverageBS1=(maax/length(lng_map(:)))*100;


end
