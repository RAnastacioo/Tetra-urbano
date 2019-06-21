function BestServerPixel(LATITUDE_NORTH,LATITUDE_SOUTH,LONGITUDE_EAST,LONGITUDE_WEST,SIGNAL_COVERAGE_LEVELS,FILE_NAME)
cenas=SIGNAL_COVERAGE_LEVELS;
cenas(isnan(SIGNAL_COVERAGE_LEVELS))=0;
RGB = label2rgb (cenas);
imwrite(RGB,[FILE_NAME '.png'],'Alpha',cenas);
% imwrite(SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_TRANSPARENT,[FILE_NAME '.png'],'Alpha',TRANSPARENCY_SIGNAL_COVERAGE_LEVELS);


%% ========================================================================
%% Create KML file
%% ========================================================================
fid_write = fopen([FILE_NAME '.kml'],'w');
fprintf(fid_write,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid_write,'<kml xmlns="http://earth.google.com/kml/2.1">\n');
fprintf(fid_write,'  <Folder>\n');
fprintf(fid_write,'   <name>Signal level - %s</name>\n',FILE_NAME);
fprintf(fid_write,'       <GroundOverlay>\n');
fprintf(fid_write,'		<Icon>\n');
fprintf(fid_write,'              <href>%s.png</href>\n',FILE_NAME);
fprintf(fid_write,'		</Icon>\n');
fprintf(fid_write,'            <LatLonBox>\n');
fprintf(fid_write,'               <north>%s</north>\n',num2str(LATITUDE_NORTH));
fprintf(fid_write,'               <south>%s</south>\n',num2str(LATITUDE_SOUTH));
fprintf(fid_write,'               <east>%s</east>\n',num2str(LONGITUDE_EAST));
fprintf(fid_write,'               <west>%s</west>\n',num2str(LONGITUDE_WEST));
fprintf(fid_write,'               <rotation>0.0</rotation>\n');
fprintf(fid_write,'            </LatLonBox>\n');
fprintf(fid_write,'       </GroundOverlay>\n');
fprintf(fid_write,'       <ScreenOverlay>\n');
fprintf(fid_write,'          <name>Color Key</name>\n');
fprintf(fid_write,'            <description>Contour Color Key</description>\n');
% fprintf(fid_write,'          <Icon>\n');
% fprintf(fid_write,'            <href>z_Legend.jpg</href>\n');
% fprintf(fid_write,'          </Icon>\n');
fprintf(fid_write,'          <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <size x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'       </ScreenOverlay>\n');
fprintf(fid_write,'  </Folder>\n');
fprintf(fid_write,'</kml>\n');
fclose(fid_write);
%  winopen(strcat(FILE_NAME,'.kml'))


if ismac
    % Code to run on Mac plaform
    cmd = 'open -a Google\ Earth ';
    fullfilename = fullfile(pwd, [FILE_NAME, '.kml']);
    system([cmd fullfilename]);
    
elseif ispc
    % Code to run on Windows platform
    winopen(strcat(FILE_NAME,'.kml'));
    
end
end

