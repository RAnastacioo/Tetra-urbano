function [combs] = combinationsWithoutRepeating(size1,size2)
A=1:size1;
B =1:size2;
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
end
 
