function results = sweepDAC0Vgs(VgsList,DAC0set,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgsList),"The Vgs set must be in ascending order");

    setBRes(1);
    setCRes(2);
    results = {};
    
    for Vgs=VgsList
        result = struct();
        [VgsResult,msg] = IdVgs(Vgs,DAC0set,pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            informLog(['abandoning Vgs plot with Vgs=' num2str(VgsList) '. A TOP BREACH occured']);
            return;
        end
        result.data = VgsResult;
        result.Vgs = Vgs;
        results{end+1} = result;
    end
    results = cell2mat(results);
end

function [VgsResult, msg] = IdVgs(Vgs,DAC0set,pathsNconsts,simulationVariables)
    informLog(["** starting DAC0 sweep for Vgs=" num2str(Vgs) " **"]);

    setBRes(1);
    setCRes(2);
    VgsResult = {};
    msg = "SUCCESS";

    for i=DAC0set
        setDAC0(i);
        msg = tuneBy("Vb","DAC1",Vgs,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    VgsResult = cell2mat(VgsResult);
end