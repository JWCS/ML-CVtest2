%Main
clear;
tic
threshold = 28;
Im = rot90( imread('H1.JPG'), -1 ); %Nature of the im, it's rotated (to me)
%Im2 = Filter(Im); %Will implement filter later, partly done by threshold
[ImMag, ImDir] = EdgeOperator( Im, 'sobel3' ); %Implement "names", use Im2
%It is type specific, the output should be ImMag, not Im3
ImMag = IsoPointRm( ImMag );
ImMag( ImMag < threshold ) = 0; %Can't do same for ImDir, manual rm
for i = 1: 10; [ImMag, ImDir] = DirExpansion( ImMag, ImDir ); end;
toc
image( ImMag )
%fancy plotting line following/finding stuff (Goal: begin no later than
%Wednesday)
toc
