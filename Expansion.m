function [ OutMag ] = Expansion( InOfMag )
%Expansion Expands all points in 8-connnectivity. Buffer is 'ones' 
seen = logical( InOfMag );
%A = conv2( full(double( seen )), ones(3, 'double' ), 'same' );
%border = bsxfun(@and, ~full(seen), A);
%OutMag = bsxfun(@or, seen, border);
OutMag = bsxfun(@or, seen, bsxfun(@and, ~full(seen), ...
            conv2( full(double( seen )), ones(3, 'double' ), 'same' ) ));
%This is older code when I retained and expanded the magnitudes. 
%   Except for some painful dual for loops, this gives each new surrounding
%   element a value of the average of the ones around it. 
%     OutMag = single( InOfMag ); %OutDir = single( InOfDir ); %2d matrices
%     seen = logical( OutMag ); newMagVals = zeros( size( OutMag ), 'single' );
%     %newDirVals = zeros( size( OutDir ), 'single' );
%     border = ~seen .* conv2( double( seen ), ones(3, 'single' ), 'same' );
%     newMagVals(:,:) = logical(border(:,:)) .* conv2( OutMag(:,:), ones(3), 'same') ./border(:,:);
%     newMagVals( isnan(newMagVals)) = 0;
%     %newDirVals(:,:) = logical(border(:,:)) .* conv2( OutDir(:,:), ones(3), 'same') ./border(:,:);
%     %newDirVals( isnan(newDirVals)) = 0;
%     OutMag = uint8( OutMag + newMagVals );
%     %OutDir = int16( OutDir + newDirVals ); 
end