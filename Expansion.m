function [ OutMag ] = Expansion( InOfMag )
%Expansion Expands all points in 8-connnectivity. Buffer is 'ones' 
seen = logical( InOfMag );
border = ~seen & conv2( single( seen ), ones(3, 'single' ), 'same' );
OutMag = InOfMag; OutMag( border ) = 1;
end