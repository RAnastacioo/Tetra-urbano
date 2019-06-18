function exportKmlBsLocations(B_STATIONS, filename)
% KML_BS_LOC Opens google earth and show the base station locations.
%   The function creates a KML file with a placemark for each base station
%       and open's it on google earth
%   Input argument:
%       --> Base Station struct Array with lat long coordinates 
%       --> Output File name

%filename = 'KML_BS_loc';
iconFilePath = fullfile(pwd, 'antenna.png');
iconFilePath = strrep(iconFilePath,'\','\\');
 
header = '<?xml version="1.0" encoding="utf-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2">\n\t<Document>\n\t\t';
footer = '\n\t</Document>\n</kml>';

fid = fopen(strcat(filename,'.kml'),'w');
fprintf(fid,header);
fprintf(fid,strcat('<name>',filename,'</name>\n'));

for i = 1:length(B_STATIONS(:,1))
    fprintf(fid,'\t\t<Placemark>\n');
    fprintf(fid,'\t\t\t<Point>\n\t\t\t\t<coordinates>%.7f,%.7f,0</coordinates>\n\t\t\t</Point>\n',B_STATIONS(i,1),B_STATIONS(i,2));
    fprintf(fid,'\t\t\t<Style>\n\t\t\t\t<IconStyle>\n\t\t\t\t\t<Icon>\n');
%      fprintf(fid,strcat('\t\t\t\t\t\t<img style="max-width:500px;" src="',iconFilePath,'>\n'));
     fprintf(fid,strcat('\t\t\t\t\t\t<href>',iconFilePath,'</href>\n'));
    fprintf(fid,'\t\t\t\t\t</Icon>\n\t\t\t\t</IconStyle>\n\t\t\t</Style>\n');
    fprintf(fid,'\t\t\t<styleUrl>#noDrivingDirections</styleUrl>\n');
    fprintf(fid,'\t\t</Placemark>\n');
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

