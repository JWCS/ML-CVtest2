function [ OutMag ] = EndConnections( InOfMag, SearchBox )
%ENDCONNECTIONS Draws connections between line ends. Assume binary uint8
if (mod( SearchBox, 2 ) ==0) || (SearchBox < 5)
    error( 'SearchBox size must be odd and >=5' );
end
seen = logical( InOfMag ); 
neighbors = ones( 3, 'single' ); neighbors(2,2)=0;
search = ones( SearchBox, 'single' );
search((SearchBox-1)/2+1, (SearchBox-1)/2+1) = 0;
NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
Ends = (NeighborNo ==1);
EndNo = conv2( single( Ends ), search, 'same');
EndNo = logical( EndNo >1) & ~seen;
%OutMag = ZhangWangThin( InOfMag + cast((EndNo>1), 'like', InOfMag), 0 ) .* InOfMag;
OutMag = zeros( size( InOfMag ));
OutMag( logical(InOfMag + uint8(EndNo)) ) = 255;
OutMag = ZhangWangThin( uint8(OutMag), true );
end
