function result= makeLevelEqualBounds(list,m, fn)
%-----------------------------------------------------------------------
% prefer makeLevelEqualBoundsMean if using the nanmean function
%Goal of the function: makes levels on a continuous variable (1st column)
%It will make m levels with equal number of the continuous data.
%Then it applies the fn (ex, sum, mean...) to the second column of list
%Each data in the first is associated with the second.
%In the third column, you get the data number.
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
%Last edit:
%
%Function created by Adrien Chopin in may 2008
%Project: BPL07
%With: Pascal Mamassian
%-----------------------------------------------------------------------
%_______________________________________________________________________

list=list(isnan(list(:,1))==0,:);
X=sortrows(list,1);
n=size(X,1);
nbDataByLevels=round(n./m);
j=1;
result=zeros(m,3);
for i=1:m
    if (j+nbDataByLevels-1)>n || i==m
        result(i,:)=[nanmean((X(j:end,1))),eval([fn,'(X(j:end,2))']),numel(X(j:end,1))];
    else
        result(i,:)=[nanmean((X(j:(j+nbDataByLevels-1),1))),eval([fn,'(X(j:(j+nbDataByLevels-1),2))']),nbDataByLevels];
    end
    j=j+nbDataByLevels;
end

