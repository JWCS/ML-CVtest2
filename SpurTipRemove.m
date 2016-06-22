function [OutMag] = SpurTipRemove( InOfMag )
%SPURTIPREMOVE Removes all points with one (end) or no (isolated point)
%neighbors. To delete spurs, run this itteratively. Assumes binary uint8
seen = logical( InOfMag ); 
neighbors = ones( 3, 3, 'single' ); neighbors(2,2) = 0;
NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
NeighborNo(NeighborNo < 2) = 0;
NeighborNo(NeighborNo > 0 ) = 1; 
OutMag = InOfMag; OutMag(~NeighborNo) = 0;