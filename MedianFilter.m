function [ OutIm ] = MedianFilter( InOfIm, side )
%MedianFilter Median Filter of an Image, side is size of median chunk
if ~(side==3 || side==5); error( 'wrong value for side' ); end;
Temp = InOfIm( 1: size(InOfIm, 1)-mod( size(InOfIm, 1), side ), ...
                        1: size(InOfIm, 2)-mod(size(InOfIm, 2), side ), :);
s = ( side -1 )/2; [ M, N, Z ] = size( Temp );
ImProc = zeros( M + 2*s, N + 2*s, Z ); OutIm = zeros( size( Temp ), 'uint8' );
Column = zeros( side^2, M*N, Z );
for z = 1:Z
    ImProc(:,:, z ) = padarray( Temp(:,:, z ), [s, s] );
    Column(:,:, z ) = im2col( ImProc( :,:, z ), [side, side], 'sliding' );
    OutIm(:,:, z ) = uint8( col2im( median( Column(:,:, z ), 1 ), ...
        [side, side], size(ImProc), 'sliding' ) );
end
end