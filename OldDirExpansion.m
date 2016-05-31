function [ OutMag, OutDir ] = DirExpansion( InOfMag, InOfDir, V )
%DirExpansion Expansion using directional operator, expanding in a
%direction only
%   Not Perfect, very stylized, but it works exactly right
    OutMag = single( InOfMag ); OutDir = single( InOfDir ); %2d matrices
    seen = logical( OutMag ); newMagVals = zeros( size( OutMag ), 'single' );
    newDirVals = zeros( size( OutDir ), 'single' ); pointed = zeros( size( seen ));
    [ M, N ] = size( pointed ); 
    %[arry(1,:),arry(2,:)] = NextInDir( OutDir(1:M,1:N), 1:M, 1:N );
    %pointed(arry(1,:),arry(2,:)) = 1;
    %pointed( NextI nDir( OutDir(1:M,1:N)) ) = 1;
    %pointed(:,:) = logical( border(:,:) ) .* NextInDir( OutDir(:,:) );
    for m = 1:M
        for n = 1:N
            if seen( m, n )
                [ m2, n2, m3, n3 ] = NextInDir( OutDir( m, n ), m, n );
                if ~( (m2-m)==0 && (n2-n)==0 ) && m2<=M && m2>=1 && n2<=N && n2>=1;
                    pointed( m2, n2 ) = 1;
                end
                if ~( (m3-m)==0 && (n3-n)==0 ) && m3<=M && m3>=1 && n3<=N && n3>=1;
                    pointed( m3, n3 ) = 1;
                end
            end
        end
    end    
    border = ~seen .* pointed .* conv2( double( seen ), ones(3, 'single' ), 'same' );
    newMagVals(:,:) = logical(border(:,:)) .* conv2( OutMag(:,:), ones(3), 'same') ./border(:,:);
    newMagVals( isnan(newMagVals)) = 0;
    OutMag = uint8( OutMag + newMagVals );
    if V == 1;
    newDirVals(:,:) = logical(border(:,:)) .* conv2( OutDir(:,:), ones(3), 'same') /9;
    newDirVals( isnan(newDirVals)) = 0; 
    OutDir = int16( ( OutDir .* ~logical(newMagVals) ) + newDirVals ); 
    else OutDir = int16( OutDir ); 
    end;
end

function [NextM, NextN, NegNextM, NegNextN] = NextInDir ( DirMN, m, n )
%NextInDir function has input of DirMN at indice M,N & returns indices
%NextM and NextN of where the next point in Dir is
    a = round( sind( DirMN ) ); b = round( cosd( DirMN ) );
    NextM = a + m; NegNextM = -a + m; NextN = b + n; NegNextN = -b + n; 
end