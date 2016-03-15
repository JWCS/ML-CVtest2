function [ ImMag, ImDir ] = EdgeOperator( Im, type )
%EdgeOperator
%   This performs an edge operator, such as sobel's, across the image. 
    %Initialize types of operators and assign del per type]
    scale = 255 / 800; %IDK what I should use for scale, depends
    s3 = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
    s5 = [-1, -2, 0, 2, 1; -2, -3, 0, 3, 2; -3, -5, 0, 5, 3; 
          -2, -3, 0, 3, 2; -1, -2, 0, 2, 1];
    if isequal( type, 'sobel3' )
        del( :, :, 1 ) = double( s3 );
        del( :, :, 2 ) = double( s3' * -1 );
    end
    if isequal( type, 'sobel5' )
        del( :, :, 1 ) = double( s5 );
        del( :, :, 2 ) = double( s5' * -1 );
    end
    %Initialize empty mats for new data, Im3,4 are buffer processing
    Im2 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, size( del, 3 ), 3, 'double');
    Im3 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 3, 'double');
    Im4 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 2, 'double');
    ImMag = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 'uint8');
    ImDir = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 'double');
    %Perform del, Assign values per RGB to Im2
    for z = 1 : size( del, 3 )
        Im2(:,:, z, 1) = conv2( double( Im(:, :, 1) ), del(:,:, z), 'valid' ); %R
        Im2(:,:, z, 2) = conv2( double( Im(:, :, 2) ), del(:,:, z), 'valid' ); %G
        Im2(:,:, z, 3) = conv2( double( Im(:, :, 3) ), del(:,:, z), 'valid' ); %B
    end
    %For mag: find mag and convert RGB into intensity(?) on uint8 scale
    Im3(:,:,:) = sqrt( sum( Im2.^2, 3 ) ); %Dim 3 is now RGB
    ImMag(:,:) = uint8( scale * ...Convert range from 0:4039(?) to 0:255
                ArbMatsRGB2gray( Im3(:,:,1), Im3(:,:,2), Im3(:,:,3) ) );
    %For dir: Turn RGB into intensity (dels), then dels into degrees
    Im4(:,:,:) = ArbMatsRGB2gray(Im2(:,:,:,1), Im2(:,:,:,2), Im2(:,:,:,3));
    %if size( del, 3 ) == 4
        %When I might choose this type of operators
    %end
    if size( del, 3 ) == 2 %Is Im4 effectively what I want for ImDir???
        ImDir = atan2( Im4( :, :, 2 ), Im4( :, :, 1) );
    end %ImDir returns value [-pi,pi], which can be used later?
end

function Mat = ArbMatsRGB2gray( R, B, G )
    Mat = 0.2989 * R + 0.5870 * G + 0.1140 * B; %Straight from docs
end