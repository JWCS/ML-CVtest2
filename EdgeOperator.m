function [ ImMag, ImDir ] = EdgeOperator( Im, type )
%EdgeOperator
%   This performs an edge operator, such as sobel's, across the image. 
    %Initialize types of operators and assign del per type. Returns ImMag
    %on scale of unit8 and ImDir in degrees 180 to -180
    %scale = 255 / 800; %IDK what I should use for scale, depends
    s3 = [-1, 0, 1; -2, 0, 2; -1, 0, 1]; %N dir
    s5 = [-1, -2, 0, 2, 1; -2, -3, 0, 3, 2; -3, -5, 0, 5, 3; 
          -2, -3, 0, 3, 2; -1, -2, 0, 2, 1];
    if isequal( type, 'sobel3' )
        del( :, :, 1 ) = double( s3' );
        del( :, :, 2 ) = double( s3 ); 
    end
    if isequal( type, 'sobel5' )
        del( :, :, 1 ) = double( s5' );
        del( :, :, 2 ) = double( s5 );
    end
    %Initialize empty mats for new data, Im3,4 are buffer processing
    Im2 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, size( del, 3 ), 3, 'double');
    Im3 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 3, 'double');
    Im4 = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 3, 'double');
    ImMag = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 'uint8');
    ImDir = zeros( size( Im, 1) - size( del, 1) +1, ...
             size( Im, 2) - size( del, 2) +1, 'int16');%ch1:doub->int16
    %Perform del, Assign values per RGB to Im2
    for z = 1 : size( del, 3 )
        Im2(:,:, z, 1) = conv2( double( Im(:, :, 1) ), del(:,:, z), 'valid' ); %R
        Im2(:,:, z, 2) = conv2( double( Im(:, :, 2) ), del(:,:, z), 'valid' ); %G
        Im2(:,:, z, 3) = conv2( double( Im(:, :, 3) ), del(:,:, z), 'valid' ); %B
    end
    %For mag: find mag and convert RGB into intensity(?) on uint8 scale
    Im3(:,:,:) = sqrt( sum( Im2.^2, 3 ) ); %Dim 3 is now RGB
    ImMag(:,:) = uint8( 255/4040 * 5/3 * sum( Im3, 3) );
    %For dir: Turn RGB into intensity (dels), then dels into degrees
    Im4(:,:,:) = atan2( Im2(:,:, 2, :), Im2(:,:, 1, :) );
    ImDir(:,:) = int16( 60 / pi * sum( Im4(:,:,:), 3 ) ); %180/3 (mean)
end
