function results = plotIcVce(Ibs,DAC0set,pathsNconsts,simulationVariables)
    arguments
        Ibs                     double      {mustBePositive, mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(Ibs),"The 'Ibs' argument must be in ascending order");
    
    informLog("starting [Ic - Vce](NPN) graph");
    informProgress("starting [Ic - Vce](NPN) plot");
    addProgressIndent;

    results = {};
    for Ib = Ibs
        informLog(['starting plot for Ib=' num2str(Ib)]);
        result = struct();
        [IbResult, msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            informLog(['abandoning Ib plot with Ib=' num2str(Ib) '. A TOP BREACH occured']);
            return;
        end
        result.data = IbResult;
        result.Ib = Ib;
        results{end+1} = result;
    end
    results = cell2mat(results);
end

function [results, msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables)
    arguments 
        Ib                      double      {mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    setCRes(1);
    setEpwr(0);
    results = {};

    for i=DAC0set
        setDAC0(i);
        msg = tuneBy("Ib","DAC1",Ib,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            informLog(['A TOP BREACH occured for Ib=' num2str(Ib) '. Abandoning plot.']);
            results = 0;
            return;
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    results = cell2mat(results);
    informProgress(['[Ic - Vce](NPN) plot completed for Ib=' num2str(Ib)]);

end

    