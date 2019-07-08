clearvars;clc;close all;
SAMPLES = 512;
%%Variaveis
f= 400e6; %Hz
Gtx=1; %db
Grx=1; % dB
Ptx=100;%w
altAntena=30; %metros
prxMin=-90;
coverageTarget=95;
passo=200; 
load('backup_512.mat');
type='A';
antennaType='';

%% prints & disp
plotIndividualAntenna = false;
plotAllAntennas=true;
exportKML=true;
CCanal=false;

%% Map Resolution
fprintf('Map resolution = %.2fmetros \n',deg2km(distance(lat_map(11),lng_map(11),lat_map(12),lng_map(12)),'earth')*1000);

fprintf('Map area = %.2fkm2 \n',deg2km(distance(lat_map(1,1),lng_map(1,1),lat_map(1,512),lng_map(1,512)),'earth')*deg2km(distance(lat_map(1,1),lng_map(1,1),lat_map(512,1),lng_map(512,1)),'earth'));

%% All Line-of-sight 5isibility points in terrain
latlim = [min(lat_map(:)), max(lat_map(:))];
lonlim = [min(lng_map(:)), max(lng_map(:))];
rasterSize = size(elevation_map);
%GEOREFCELLS Reference raster cells to geographic coordinates
R = georefpostings(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');
disp('------------------------------------')
while (true)
    disp('Choose radio propagation model for predicting the path loss')
    disp('1 - Free Path Loss \n');
    disp('2 - Okumura/Hata \n');
    disp('3 - IEEE 802.16d \n');
    str = input('Insert 1, 2 or 3 -> ','s');
    str = lower(str);
    switch str
        case '1'
            disp(' Free Path Loss')
            model=1;
            break;
        case '2'
            disp('Okumura/Hata')
            model=2;
            break;
        case '3'
            
            disp('IEEE 802.16d')
            model=3;
            disp('------------------------------------')
            while (true)
                disp('Choose the TYPE')
                disp('A - for hilly terrain with moderate-to-heavy tree densities \n');
                disp('B - for intermediate path loss conditions \n');
                disp('C - for flat terrain with light tree densities \n');
                str = input('Insert A, B or C -> ','s');
                str = lower(str);
                switch str
                    case 'a'
                        disp('TYPE A')
                        type='A';
                        break;
                    case 'b'
                        disp('TYPE B')
                        type='B';
                        break;
                    case 'c'
                        disp('TYPE C')
                        type='C';
                    otherwise
                        disp('It is necessary to choose the TYPE')
                end
            end
            break;
        otherwise
            disp('It is necessary to choose the model')
    end
end
disp('------------------------------------')
while (true)
    
    fig=figure('Name','Antenna Patern Atenuação 3D');
    subplot(1,2,1);
    title('Dipole');
    antennaObject = design(dipole,f);
    plotFrequency = 400000000;
    [efield,az,el]=pattern(antennaObject, plotFrequency);
    patternCustom(efield',(90-el),az');

    subplot(1,2,2);
    load('Antena400MhzGain13.mat');
    title('Directive');
    patternCustom(Antena400MhzGain13.Attenuation,Antena400MhzGain13.Vert_Angle,Antena400MhzGain13.Hor_Angle);
    
    disp('Choose antenna model')
    str = input('Insert dipolo(dip) or Directive Antenna(dir) -> ','s');
    str = lower(str);
    switch str
        case 'dip'
            disp('Dipolo')
            antennaType=str;
            break;
        case 'dir'
            disp('Directive Antenna')
            antennaType=str;
            break;
        otherwise
            disp('It is necessary to choose the operating mode')
    end
end
disp('------------------------------------')
while (true)
    disp('Choose the mode of placement of antennas between manual or automatic.')
    str = input('Insert manual or auto -> ','s');
    str = lower(str);
    switch str
        case 'manual'
            disp('Manual mode')
            [BS] = getpts3d(lat_map,lng_map,elevation_map);
            break;
        case 'auto'
            disp('Automatic mode')
            [BS]=bestBsCoverage(elevation_map,lat_map,lng_map,R,passo,coverageTarget,f,Gtx,Grx,Ptx,altAntena,prxMin,model,type,antennaType);
            break;
        otherwise
            disp('It is necessary to choose the operating mode')
    end
end
disp('------------------------------------')
Prx_dBmBS=NaN(size(lat_map));
visgridBS=NaN(size(lat_map));
visgridALL=zeros(size(lat_map));
for i=1:length (BS(:,1))
    [Prx_dBmBS(:,:,i),visgridBS(:,:,i)] = Antena(['BS',num2str(i)],['BS',num2str(i)],BS(i,:),elevation_map,lat_map,lng_map,R,f,Gtx,Grx,Ptx,altAntena,prxMin,plotIndividualAntenna,model,type,antennaType);
    visgridALL=or (visgridALL,visgridBS(:,:,i));
end

N = length (BS(:,1));
if(plotAllAntennas || N>20)
    %% All antennas
    figure('Name','All antennas on the ground');
    nS   = sqrt(N);
    nCol = ceil(nS);
    nRow = nCol - (nCol * nCol - N > nCol - 1);
    for k = 1:N
        subplot(nRow, nCol, k);
        %Coverage
        numberOnes(:,1)=sum(sum(visgridBS(:,:,k)));
        coverage=round((max(numberOnes/length(lng_map(:)))*100));
        % color devision | Plot
        signalColor=colorLegend(Prx_dBmBS(:,:,k));
        axis tight
        mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
        hold on
        title(strcat(['BS',num2str(k),' - Coverage: ',num2str(coverage),'%']));
        xlabel('Latitude (º)');
        ylabel('Longitude (º)');
        zlabel('Elevation (m)');
        scatter3(BS(k,1),BS(k,2),BS(k,3)+altAntena,'filled','v','m','SizeData',200);
        hold off
    end
end
visgridBS=logical(visgridBS);
%% BestBSCoverage
[~,bestServerPixel]=max(Prx_dBmBS,[],3);
bestServerPixel(~visgridALL)=NaN;

fig=figure('Name','BestServerPixel');
fig.WindowState = 'maximized';
surf(lng_map(1,:), lat_map(:,1), elevation_map,'DisplayName','','HandleVisibility','off');
hold on
for i=1:length (BS(:,1))
    str=['BS',num2str(i)];
    plot3(lng_map(bestServerPixel==i),lat_map(bestServerPixel==i),elevation_map(bestServerPixel==i),'*','DisplayName',str);
end
lgd=legend;
lgd.FontSize = 14;
lgd;
title('BestServerPixel');
hold off

%% PRX
Prx_dBm=NaN(size(lat_map));
serverVisgrid=zeros(size(lat_map));
for i=1:length (BS(:,1))
    serverVisgrid=logical(bestServerPixel==i);
    auxprx=Prx_dBmBS(:,:,i);
    Prx_dBm(serverVisgrid)=auxprx(serverVisgrid);
end

%% Co-Canal

if(CCanal)
Sub=NaN(size(visgridBS(:,:,1)));
CoCanal = "-----------------";
CoCanal =  [CoCanal;"Co-channel interference (Mean Value)"];
CoCanal = [CoCanal ; "-----------------"];
for i=1:length (BS(:,1))
    for j=1:length (BS(:,1))
        if(j~=i)
            Sub=and(visgridBS(:,:,i),visgridBS(:,:,j));
            CC=10.^((Prx_dBmBS(:,:,i))./10).*Sub;
            II=10.^((Prx_dBmBS(:,:,j))./10).*Sub;
            XX=CC./II;
            CI_=XX(XX<=1);
            %           CI=CI_(CI_>=0);% nao tenho a certeza se metemos esta linha ou nao (meti pq dava valor negativo sem ela)
            CI_m=round(mean(CI_,'omitnan'),2);
            CoCanal = [CoCanal ; 'BS',num2str(i) ' with BS',num2str(j) '=',num2str(CI_m)];
            %             fprintf('BS%d c/ BS%d = %.2f \n',i,j,CI_m);
        end
    end
    CoCanal = [CoCanal ; "-----------------"];
end
disp(CoCanal);
end
%% Coverage Area
coverageTotal=logical(visgridALL);
numberOnes(:,1)=sum(sum(coverageTotal));
coverageTotal=round((max(numberOnes/length(lng_map(:)))*100));

%% color devision
signalColor=colorLegend(Prx_dBm);
%% Displays the data
fig=figure('Name','ALL BS');
fig.WindowState = 'maximized';
subplot(1,2,1);
axis tight
mesh(lng_map(1,:), lat_map(:,1), elevation_map,signalColor);
hold on
title(strcat(['Coverage map : ',num2str(coverageTotal),'%']));
xlabel('Latitude (Âº)');
ylabel('Longitude (Âº)');
zlabel('Elevation (m)');
for i=1:length (BS(:,1))
    scatter3(BS(i,1),BS(i,2),BS(i,3)+10,'filled','v','m','SizeData',200);
end
hold off
subplot(1,2,2);
imshow('z_Legend.jpg');

%% KML file
if(exportKML)
exportKmlBsLocations(BS, 'BsLocations');
BestServerPixel(lat_map(1),lat_map(SAMPLES,SAMPLES),lng_map(1),lng_map(SAMPLES,SAMPLES),bestServerPixel,'BestServerPixel');
AA_func(lat_map(1),lat_map(SAMPLES,SAMPLES),lng_map(1),lng_map(SAMPLES,SAMPLES),Prx_dBm,'Coverage_map');
% exportKmlBsLoS(BS, 'Los');
end