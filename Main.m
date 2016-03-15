%Main
clear;
tic
threshold = 28;
Im = rot90( imread('H1.JPG'), -1 ); %Nature of the im, it's rotated (to me)
%Im2 = Filter(Im); %Will implement filter later, partly done by threshold
[ImMag, ImDir] = EdgeOperator( Im, 'sobel3' ); %Implement "names", use Im2
%It is type specific, the output should be ImMag, not Im3
ImMag( ImMag < threshold ) = 0;
toc
%Im3 = Expansion( Im3 );
image( ImMag )
%fancy plotting line following/finding stuff (Goal: begin no later than
%Wednesday)
toc
