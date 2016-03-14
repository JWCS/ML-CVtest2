%Main
clear;
tic
threshold = 20;
Im = rot90( imread('H1.JPG'), -1 ); %Nature of the im, it's rotated (to me)
%Im2 = Filter(Im); %Will implement filter later, partly done by threshold
[ImMag, ImDir] = EdgeOperator( Im, 'sobel' ); %Implement "names", use Im2
Im3 = uint8( sqrt( ImMag( :, :, 1 )^2 + ImMag( :, :, 2 )^2 ) );
Im3( Im3 < threshold ) = 0;
toc
%Im3 = Expansion( Im3 );
image( Im3 )
%fancy plotting line following/finding stuff (Goal: begin no later than
%Wednesday)
toc
