 function [ a ] = deleteRepetation( a )
    leng=size(a);tempa=zeros(1,2);
    for i=1:leng(1)
        tempa=a(i,:);
        tempa=sort(tempa);
        a(i,:)=tempa;
    end
    deletionList=[1];
    while size(deletionList)>0
        deletionList=[];leng=size(a);
        for i=1:leng(1)
            tempa=a(i,:);
            for j=i+1:leng(1)
                if tempa==a(j,:)
                    deletionList=[deletionList j];
                end
            end
        end
        a(deletionList,:)=[];   
    end
    end