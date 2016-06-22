function [ List, ImOut ] = Line( InOfMag, InOfDir, Runs )
%LINE Generates list of lines in image. ImOut is logical (binary). 
ImOut = InOfMag; 
for i = 1:Runs
    [ LineIDs, Lines, LinesM, NeighborNo ] = AcquireLines( logical( ImOut ), 1 );
    [~, ~, ImOut ] = Process2( Lines, LineIDs, LinesM, InOfDir, NeighborNo);
end
[ LineIDs, Lines, LinesM, ~ ] = AcquireLines( logical( ImOut ), 0 );
List(:,1) = LineIDs(:,1);
List(:,2:1+size(Lines,2)) = Lines;
List( bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)') + 2*LinesM)=LineIDs(:,2);
end

function [ LineIDs, Lines, LinesM, NeighborNo ] = AcquireLines( seen, addJunctions )
%Acquire unique lines into LineIDs
M = size( seen, 1 ); neighbors = ones(3, 'single'); neighbors(2, 2) = 0;
MatInd = bsxfun(@plus, (1:M)', (0:size(seen,2)-1)*M);
for a = 1:2
    if a>1; seen = logical(NeighborNo); end;
    NeighborNo = conv2( single(seen), neighbors, 'same' ) .* single(seen);
    LinePts = (NeighborNo==2);
    Lines = ((conv2(single(LinePts),neighbors, 'same') .*LinePts) ==1).*MatInd;
    LinePts = LinePts .* MatInd; LinePts(1:2, 1:2) = 0;
    Lines(Lines==0) = []; Lines = Lines'; i=1; cont = true;
    NextPoints = conv2(single(LinePts),neighbors, 'same').*logical(LinePts);
    while cont %Lines has each line end, this loop adds pts to make whole line
        if i>1
            Lines(:,i+1) = NextPoints(Lines(:,i)) - LinePts(Lines(:,i-1));
        else
            Lines( :, i+1 ) = NextPoints( Lines(:, i ));
        end
        cont = any( Lines(:, i+1) );
        Lines( Lines<=0 ) = 1;
        i = i +1;
    end
    cont = true; i = 1;
    while cont %For everyline, there is a duplicate: this loop removes it
        for j = i+1:size(Lines, 1)
            if sum(builtin('_ismemberhelper', Lines(i,:), sort(Lines(j,:))))...
                    ==size(Lines,2);
                Lines(j,:)=[]; break;
            end
        end
        i= i+1; cont = i<size(Lines,1);
    end; clear i j cont;
    LinesM = size(Lines,1); 
    CritsInd = (NeighborNo==1 | NeighborNo>2) .* MatInd;
    Temp = conv2( single(CritsInd), neighbors, 'same'); %
    LineIDs(:,1) = Temp(Lines(:,1)); Lines(Lines==1)=nan;
    LineIDs(:,3) = bsxfun(@minus, size(Lines,2), sum(isnan(Lines), 2));
    LineIDs(:,2)=Temp(Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)')));
    if a==1
        NeighborNo(LineIDs(LineIDs(:,1)==LineIDs(:,2)))= ...
            NeighborNo(LineIDs(LineIDs(:,1)==LineIDs(:,2)))-2;
        Temp = reshape(Lines(LineIDs(:,1)==LineIDs(:,2),:), [], 1);
        Temp(isnan(Temp))=[]; clear LineIDs;
        NeighborNo(Temp) = 0; %Removes loops with 1 crit point
        for i = 1: 2
            for j = 1:10
                NeighborNo = SpurTipRemove( uint8(NeighborNo) );
            end
            NeighborNo = ZhangWangThin( NeighborNo, 0, 0 );
        end %Not worried about Thin removing > 1-2 at a place: Mat,0,0
    end; 
    clear i j;
end; clear a Temp;
%Lines in LineIDs: Critical End 1, Crit End 2, No of pts inbetween(not inc)
if addJunctions
    %Add junctions of splits as lines with 0 inbetween points
    Temp = double(NeighborNo); Temp(Temp<3) = 0; Temp(Temp>2) = 1;
    Q = find( Temp ); Temp = Temp .* MatInd; Temp(:,end+1) = zeros( M, 1 ); j = 2;
    for i = [-M-1, -M, -M+1, -1, +1, M-1, M, M+1]
        %For each split, make a list of the points closest to it, and their angles
        %relative to the origin, and find the two that plus/minus 180 are closest
        %to the angle given. Keep those lines, eithe those that meet one end or two
        Q(:,j) = Temp( Q(:,1) + i );
        j = j+1;
    end; clear i j Temp;
    %This next bit, plus above, adds each poss line through a junction to Lines
    Q = permute( Q, [3, 2, 1] );
    R = Q(:,1,:);
    R(2:9,2,:) = permute( Q(:,2:9,:), [2,1,3] );
    R(2:9,1,:) = bsxfun(@times, R(1,1,:), ones(8,1));
    R = reshape( R, [], 2, 1 ); R(~all(R,2),:) = [];
    Lines( end +1 : end +size(R,1), 2:-1:1) = R; Lines( Lines==0 ) = nan;
    R(:,3) = 2*ones(size(R,1),1); LinesM = size( Lines, 1 );
    LineIDs( end +1 : end +size(R,1), 1:3 ) = R;
end
end

function [LineIDsOut, LinesOut, ImOut ] = ...
    Process2( Lines, LineIDs, LinesM, ImDir, NeighborNo)
%ImOut is logical, 3rd col of LineIDs gives length of Lines
% This piece tried to delete all lines connected to a split if they
% weren't the 2 most accurate / in line with the ImDir there
M = size( NeighborNo, 1 );
List = find(NeighborNo>2); N = size(NeighborNo,2);
for a = 1:2
ListInds = permute(cat(3, sort(bsxfun(@times,bsxfun(@eq,List,LineIDs(:,1)'),(1:LinesM)),...
    2,'descend'),sort(bsxfun(@times,bsxfun(@eq,List,LineIDs(:,2)'),1:LinesM),...
    2,'descend')), [3,2,1]);
%That line finds all the splits (List), compares it to all points in
%LineIDs, and then multiplies the matrix to generate row numbers for points
%in Lines. This is sorted, nums are in 1st 4 cols, and the two comparisons
%are combined. The next line gets the num of elements in each row
ListIndsSize = permute(sum(logical(ListInds),2), [1,3,2]);
if a==1; List(sum(ListIndsSize,1)<3)=[]; end;
end; clear a;
for i = 1:size(List,1)
    if ListIndsSize(1,i)~=0
        List(i,2:1+ListIndsSize(1,i)) = Lines(ListInds(1,1:ListIndsSize(1,i),i));
    end
    if ListIndsSize(2,i)~=0
        List(i,2+ListIndsSize(1,i):1+ListIndsSize(1,i)+ListIndsSize(2,i)) ...
            = LineIDs(ListInds(2,1:ListIndsSize(2,i),i));
    end
end; clear i; %Assigns to List(:,2:5) the inds of the points near each split
List(List==0)=nan; 
[Temp(:,:,3),Temp(:,:,4)] = ind2sub([M,N],List(:,1));
Temp = bsxfun(@times, Temp, ones(1,size(List,2)-1,1));
[Temp(:,:,1),Temp(:,:,2)] = ind2sub([M,N],List(:,2:end));%Temp is local 9
TempDirDist = bsxfun(@times, double(ImDir( List(:,1))), ones(1,size(List,2)-1, 2));
TempDirDist(:,:,1) = TempDirDist(:,:,1)-180; 
TempDirDist(TempDirDist(:,:,1)<-180) = TempDirDist(TempDirDist(:,:,1)<-180) +360;
TempDirDist = bsxfun(@minus, TempDirDist, ...
    atan2d(Temp(:,:,2)-Temp(:,:,4),Temp(:,:,1)-Temp(:,:,3)));
TempDirDist(TempDirDist<-180) = TempDirDist(TempDirDist<-180) + 360;
TempDirDist(TempDirDist>180) = TempDirDist(TempDirDist>180) - 360;
DirDist = TempDirDist(:,:,2);
DirDist(bsxfun( @lt, abs(TempDirDist(:,:,1)), abs(TempDirDist(:,:,2)) )) = ...
    TempDirDist(bsxfun( @lt, abs(TempDirDist(:,:,1)), abs(TempDirDist(:,:,2)) ));
Temp = SortAboutZero( DirDist );
DirDist( bsxfun(@lt, abs(Temp(:,3)), DirDist) | ...ifTempNeg
    bsxfun(@gt, -abs(Temp(:,3)), DirDist)  )=nan; %ifTempPos
A = bsxfun(@eq, Temp(:,3), DirDist); A(sum(A,2)>1,:)=0; DirDist(A) = nan;
DirDist(~isnan(DirDist))=1; DirDist(isnan(DirDist))=0; %Convert to logical
%Gets the connecting 1-2 points furthest from ImDir, corresponds with List
ListKeepLog = ones(size(List)); ListKeepLog(:,2:end) = DirDist;
toKeep = List( logical(ListKeepLog) );%Don't delete, keep
Q = bsxfun(@eq, toKeep, LineIDs(:,1)'); %For bsxfun memory probs
toKeepInds1 = bsxfun(@times, Q, 1:LinesM );
toKeepInds1( toKeepInds1 == 0 ) = [];
R = bsxfun(@eq, toKeep, LineIDs(:,2)'); %For bsxfun memory probs
toKeepInds2 = bsxfun(@times, R, 1:LinesM );
toKeepInds2( toKeepInds2 == 0 ) = [];
toKeepInds = cat( 2, toKeepInds1, toKeepInds2 );
%Important tuning factor here, b/c we kept all the most relevant lines,
%limit to the ones multiply supported. Also, tested =2, broke some places
Tune = 1;
FinalPoints1 = Lines( sum(bsxfun(@eq, toKeepInds, (1:LinesM)'),2) >Tune, : );
LinesOut = FinalPoints1;
FinalPoints1( isnan(FinalPoints1) ) = [];
LineIDsOut = LineIDs( sum(bsxfun(@eq, toKeepInds, (1:LinesM)'),2) >Tune, 1:2 );
ImOut = zeros(size(NeighborNo)); 
ImOut( FinalPoints1 ) = 1; ImOut( LineIDsOut ) = 1; ImOut=logical(ImOut);
end

function [ OutMat ] = SortAboutZero( InOfMat )
%SORTABOUTZERO Sorts each row from closest to zero to furthest, (-) ignored
A = InOfMat; A( A<0 ) = nan;
B = -1.*InOfMat; B( B<=0 ) = nan;
OutMat = sort( cat( 2, A, B ), 2 ); OutMat( :, 1+ size(InOfMat,2) : end ) = [];
Temp = permute(any(bsxfun( @eq, permute(OutMat, [3,2,1]), ...
    permute(B, [2,3,1]) ),1), [3,2,1]);
OutMat( Temp ) = -1.*OutMat( Temp );
end

% function [LineIDs, Lines, ImOut ] = ...
%     Process1( Lines, LineIDs, LinesM, ImDir, NeighborNo)
% global M; %ImOut is logical. LineIDs out gives Lines lengths in 3rd col
% % This piece was assuming the correct lines pointed to each other. 
% % Check by reference ImDir; Degrees are N over M, positively oriented.
% A(:,1,1) = round( sind( single(ImDir( Lines(:,1) )) )); % Val along +N dir
% A(:,2,1) = round( cosd( single(ImDir( Lines(:,1) )) )); % Val along +M dir
% A(:,3,1) = round(sind(single(ImDir(Lines(:,1))+30)));
% A(:,4,1) = round(cosd(single(ImDir(Lines(:,1))+30)));
% A(:,5,1) = round(sind(single(ImDir(Lines(:,1))-30)));
% A(:,6,1) = round(cosd(single(ImDir(Lines(:,1))-30)));
% A(:,7:12,1) = -1 * A(:,1:6,1); %Does the same, checking opp dir
% A(:,13:18,1) = bsxfun(@plus, Lines(:,1), A(:,2:2:12,1) + M*A(:,1:2:11,1) );
% A(:,19:24,1) = bsxfun( @eq, A(:,13:18,1), LineIDs(:,1) ); %Checks if Lines-> Crits
% %Also checks now if Crits-> Lines for first points
% A(:,1,2) = round( sind( single(ImDir( LineIDs(:,1) )) )); % Val along +N dir
% A(:,2,2) = round( cosd( single(ImDir( LineIDs(:,1) )) )); % Val along +M dir
% A(:,3,2) = round(sind(single(ImDir(LineIDs(:,1))+30)));
% A(:,4,2) = round(cosd(single(ImDir(LineIDs(:,1))+30)));
% A(:,5,2) = round(sind(single(ImDir(LineIDs(:,1))-30)));
% A(:,6,2) = round(cosd(single(ImDir(LineIDs(:,1))-30)));
% A(:,7:12,2) = -1 * A(:,1:6,2); %Does the same, checking opp dir
% A(:,13:18,2) = bsxfun(@plus, LineIDs(:,1), A(:,2:2:12,2) + M*A(:,1:2:11,2) );
% A(:,19:24,2) = bsxfun( @eq, A(:,13:18,2), Lines(:,1) ); %Checks if Lines-> Crits
% % Check now for the other end point for each line. 
% A(:,1,3) = round( sind( single(ImDir( ...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)')) )) ));
% A(:,2,3) = round( cosd( single(ImDir( ...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)')) )) ));
% A(:,3,3) = round(sind(single(ImDir(...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)'))) + 30)));
% A(:,4,3) = round(cosd(single(ImDir(...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)'))) + 30)));
% A(:,5,3) = round(sind(single(ImDir(...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)'))) - 30)));
% A(:,6,3) = round(cosd(single(ImDir(...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)'))) - 30)));
% A(:,7:12,3) = -1 * A(:,1:6,3); 
% A(:,13:18,3) = bsxfun(@plus, Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, ...
%     (1:LinesM)')), A(:,2:2:12,3) + M*A(:,1:2:11,3) );
% A(:,19:24,3) = bsxfun( @eq, A(:,13:18,3), LineIDs(:,2) );
% %Also checks now if Crits-> Lines for first points
% A(:,1,4) = round( sind( single(ImDir( LineIDs(:,2) )) )); 
% A(:,2,4) = round( cosd( single(ImDir( LineIDs(:,2) )) )); 
% A(:,3,4) = round(sind(single(ImDir(LineIDs(:,2))+30)));
% A(:,4,4) = round(cosd(single(ImDir(LineIDs(:,2))+30)));
% A(:,5,4) = round(sind(single(ImDir(LineIDs(:,2))-30)));
% A(:,6,4) = round(cosd(single(ImDir(LineIDs(:,2))-30)));
% A(:,7:12,4) = -1 * A(:,1:6,4); 
% A(:,13:18,4) = bsxfun(@plus, LineIDs(:,2), A(:,2:2:12,4) + M*A(:,1:2:11,4) );
% A(:,19:24,4) = bsxfun( @eq, A(:,13:18,4), ...
%     Lines(bsxfun(@plus,(LineIDs(:,3)-1)*LinesM, (1:LinesM)')) );
% % Create final list of acceptable lines. 
% B = ( any( A(:,19:24,1), 2) | any( A(:,19:24,2) ,2) ) | ...
%     ( any( A(:,19:24,3), 2) | any( A(:,19:24,4) ,2) );
% C = reshape(Lines(~B,:), [],1); C(isnan(C))=[];
% NeighborNo( C ) = 0; Lines(~B,:) = []; LineIDs(~B,:) = []; 
% TempLines = reshape(Lines, [], 1); TempLines(isnan(TempLines))=[];
% ImOut = zeros(size(NeighborNo)); 
% ImOut( reshape( LineIDs(:,1:2), [], 1 ) ) = 1; 
% ImOut( TempLines ) = 1; ImOut=logical(ImOut);
% end
