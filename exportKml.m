function exportKml(Coord1, Coord2, figureName, colorBarName, outputFileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 
% Create KML File
fid_write = fopen([outputFileName '.kml'],'w');
fprintf(fid_write,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid_write,'<kml xmlns="http://earth.google.com/kml/2.1">\n');
fprintf(fid_write,'  <Folder>\n');
fprintf(fid_write,'     <name>Overlay - %s</name>\n', figureName);
fprintf(fid_write,'         <GroundOverlay>\n');
fprintf(fid_write,'             <Icon>\n');
fprintf(fid_write,'                 <href>%s</href>\n', figureName);
fprintf(fid_write,'             </Icon>\n');
fprintf(fid_write,'             <LatLonBox>\n');
fprintf(fid_write,'                 <north>%s</north>\n', num2str(Coord1(1)));
fprintf(fid_write,'                 <south>%s</south>\n', num2str(Coord2(1)));
fprintf(fid_write,'                 <east>%s</east>\n',   num2str(Coord2(2)));
fprintf(fid_write,'                 <west>%s</west>\n',   num2str(Coord1(2)));
fprintf(fid_write,'                 <rotation>0.0</rotation>\n');
fprintf(fid_write,'             </LatLonBox>\n');
fprintf(fid_write,'         </GroundOverlay>\n');
fprintf(fid_write,'     <ScreenOverlay>\n');
fprintf(fid_write,'         <name>Color Bar - %s</name>\n', colorBarName);
fprintf(fid_write,'             <description>Color Bar</description>\n');
fprintf(fid_write,'             <Icon>\n');
fprintf(fid_write,'                 <href>%s</href>\n', colorBarName);
fprintf(fid_write,'             </Icon>\n');
fprintf(fid_write,'          <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <size x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'     </ScreenOverlay>\n');
fprintf(fid_write,'  </Folder>\n');
fprintf(fid_write,'</kml>\n');

end

