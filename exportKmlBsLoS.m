function exportKmlBsLoS(B_STATIONS, filename)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
LINE_COLOUR = 'afafafaf';
BALLON_COLOUR = '00664422';
TEXT_COLOUR = 'ff000000';
LINE_WIDTH = 5;


header = '<?xml version="1.0" encoding="utf-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2">\n\t<Document>\n';
footer = '\n\t</Document>\n</kml>';

fid = fopen(strcat(filename,'.kml'),'w');
fprintf(fid,header);
fprintf(fid,strcat('\t\t<name>',filename,'</name>\n'));

A=1:length(B_STATIONS(:,1));
B =1:length(B_STATIONS(:,1));
ab = [A B];
allcombs = nchoosek(ab,2);
combs = unique(allcombs, 'rows');
combs=deleteRepetation( combs );
for i=1:length (combs(:,1))
    if(combs(i,1)== combs(i,2))
        combs(i,1)=NaN;
        combs(i,2)=NaN;
    end
end
mask=~isnan(combs(:,1));
combs=combs(mask,:);

for i=1:length (combs(:,1))
    %% dist
    dist=deg2km(distance(B_STATIONS(combs(i,1),2),B_STATIONS(combs(i,1),1),B_STATIONS(combs(i,2),2),B_STATIONS(combs(i,2),1)),'earth');
    fprintf(fid,'\t\t<Placemark>\n');
    fprintf(fid,'\t\t\t<LineString>\n\t\t\t\t<coordinates>%.7f,%.7f,%i. %.7f,%.7f,%i.</coordinates>\n'...
        , B_STATIONS(combs(i,1),1), B_STATIONS(combs(i,1),2), B_STATIONS(combs(i,1),3),...
        B_STATIONS(combs(i,2),1), B_STATIONS(combs(i,2),2), B_STATIONS(combs(i,2),3));
    fprintf(fid,'\t\t\t\t<altitudeMode>relativeToGround</altitudeMode>\n');
    fprintf(fid,'\t\t\t</LineString>\n');
    fprintf(fid,'\t\t\t\t<Style>\n');
    fprintf(fid,'\t\t\t\t\t<LineStyle> <color>#%s</color> <width>%i</width> </LineStyle>\n',LINE_COLOUR,LINE_WIDTH);
    fprintf(fid,'\t\t\t\t\t<BalloonStyle>\n');
    fprintf(fid,'\t\t\t\t\t\t<bgColor>%s</bgColor> <textColor>%s</textColor>\n',BALLON_COLOUR,TEXT_COLOUR);
    fprintf(fid,'\t\t\t\t\t\t<text>Line of Sight betwen:<br/> %d and %d<br/>Distance: %.2fKm</text>\n',combs(i,1),combs(i,2),dist);
    fprintf(fid,'\t\t\t\t\t</BalloonStyle>\n');
    fprintf(fid,'\t\t\t\t</Style>\n');
    fprintf(fid,'\t\t</Placemark>\n\n');
end


fprintf(fid,footer);
fclose(fid);

if ismac
    % Code to run on Mac plaform
    cmd = 'open -a Google\ Earth ';
    fullfilename = fullfile(pwd, [filename, '.kml']);
    system([cmd fullfilename]);
    
elseif ispc
    % Code to run on Windows platform
    winopen(strcat(filename,'.kml'));
    
end

end

