function [ OutMag ] = ThinningMethod1( InOfMag, rounds )
%THINNING Thins image, until full skeleton, rounds is No of rounds or 'all'
%   Check if point, if meets no of neighbors, & if it maintains
%   connectivity
tic
    NewOut = OneRound( logical( InOfMag ) ); NewIn = ones(size(InOfMag));
    while ~isequal(uint8(NewIn) - uint8(NewOut),zeros(size(InOfMag)))...
            & rounds %#ok<AND2>
        NewIn = NewOut;
        NewOut = OneRound( logical(NewIn) );
        if isnumeric(rounds)&&(rounds>0)
            rounds = rounds -1;
        end
    end
    OutMag = uint8( InOfMag ) .* uint8( NewOut );
    toc
end
function [ Out ] = OneRound( seen )
    neighbors = ones( 3, 'single' ); neighbors(2,2) = 0;
    NeighborNo = conv2( single( seen ), neighbors, 'same').*single(seen);
    %Neighbor rules, rm if 1 or 0 neighbors, or 7 or 8 (inside & end)
    NeighborNo(NeighborNo > 6) = 0; NeighborNo(NeighborNo < 2) = 0; 
    NeighborNo(NeighborNo > 0 ) = 1; 
    toDelete = uint8(ConnectivityCheck( uint8(seen) )).*uint8(NeighborNo); %Final check, del if pass
    Out = uint8(uint8(seen) - toDelete); 
end 
%Functionality moved to ConnectivityCheck.c
%This is saved for later usage. The code was working in matlab, but took so
%long that it wasn't good. So I rewrote it halfway in c/mex. Upon testing
%if it worked, it kept crashing matlab. moving to another method that fully
%uses matlab
% function toDelete = ConnectivityCheck( LogMat ) %For logical matrix LogMat
%     [ M, N ] = size( LogMat ); 
%     Mat = zeros( M +2, N +2 );
%     Mat( 2:M+1, 2:N+1 ) = LogMat; 
%     Cols = im2col_slide_3x3( Mat ); 
%     toDelete = zeros( M, N );
%     toDelPad = zeros( M +2, N +2 );
% %     for m = 1:M; 
% %         for n = 1:N;
% %             if LogMat( m, n )
% %                 toDelPad( 2:M+1, 2:N+1 ) = toDelete;
% %                 tempCols = im2col_slide_3x3( toDelPad );
% %                 if (sum( tempCols( :, M*(n-1) + m ) ) == 0)&&(ConnectDeCol( Cols( :, M*(n-1)+m ) )==1)
% %                        toDelete( m, n ) = 1;
% %                 end
% %             end
% %         end; 
% %     end;
% %     %toDelPad( 2:M+1, 2:N+1 ) = @(toDelete) toDelete;
% %     %tempCols = @(toDelPad) im2col_slide_3x3( toDelPad );
% %     for m = 1:M
% %         for n = 1:N
% %             A( M * (n-1) + m ) = M * (n-1) + m;
% %         end
% %     end
% %     toDelete( (LogMat==1) ) = ( ConnectDeCol( Cols( A ) ) ==1 );
% end
% function n = ConnectDeCol( col )
%     %Elements in col are as follows: [ 1, 4, 7; 2, 5, 8; 3, 6, 9 ]
%     mat = reshape( col, [3,3] ); a(1:4)=0; b(1:4)=1;
%     if(mat(1,1)==1); a(1) = mat(1,1) - mat(2,1); end;
%     if(mat(3,1)==1); a(2) = mat(3,1) - mat(3,2); end;
%     if(mat(3,3)==1); a(3) = mat(3,3) - mat(2,3); end;
%     if(mat(1,3)==1); a(4) = mat(1,3) - mat(1,2); end;
%     
%     if(mat(2,1)==1); b(1) = mat(3,1) + mat(3,2); end;
%     if(mat(3,2)==1); b(2) = mat(3,3) + mat(2,3); end;
%     if(mat(2,3)==1); b(3) = mat(1,3) + mat(1,2); end;
%     if(mat(1,2)==1); b(4) = mat(1,1) + mat(2,1); end;
%     b( b > 0 ) = -1; b = b + 1; %If b=0, is a change, if b~=0,
%     n = sum(a) + sum(b);
% end
% function out = im2col_slide_3x3( Mat )
% nrows = 3;
% ncols = 3;
% [m,n] = size(Mat);
% %// Start indices for each block
% start_ind = reshape(bsxfun(@plus,(1:m-nrows+1)',(0:n-ncols)*m),[],1);
% %// Row indices
% lin_row = permute(bsxfun(@plus,start_ind,(0:nrows-1))',[1 3 2]);
% %// Get linear indices based on row and col indices and get desired output
% out = Mat(reshape(bsxfun(@plus,lin_row,(0:ncols-1)*m),nrows*ncols,[]));
% end