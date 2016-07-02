function [OutMag] = SpurTipRemove( InOfMag )
%SPURTIPREMOVE Removes all points with one (end) or no (isolated point)
%neighbors. To delete spurs, run this itteratively. 
%Assumes sparse logical matrix (no diff if double, can still work if full)
neighbors = ones( 3, 3, 'double' ); neighbors(2,2) = 0;
NeighborNo = conv2( full(double( InOfMag )), neighbors, 'same').*double(InOfMag);
NeighborNo(NeighborNo ==1 ) = 0;
NeighborNo(NeighborNo > 0 ) = 1; 
OutMag = sparse( logical( NeighborNo ));