function [ OutMag ] = DirExpansion( InOfMag, InOfDir, IncludePointsBool )
%DirExpansion Expansion using the base original direction matrix. Assumes 
%binary uint8. Given a point or end, will chain search in the direction 
%given. OnlyEndsBool is true to only search off ends, false to also include 
%isolated points
tic
seen = logical( InOfMag ); [M, N] = size(seen); NewPoints=zeros(size(seen));
%NoOfWildChains = 4; %This is a precaution against an endless chain, or 10
neighbors = ones( 3, 'single' ); %Do not include neighbors(2,2)=0;
NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
valInd = find( (NeighborNo==2) + (IncludePointsBool&(NeighborNo==1)) );%of ValPoints
NewValInd = NextInDir( valInd, InOfDir( valInd ), seen, M, N );
NewPoints( NewValInd ) = 1; 
NewSeen = seen | NewPoints;
toc
while( size(NewValInd, 1) ~=0)%> NoOfWildChains )
    NeighborNo = conv2( single( NewSeen ), neighbors, 'same').*single(NewSeen);
    valInd = find( (NeighborNo==2) );%All iso points now would be lines
    NewValInd = NextInDir( valInd, InOfDir( valInd ), NewSeen, M, N );
    NewPoints( NewValInd ) = 1;
    NewSeen = NewSeen | NewPoints; disp(size(NewValInd, 1));
    toc
end
OutMag = uint8(NewSeen)*255; 
toc
end

function [newIndexVals] = NextInDir ( valInd, DirInd, Mat, Rows, Cols )
%NextInDir Given input of indeces, and the direction each points to, give
%new indeces to check, that are pointed to
%NextM and NextN of where the next point in Dir is; y=n right, x=m down
N=zeros(size(DirInd)); M=zeros(size(DirInd));
N( abs(DirInd)>=135-15 ) = -1; N( abs(DirInd)<=45+15 ) = 1; %Horizontal,increased defs by 15
M( (abs(DirInd)>=45) & (abs(DirInd)<=135) ) = -1;     %Vertical
M( (DirInd<0) & (M==1) ) = 1;
newIndexVals = int16( valInd + M + N*Rows );
newIndexVals( (newIndexVals>Rows*Cols) | (newIndexVals<1) ) = [];
newIndexVals( Mat(newIndexVals) == 1) = [];
end
%Loosened defs on N, check sols for diagnal increasing. This sometimes
%doesn't catch the obvious +1 pixel soln, end expansion would help after
%this, but after there's many spurs, eh. 