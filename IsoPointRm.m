function [ OutMat ] = IsoPointRm( InOfMat )
%IsoPointRm Removes isolated points, a point surrounded by zeros, point>=0
   other = ones(3, 'single'); other(2,2) = 0;
   removed = logical( conv2( single( InOfMat ), other, 'same' ) );
   OutMat = uint8( removed ) .* InOfMat;
end