
function [BScoordinates] = getpts3d(lat_map,lng_map,elevation_map)

fig = figure;
fig.WindowState = 'maximized';
mesh(lng_map,lat_map,elevation_map);
hold on
title({'Choose your base stations','Click display to create a data tip, press shift+mouseleft for any points, then press "Return"'});
xlabel('Latitude (º)');
ylabel('Longitude (º)');
zlabel('Elevation (m)');
% Initialize data cursor object
cursorobj = datacursormode(fig);
cursorobj.SnapToDataVertex = 'on'; % Snap to our plotted data, on by default

disp('Click display to create a data tip, press shift+mouseleft for any points, then press "Return"')
while ~waitforbuttonpress 
  keydown= waitforbuttonpress;
    % waitforbuttonpress returns 0 with click, 1 with key press
    % Does not trigger on ctrl, shift, alt, caps lock, num lock, or scroll lock
    cursorobj.Enable = 'on'; % Turn on the data cursor, hold alt to select multiple points
end
cursorobj.Enable = 'off';
mypoints = getCursorInfo(cursorobj);
BScoordinates = cell2mat({mypoints.Position}');
close(fig);
end

