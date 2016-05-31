function [ Im2 ] = MedianFilter( Im, side )
%MedianFilter Median Filter of an Image, side is size of median chunk
    if ~(side==3 || side==5); error( 'wrong value for side' ); end;
    s = ( side -1 )/2; [ M, N, Z ] = size( Im ); 
    ImProc = zeros( M + 2*s, N + 2*s, Z ); Im2 = zeros( size( Im ), 'uint8' );
    Column = zeros( side^2, M*N, Z );
    for z = 1:Z
        ImProc(:,:, z ) = padarray( Im(:,:, z ), [s, s] );
        Column(:,:, z ) = im2col( ImProc( :,:, z ), [side, side], 'sliding' );
        Im2(:,:, z ) = uint8( col2im( median( Column(:,:, z ), 1 ), ...
            [side, side], size(ImProc), 'sliding' ) );
    end
end