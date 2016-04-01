function [ OutMag ] = Thinning( InOfMag )
%THINNING Thins image, until full skeleton
%   Basing this off of vision notes and online resources, 4 parts
tic
    NewOut = OneRound( logical( InOfMag ) ); NewIn = ones(size(InOfMag));
    disp(isequal(uint8(NewIn) - uint8(NewOut),zeros(size(InOfMag))));
    while ~isequal(uint8(NewIn) - uint8(NewOut),zeros(size(InOfMag)))
        NewIn = NewOut;
        NewOut = OneRound( logical(NewIn) );
        disp(isequal(uint8(NewIn) - uint8(NewOut),zeros(size(InOfMag))));
    end
    OutMag = uint8( InOfMag ) .* uint8( NewOut );
    toc
end
function [ Out ] = OneRound( seen )
    neighbors = ones( 3, 'single' ); neighbors(2,2) = 0;
    NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
    %Neighbor rules, don't rm if 1 or 0 neighbors, or 7 or 8 (inside & end)
    NeighborNo(NeighborNo > 6) = 0; NeighborNo(NeighborNo < 2) = 0; 
    NeighborNo(NeighborNo > 0 ) = 1; 
    toDelete = uint8(ConnectivityCheck( seen )).*uint8(NeighborNo); %Final check, del if pass
    Out = uint8(uint8(seen) - toDelete); 
end
function toDelete = ConnectivityCheck( LogMat ) %For logical matrix LogMat
    Mat = padarray( LogMat, [1,1] ); toDelete = zeros( size( LogMat ) );
    Cols = im2col( Mat, [3,3], 'sliding' );
    for m = 1:size( LogMat, 1 ); 
        for n = 1:size( LogMat, 2 );
            if LogMat( m, n )
                tempCols = im2col( padarray( toDelete, [1,1] ), [3,3], 'sliding' );
                if sum( tempCols( :, size(LogMat, 1)*(n-1) + m ) ) == 0
                    if ConnectDeCol( Cols( :, size(LogMat, 1)*(n-1)+m ))==1
                       toDelete( m, n ) = 1; 
                    end
                end
            end
        end; 
    end;
end
function n = ConnectDeCol( col )
    %Elements in col are as follows: [ 1, 4, 7; 2, 5, 8; 3, 6, 9 ]
    mat = reshape( col, [3,3] ); a(1:4)=0; b(1:4)=1;
    if(mat(1,1)==1); a(1) = mat(1,1) - mat(2,1); end;
    if(mat(3,1)==1); a(2) = mat(3,1) - mat(3,2); end;
    if(mat(3,3)==1); a(3) = mat(3,3) - mat(2,3); end;
    if(mat(1,3)==1); a(4) = mat(1,3) - mat(1,2); end;
    
    if(mat(2,1)==1); b(1) = mat(3,1) + mat(3,2); end;
    if(mat(3,2)==1); b(2) = mat(3,3) + mat(2,3); end;
    if(mat(2,3)==1); b(3) = mat(1,3) + mat(1,2); end;
    if(mat(1,2)==1); b(4) = mat(1,1) + mat(2,1); end;
    b( b > 0 ) = -1; b = b + 1; %If b=0, is a change, if b~=0,
    n = sum(a) + sum(b);
end