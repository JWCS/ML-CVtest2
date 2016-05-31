function [ List ] = Line( InOfMag, InOfDir )
%LINE Generates list of lines in image
seen = logical( InOfMag ); 
neighbors = ones(3, 'single'); neighbors(2, 2) = 0;
NeighborNo = conv2( single(seen), neighbors, 'same' ) .* single(seen);
if sum(sum( NeighborNo >3, 1), 2) ~=0; error('Is not reduced, THIN'); end;
Edges = (NeighborNo==2);
Crit = (NeighborNo==1)*2 + (NeighborNo==3)*3; %Critical Points are ends and splits

end

