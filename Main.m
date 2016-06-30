%Main
%Editable values: threshold, itterations of expansion/thinning & pruning
threshold = 130; %Sobel5 thresh 130, sobel3 thresh >20 <50, too long
Error = true;
while Error
Error = false; %This is for threshold: if too low, out of memory error
filterRegSide = 5; % Apparently can only be 3||5, memory
Im = rot90( imread('H1.JPG'), -1 ); %Nature of the im, it's rotated (to me)
Im2 = MedianFilter( Im, filterRegSide ); 
[ImMag, ImDir] = EdgeOperator( Im2, 'sobel5' ); %Implement "names"
%ImMag is the matrix which holds valid points and is operated on. ImDir is
%a constant matrix, based off of original data, for reference
ImMag( ImMag < threshold ) = 0; %Points not removed from ImDir, more data
%At this point, useless to continue to hold magnitude vals. Convert to BW
% --sparseDev Edits: Converting to Sparse here
% -- Affected functions: ZhangWang, Expansion, SpurTipRemove, Line
% --Also, in case it was not already so, all Ims should now be logical
% -- ZhangWangThin had 1 change, 3 %'ed out b/c unsure if better
% -- Expansion should be fine
% -- SpurTipRemove should be fine
% -- Line is mostly index manip, which is full mats of inds, a lil adjust
Im2 = sparse(logical( ImMag ) );
Im3 = ZhangWangThin( Im2, false, false );
%Expansion & thinning, This section can benefit from improvements
for i = 1: 4
    j=0;
    while( j< i )
        Im3 = Expansion( Im3 ); j=j+1;
    end 
    Im3 = ZhangWangThin( Im3, true, false ); %This func is highly optimized
end; clear i j;
%Pruning, removing spurs, final cleaning. ImMag2 is kinda shoddy
Im4 = Im3;
for i = 1: 4
    for j = 1:30
        Im4 = SpurTipRemove( Im4 );
    end
    Im4 = ZhangWangThin( Im4, 1, true );
end; clear i j;
try
[LineList, ImOut] = Line( Im4, ImDir, 2 ); %Two seemed to be most opt
catch ME
    if strcmp(ME.identifier, 'MATLAB:nomem')
        Error = true;
        threshold = threshold + 15; disp(ME);
        disp('Out of Memory error. Resolution: threshold is now ');
        disp(threshold); disp('Will rerun. If this persists, move machines.');
    else
        rethrow(ME);
    end
end
end
