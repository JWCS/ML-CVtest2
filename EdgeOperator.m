function Im2 = EdgeOperator( Im, type )
%EdgeOperator
%   This performs an edge operator, such as sobel's, across the image. 
    if type = 'sobel' %Make some sorter thingy for diff types, maybe?
        delX = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
        delY = [1, 2, 1; 0, 0, 0; -1, -2, -1];
    end
    

end