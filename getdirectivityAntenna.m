function [directivityAngle]=getdirectivityAntenna(visgrid,row,col)

%getdirectivityAntenna
[rows columns numberOfColorBands] = size(visgrid);
croppedMatrixquadrant1 = visgrid(1:row, col:columns);
croppedMatrixquadrant2 = visgrid(1:row, 1:col);
croppedMatrixquadrant3 = visgrid(row:rows, 1:col);
croppedMatrixquadrant4 = visgrid(row:rows, col:columns);

numberOnes(1,1)=sum(sum(croppedMatrixquadrant1));
numberOnes(2,1)=sum(sum(croppedMatrixquadrant2));
numberOnes(3,1)=sum(sum(croppedMatrixquadrant3));
numberOnes(4,1)=sum(sum(croppedMatrixquadrant4));

[~,id]=max(numberOnes);

%getdirectivityAntenna
directivityAntennaBase=-90;
quadrant(1,1)=directivityAntennaBase+45;
quadrant(2,1)=quadrant(1,1)+90;
quadrant(3,1)=quadrant(2,1)+90;
quadrant(4,1)=quadrant(3,1)+90;

directivityAngle=quadrant(id,1);


end

