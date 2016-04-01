function ThreshOut = ThresholdTuner( ThreshInit, Im, PixelDens )
%THRESHOLDTUNER Given pixel density between 0-1, and initial threshold low
%enough to increase, will calculate the threshold needed for density of Im.
%A high ThreshInit is equilivant to setting a minimum or a desired thresh.
    ThreshOut = ThreshInit; Dens = Density( Im ); 
    LastDens = Dens; LastThresh = ThreshOut;
    while Dens > PixelDens
        LastDens = Dens; LastThresh = ThreshOut;
        ThreshOut = ThreshOut + 1;
        Im( Im < ThreshOut ) = 0;
        Dens = Density( Im );
    end
    if LastDens == min( abs( LastDens - PixelDens ), abs( Dens - PixelDens ) );
       ThreshOut = LastThresh; 
    end
end

function d = Density( Im )
    d = sum(sum(logical(Im),1),2)/size(Im,1)/size(Im,2);
end