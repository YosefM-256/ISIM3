function doubleTuning(DAC0tuning,DAC1tuning,DAC0target,DAC1target,DAC0inf,DAC1inf,pathsNconsts,simulationVariables)
    arguments
        DAC0tuning          {mustBeMember(DAC0tuning, {'Ib','Vb','Ic','Vc','beta'})}
        DAC1tuning          {mustBeMember(DAC1tuning, {'Ib','Vb','Ic','Vc','beta'})}
        DAC0target          {mustBeNumeric}
        DAC1target          {mustBeNumeric}
        DAC0inf             {mustBeMember(DAC0inf, {'direct', 'inverse'})}
        DAC1inf             {mustBeMember(DAC1inf, {'direct', 'inverse'})}
        pathsNconsts        struct
        simulationVariables struct
    end

    % phase 1

    DAC0state = getDAC(0);
    DAC1state = getDAC(1);
    DAC0jump = 1;
    DAC1jump = 1;
    if ((DAC0target-getState(0))*DAC0inf > 0) DAC0dir = 1; else DAC0dir = -1; end
    if ((DAC1target-getState(1))*DAC1inf > 0) DAC1dir = 1; else DAC1dir = -1; end

    msg = "SUCCESS";

    while true
        
        if DAC0state + DAC0jump*DAC0dir < 0
            setDAC(DACnum=0,DACvalue=0);
        elseif DAC0state + DAC0jump*DAC0dir > 4095
            setDAC(DACnum=0,DACvalue=4095);
        else
            setDAC(DAC0state + DAC0jump*DAC0dir);
        end
        
        if DAC1state + DAC1jump*DAC1dir < 0
            setDAC(DACnum=1,DACvalue=0);
        elseif DAC1state + DAC1jump*DAC1dir > 4095
            setDAC(DACnum=1,DACvalue=4095);
        else
            setDAC(DAC1state + DAC1jump*DAC1dir);
        end

        DAC0state = getState(0);
        if ( (DAC0target - DAC0state)*DAC0inf*DAC0dir ) < 0 && ...
           ( (DAC1target - DAC1state)*DAC1inf*DAC1dir ) < 0
            break;
        end

        if getDAC(0) == 4095 && DAC0dir > 0
            msg = "DAC0 TOP BREACH";
            return;
        end
        if getDAC(0) == 0 && DAC0dir < 0
            msg = "DAC0 BOTTOM BREACH";
            return;
        end 

        DAC1state = getState(1);
        if getDAC(1) == 4095 && DAC1dir > 0
            msg = "DAC1 TOP BREACH";
            return;
        end
        if getDAC(1) == 0 && DAC1dir < 0
            msg = "DAC1 BOTTOM BREACH";
            return;
        end         
        
        DAC0jump = DAC0jump*2;
        DAC1jump = DAC1jump*2;
    end

    function state = getState(DACnum)
        mustBeMember(DACnum,[0 1]);
        result = simulate(pathsNconsts, simulationVariables);
        if (DACnum == 0) tune = DAC0tuning; else tune = DAC1tuning; end

        % this adds support to tuning a DAC by beta
        if tune == "beta"
            state = result.Ic/result.Ib;
        else
            state = result.(tune);
        end
    end

    function state = getDAC(DACnum)
        mustBeMember(DACnum,[0 1]);
        if DACnum == 0
            global DAC0; state = DAC0;
        else
            global DAC1; state = DAC1;
        end
    end
    
    function setDAC(DACnum, DACvalue)
        mustBeMember(DACnum,[0 1]);
        mustBeInteger(DACvalue);
        mustBeInRange(DACvalue,0,4095);

        if DACnum == 0
            global DAC0; DAC0 = DACvalue;
        else
            global DAC1; DAC1 = DACvalue;
        end
    end
end