function varargout = mat2png(varargin)
%mat2png(Array, FileName) generates and saves a image on the
%script/function directory corresponding to the array data.
%   INPUTS
%     Array : The array to be mapped into a image
%     FileName : The name of the output image file
%     colormap : The colormap name used to map the array. Default: parula.
%     format : The file format in which the file is saved as. Default: png
%     contrast : Data mapping contrast
%     notRenderColors : The index of the colormap colors you want to make
%     transparent. Default: Render all

p = inputParser;

defaultColorMap = parula(256);
defaultFormat = 'png';
defaultContrast = 256;
defaultRenderColors = [];
defaultLegend = "auto";
defaultColorsTransparency = 1;
defaultRenderNaNs = 0;

addRequired(p, 'array', @(x) validateattributes(x,{'double'},{'nonempty', '2d'}));
addRequired(p, 'filename', @ischar);
addParameter(p, 'colormap', defaultColorMap, @(x) validateattributes(x,{'numeric'},{'ncols', 3, 'nonempty', 'nonnegative'}));
addParameter(p, 'format', defaultFormat);
addParameter(p, 'contrast', defaultContrast, @(x) validateattributes(x,{'numeric'},{'nonempty', 'nonnegative'}));
addParameter(p, 'notRenderColors', defaultRenderColors, @(x) validateattributes(x,{'numeric'},{'vector', 'nonempty', 'positive'}));
addParameter(p, 'legend', defaultLegend, @(x) validateattributes(x,{'string'},{'nonempty'}));
addParameter(p, 'renderColorsTransparency', defaultColorsTransparency, @(x) validateattributes(x,{'numeric'},{'scalar', '>=', 0, '<=', 1}));
addParameter(p, 'renderNaNs', defaultRenderNaNs, @(x) validateattributes(x,{'logical'},{'nonempty'}));

parse(p, varargin{:});

array = p.Results.array;
filename = p.Results.filename;
color_map = p.Results.colormap;
fileformat = p.Results.format;
contrast = p.Results.contrast;
notRenderColors = p.Results.notRenderColors;
legend = p.Results.legend;

% Gets the color map. The Maximum colors are 256.
if (length(color_map)>256)
    color_map = defaultColorMap;
    warning('The color map will be the default because the color map you entered have more than 256 colors.');
elseif (length(color_map)<256)
    repeat = ceil(256/size(color_map, 1));
    color_map_aux = repelem(color_map, repeat, 1);
    color_map = color_map_aux(1:256, :);
end

if any(any(color_map>1) | any(color_map<0))
    color_map = scaledata(color_map, 0, 1);
end


width_bar = 10^(numel(num2str(length(array)))-1);
colorbar_array = NaN(width_bar, length(array));
for i=1:width_bar
    % Gets the color bar "values"
    colorbar_array(i,:) = linspace(min(min(array)), max(max(array)), length(array));
end

scaled_array = scaledata(array, 0, contrast);
scaled_colorbar_array = scaledata(colorbar_array, 0, contrast);

% Transparency Map -> NaN will be transparent.
transparency_map = ones(length(color_map), 1) * p.Results.renderColorsTransparency;
if ~p.Results.renderNaNs && any(isnan(array(:))==1)
    transparency_map(1) = 0;
end
    
if ~isempty(notRenderColors)
    %Prevents floating point indexes
    notRenderColors = unique(round(notRenderColors));
    
    if any(notRenderColors)>length(color_map)
        warning('notRenderColors range must be on the colormap range! Not rendering from the lowest element untill length of colormap.');
        notRenderColors = min(notRenderColors):length(color_map);
    end
    
    transparency_map(notRenderColors) = 0;
end

% Saves the image.
imwrite(scaled_array, color_map, [filename, '_map.', fileformat], fileformat, 'Transparency', transparency_map);
imwrite(scaled_colorbar_array', color_map, [filename, '_bar.', fileformat], fileformat);

if strcmp(legend, defaultLegend)
    if (length(array)<76); TxtSize = 2; Div=3; elseif (length(array)<121); TxtSize = 4; Div=4;
    elseif (length(array)<201); TxtSize = 8; Div=5; elseif (length(array)<351); TxtSize = 10; Div=6; 
    else;  TxtSize = 14; Div=7; end
    
    [bar, map] = imread([filename, '_bar.', fileformat]);
    if ~isempty(map); bar = ind2rgb(bar,map); end
    
    values2print = linspace(min(min(array)), max(max(array)), Div);
    vertposition2print = round(linspace(1, length(scaled_colorbar_array), Div));
    
    position = ones(length(vertposition2print), 2);
    position(:,2) = vertposition2print;
    
    bar(position(:,2),:,:) = 1;
    
    position(length(position),2) = position(length(position),2) - TxtSize*2;
    new_bar = insertText(bar, position, values2print, 'FontSize', TxtSize, 'BoxColor', 'white', 'BoxOpacity', 0.4);
    
    imwrite(new_bar, map, [filename, '_bar.', fileformat], fileformat);
end

if nargout==1
    varargout{1} = [filename, '_map_.', fileformat];
elseif nargout==2
    varargout{1} = [filename, '_map.', fileformat];
    varargout{2} = [filename, '_bar.', fileformat];
end

end