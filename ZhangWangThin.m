function [ OutMag ] = ZhangWangThin( InOfMag, isIterative, rmIsolated )
%ZHANGWANGTHIN A thinning / skeletization algorithm by YY Zhang and PSP
%Wang; input is matrix to thin, output is same, uint8; Assume binary uint8.
seen = logical( InOfMag ); %toItt = .5;
neighbors = ones( 3, 'single' ); neighbors(2,2) = 0; cont = true;
while( cont )
    %Rule 1,2: p is point and 2<=B(p)<=6
    NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
    %Neighbor rules, rm if 1 or 0 neighbors, or 7 or 8 (inside & end)
    NeighborNo(NeighborNo > 6) = 0; NeighborNo(NeighborNo < 2) = 0;
    NeighborNo(NeighborNo > 0 ) = 1; %NeighborNo has possible points toDelete
    toDelete = localOperations( seen, NeighborNo, rmIsolated);
    if isIterative
        [ M, N ] = size( toDelete );
        for i = 1:(M*N-M-1)
             if toDelete( i );
                toDelete([ i+1, i+1+M, i+M, i-1+M ]) = 0; 
             end
        end
    end
    seen = logical( seen - toDelete );
    cont = sum(sum(toDelete, 1), 2) ~=0;
end
OutMag = InOfMag; OutMag(~seen) = 0;
end

function toDelete = localOperations( logMat, validPoints, rmIsolated ) 
%AKA Connectivity Check: A(p)=1; 
%Rule 3, 4, 5: Delete if maintains connectivity and critical neighbors
[M, N] = size( logMat ); validPoints = logical( validPoints );
toDelPad = spalloc( M + 3, N + 3, nnz( logMat ) ); 
toDelPad( 1+2:M+2, 1+1:N+1 ) = logMat;
cols = logical( im2col_slide_4x4( toDelPad ) );
%R4a = sparse( M*N, 1 ); R4b = sparse( M*N, 1 ); 
%R5a = sparse( M*N, 1 ); R5b = sparse( M*N, 1 );
%Sides: 1,2:p2:n6; 3,2:p6:n8; 2,1:p8:n3; 2,3:p4:n11; Outside:p11=n5,p15=n15
R4a( 1:M*N )=cols( 6, 1:M*N ).*cols( 11, 1:M*N ).*cols( 3, 1:M*N );R4a=~R4a;
R5a( 1:M*N )=cols( 6, 1:M*N ).*cols( 11, 1:M*N ).*cols( 8, 1:M*N );R5a=~R5a;
%In testing, it missed some pts: assumed 4-conn? Adjusting R4,5b from alg
R4b( 1:M*N ) = logical( cols(5,1:M*N) | cols(1,1:M*N) | cols(9,1:M*N) );
R5b( 1:M*N ) = logical( cols(15,1:M*N) | cols(14,1:M*N) | cols(16,1:M*N) );
validPoints = reshape( validPoints, 1, M*N ).*((R4a | R4b)&(R5a | R5b));
%Some optimization in moving || to earlier, poss w/ 4&5
%Corners: 1,1:p9:n2; 3,1:p7:n4; 3,3:p5:n12; 1,3:p3:n10;
valInd = find(validPoints); R3a = zeros(1,M*N); R3b = zeros(1,M*N);
%valInd = find(validPoints); R3a = sparse( 1, M*N ); R3b = sparse( 1, M*N );
R3a(valInd) = cols( 2, valInd ) + cols( 4, valInd ) + cols( 12, valInd ) +...
    cols( 10, valInd ) - cols( 2, valInd ) .* cols( 3, valInd ) -...
    cols( 4, valInd ) .* cols( 8, valInd ) - cols( 12, valInd ) .* ...
    cols( 11, valInd ) - cols( 10, valInd ) .* cols( 6, valInd );
validPoints = validPoints - ( R3a >1 );
valInd = find(validPoints);
R3b(valInd) = logical(cols( 6, valInd )&~( cols( 2, valInd ) + cols( 3, valInd ) ))...
    + logical(cols( 11, valInd )&~( cols( 10, valInd ) + cols( 6, valInd ) ))...
    + logical(cols( 8, valInd )&~( cols( 12, valInd ) + cols( 11, valInd ) ))...
    + logical(cols( 3, valInd )&~( cols( 4, valInd ) + cols( 8, valInd ) ));
if rmIsolated == 1;
    toDelete = reshape( validPoints .* ( (R3a + R3b) <=1 ), M, N ); 
else
    toDelete = reshape( validPoints .* ( (R3a + R3b) ==1 ), M, N ); 
end
end

function out = im2col_slide_4x4( Mat )
nrows = 4;
ncols = 4;
[m,n] = size(Mat);
%// Start indices for each block
%start_ind = reshape(bsxfun(@plus,(1:m-nrows+1)',(0:n-ncols)*m),[],1);
%// Row indices
%lin_row = permute(bsxfun(@plus,start_ind,(0:nrows-1))',[1 3 2]);
%// Get linear indices based on row and col indices and get desired output
%out = Mat(reshape(bsxfun(@plus,lin_row,(0:ncols-1)*m),nrows*ncols,[]));
%The above lines have been commented out and subbed below, for effeciency
out = Mat(reshape(bsxfun(@plus,permute(bsxfun(@plus, ...
    reshape(bsxfun(@plus,(1:m-nrows+1)',(0:n-ncols)*m),[],1),...
    (0:nrows-1))',[1 3 2]),(0:ncols-1)*m),nrows*ncols,[]));
end
% Sparse changes: 3 lines of init in toDelete, currently commented out, idk
% if that will actually speed it up. Also, toDelmat was changed to sparse