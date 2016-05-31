%Main
%Editable values: threshold, i (No of itterations of expansion), j (search
%size for end connections, larger causes more spurs, fix sometime), 
clear;
tic
threshold = 130; filterRegSide = 5; % Apparently can only be 3||5, memory
Im = rot90( imread('H1.JPG'), -1 ); %Nature of the im, it's rotated (to me)
Im2 = Im( 1: size(Im, 1)-mod(size(Im, 1),15), 1: size(Im, 2)-mod(size(Im, 2),15), :);
Im2 = MedianFilter(Im2, filterRegSide); 
[ImMag, ImDir] = EdgeOperator( Im2, 'sobel5' ); %Implement "names"
%ImMag is the matrix which holds valid points and is operated on. ImDir is
%a constant matrix, based off of original data, for reference
ImMag( ImMag < threshold ) = 0; %Points not removed from ImDir, more data
%At this point, useless to continue to hold magnitude vals. Convert to BW
ImMag( ImMag > 0 ) = 255;%Max on uint8 scale, constrast shows in image
%Expansion and Thinning. 1) Thin quickly to staccato lines. Expand &
%Itteratively thin n times to connect points/lines seperated by 1:2^n
%or so pixels. This will skeletonize the image quickly with high accurency
ImMag2 = ZhangWangThin( ImMag, false );
%Slow Method B, use the spurious...Mat to avoid recalculating the next loop
toc
for i = 1: 5
    j=0;
    while( j< i )
        ImMag2 = Expansion( ImMag2 ); j=j+1;
    end
    ImMag2 = ZhangWangThin( ImMag2, true );
end
toc
ImMag3 = ImMag2;
for i = 1: 4
    for j = 1:50
        ImMag3 = SpurTipRemove( ImMag3 );
    end
    ImMag3 = ZhangWangThin( ImMag3, 1 );
end
toc
%LineList = Line( ImMag3, ImDir );
