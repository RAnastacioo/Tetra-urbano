function [visgrid] = bestBsCoverage(elevation_map,lat_map,lng_map,R)
altAntena=30; %metros

for i=1:size(lat_map())
[visgrid,~]=viewshed(elevation_map,R,lat_map(i),lng_map(i),altAntena,1);
visgrid=logical(visgrid);


end

