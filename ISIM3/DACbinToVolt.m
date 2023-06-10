function Volt = DACbinToVolt(DAC)
    arguments
        DAC     {mustBeInteger, mustBeInRange(DAC,0,4095)}
    end  
    Volt = 5*double(DAC)/4095;
end