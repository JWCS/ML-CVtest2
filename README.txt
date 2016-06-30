CV Trial 2 in Matlab, by JWC Sauve.  

The code in Main is shown below. It makes usage of the following functions (chronologically): MedianFilter, EdgeOperator(Sobel3/5), Expansion, ZhangWangThin, and Line.  
The names are generally explanatory, and details are in the functions themselves; Main is a pertinent example of their functionality.  
The final function, Line, outputs a final logical/binary image and a list of all lines in the image (Recorded and included in Image1 as ImOut.jpg and LineList.csv respectively).

Key components to note: first, there is no built-in input for Main, the image to be processed is written in.  

Second, ZhangWangThin, a 4x4 thinning algorithm which includes a description inside of it, was optimized as much as possible for each thinning style employed. It by default thins in parallel, which can cause neighboring points, of which only one should be deleted, to both be deleted, causing gaps of 1-2 pixels. This is, however, quicker and fixed by expansion. It can also delete iteratively, one at a time, preventing overdeletion. This function is the most time consuming of the algorithm.  

Third, much time was spent on expansion algorithms, just to be tossed to the side for the sake of time. The base expansion method used causes 'bubbles,' spurs, and loops in the line. These are much reduced, but not all. The final image is quite clean, but hardly perfect.  

Fourth, Line, using the directional matrix produced by the edge operator, filters out some of these bubbles and returns a final image as well as a list, where every row is a line, from a line end to a junction.  

A significant speed increase and code rewrite can be achieved by using sparse matrices, but I saved that for another project. Currently takes ~ 7 min for 2500x2000 pixel image.  

Better results would require a template or some curve details pertaining to the nature of the hand- this and better expansion functions are places for improvement.  

The Unused methods folder contains developmental junk kept for reference.  

Image1 folder contains the .mat file with all of the outputs of Main for the hand image the program was written around, as well as the image and the produced images in .jpg format.  

Image2 folder contains some .jpg s of this algorithm applied to other photos.  

The wiki tab contains images at each of the stages, for the original image, for easy viewing.  

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
Im3 = ZhangWangThin( logical( ImMag ), false, false );
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

The thoughts.txt file contains my log of this project. This is the TL;DR:  
Right before spring break, 3rd week in March, I was given this project, decided all of the previous junk I wrote was that, and started from scratch.  
Made an edge operator that allowed the usage of Sobel, with either a 3x3 or 5x5 (5x5 is better).  
It was interesting, but I made a median filter. It could find the median of a 3x3 or 5x5 (best), but 7x7 caused errors.  
I realized that random blind expansion could/would make my job harder, so I attempted to make more knowledgeable expanding functions. 
I have no solution to the current implementation of a user-inputted threshold.  
End of spring break, I tried to make a thinning algorithm. I researched a bit, to get a grasp of what there was. I found out the requirements to delete a pixel and tried to work with that.  
I finally got it to work, but several things happened. 1) Hon Hon Physics got harder. 2) 3cr Thermo class just failed 2/3 of its students. With only 1/3 of the class left, survivors are buckling down for the passing C, cause there is no curve. 3) The code I wrote for thinning, I tried on a 16x16 square that I knew what it was supposed to thin to. That took 2.7 hours. On the 2500 x 2000 picture, that won't work.  
Semester ended. The freshman rocket competition team, of which I did electronics, mechanisms, and programing, had the rocket fall from 3000 ft and thus end. Prof said first and foremost came my grades, and I agree- between physics and thermo I was packed- & had was very sick for week of finals & half week before that.  
But! Now over with better than expected grades, I worked to convert the code to mex, the C-Matlab fun demon. After researching and writing enough to just create the padded image and having it repeatedly crash Matlab, I realized that I've wasted all the time I spent for the last 1.5-2 months (minimal nonschoolwork) on this avenue of thinning.  
I saw on Stack Overflow a reference to a 4x4 thinning algorithm by Zhang and Wang. I decided to implement it.  
I comfort myself with the fact that I knew nothing about Matlab at somepoint. For I spent all this time on thinning, and wrote ZhangWangThin in 2 days.  
I have some CV existentialism with the fact that I'm not using a template, and thus only minimally know what's accurate, I'm not quite sure what format to output this, if this is getting piped for a particular application there must be an easier way than my intermediary output, and I was supposed to finish ages ago... 
I struggle with expansion. The expansion and thinning causes many false paths, because the expansion expands in places I know I don't want, but it does not. I scrap my directed expansion functions, as those could be a future improvement, a big one, but I need to end this, get the lines.  
ZhangWangThin gets edited, modified, improved, and is the most optimized and longest function I have.  
Line acquisition is painful, because of all of the false loops and bubbles by bad expansion. Somehow, though it took me awhile, I made a way to get what I wanted, all of the lines in the image, and the successful (I think) removal of many bad loops.  
Clean up. Good enough. Format, readme, send to prof.  
This could be better, could be quicker, could've been finished quicker as well. Regardless, I am thankful for this stimulating project on such an interesting topic. I went from having no knowledge of Matlab to a much much stronger knowledge, to the point that I think I know Matlab language best now.  
