function msg = tuneBy(tune, by, target, relation, pathsNconsts, simulationVariables)
    arguments
        tune                {mustBeMember(tune, {'Ib','Vb','Ic','Vc','Ie','beta','beta PNP','Vcb','Vce','Vbe'})}
        by                  {mustBeMember(by, {'DAC0', 'DAC1'})}
        target              {mustBeNumeric}
        relation            {mustBeMember(relation, {'direct', 'inverse'})}
        pathsNconsts        struct
        simulationVariables struct
    end
  
    informLog(['starting to tune ' tune ' to ' string(target) ' by changing ' by]);
    [errorPlot, DACplot] = startPlot();
    DACstate = getDAC();
    % how much the function increases or decreases the DAC in each iteration 
    % allways starts from 1
    jump = 1;
    % inf is whether the DAC has to go up or down in reaction to the state
    % of the target increasing or decreasing
    if relation == "direct" inf=1; else inf=-1; end;
    % direction is whether the next iteration has to increase or decrease the DAC 
    if ((target-getState())*inf > 0) direction = 1; else direction = -1; end;
    % initiate msg as a SUCCESS message. 
    msg = "SUCCESS";
    % now the function changes the DAC in increasingly bigger jumps until
    % the state goes over the target
    informLog(['Initiating phase 1: increaing jumps']);
    state = getState();

    while true
        if DACstate + jump*direction < 0
            setDAC(0);
            informPlot(abs(state-target),getDAC());
        elseif DACstate + jump*direction > 4095
            setDAC(4095);
            informPlot(abs(state-target),getDAC());
        else
            setDAC(DACstate + jump*direction);
            informPlot(abs(state-target),getDAC());
        end
        state = getState();

        if (target - state)*inf*direction < 0
            break;
        end
        if getDAC() == 4095 && direction > 0
            msg = "TOP BREACH";
            return;
        end
        if getDAC() == 0 && direction < 0
            msg = "BOTTOM BREACH";
            return;
        end 
        jump = jump*2;
    end
    
    % now the function "zooms in", dividing 'jump' by half in each
    % iteration until it equals 1
    informLog('Initiating phase 2: zooming in');
    while jump > 1
        jump = fix(jump/2);
        state = getState();
        if (target - state)*inf > 0 direction=1; else direction=-1; end;
        setDAC(getDAC() + jump*direction);
        informPlot(abs(state-target),getDAC());
    end
    
    % final check: the program goes over the 5 DAC values closest to the
    % value it has reached up to this point and checks which one gets the
    % samllest error (smallest difference to the target)
    informLog('initiating phase 3: final chack');
    errors = []; DACvalues = [];
    for i = max((getDAC-2),0) : min((getDAC+2),4095)
        setDAC(i);
        informPlot(abs(state-target),getDAC());
        state = getState();
        errors(end + 1) = abs(state - target);
        DACvalues(end + 1) = i;
    end
    [error, minErrorIndex] = min(errors);
    % sets the DAC to be the ideal DAC 
    setDAC(DACvalues(minErrorIndex));
    informPlot(abs(state-target),getDAC());
    informLog(['ideal value for ' by ' found to be ' num2str(DACvalues(minErrorIndex)) ...
        '. error=' num2str(error) '. proportional error=' num2str(error/target)]);
    informLog('-');
    % this nested function returns the current state of what is being tuned
    function state = getState()
        result = simulate(pathsNconsts, simulationVariables);
        % this adds support to tuning a DAC by beta
        if tune == "beta"
            state = abs(result.Ic/result.Ib);
        elseif tune == "beta PNP"
            state = abs(result.Ie/result.Ib);
        elseif tune == "Vcb"
            state = result.Vc - result.Vb;
        elseif tune == "Vce"
            state = result.Vc - result.Ve;
        elseif tune == "Vbe"
            state = result.Vb - result.Ve;
        else
            state = result.(tune);
        end
    end

    
    % this nested function returns the current value of the dac.
    % it receive the dac as a string
    function state = getDAC
        if by == "DAC0"
            global DAC0; state = DAC0;
        elseif by == "DAC1"
            global DAC1; state = DAC1;
        end
    end
    
    % this nested function sets the right to DACvalue DAC by receiving the dac name as a
    % string
    function setDAC(DACvalue)
        % here the nested function makes sure it has received valid
        % arguments
        mustBeInteger(DACvalue);
        mustBeInRange(DACvalue,0,4095);

        if by == "DAC0"
            global DAC0; DAC0 = DACvalue;
        elseif by == "DAC1"
            global DAC1; DAC1 = DACvalue;
        end
    end
    
    function informPlot(error, DAC)
        mustBeNumeric(error);
        mustBeNumeric(DAC);
        errorPlot.YData(end+1) = error;
        DACplot.YData(end+1) = DAC;
    end

    function [errorPlot, DACplot] = startPlot
        global app;
        mustBeNonempty(app);
        errorPlot = plot(app.tuningAxesError,abs(getState()-target));
        errorPlot.Color = 'red';
        
        DACplot = plot(app.tuningAxesDAC,getDAC());
        DACplot.Color = 'blue';
        DACplot.Marker = 'o';
        DACplot.MarkerFaceColor = 'blue';
    end
end