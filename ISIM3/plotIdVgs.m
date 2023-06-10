function results = plotIdVgs(Vds, VgsSet, VdsTopBreachAction, pathsNconsts, simulationVariables)
    arguments
        Vds                     double      {mustBeInRange(Vds,0,10)}
        VgsSet                  double      {mustBeNonempty, mustBePositive}
        VdsTopBreachAction      string      {mustBeMember(VdsTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    informLog(["** starting [Id - Vgs](PMOS) plot for Vds=" num2str(Vds) " **"]);
    
    setBRes(1);
    CResNum = 0;
    setCRes(CResNum);
    results = {};

    for i = VgsSet
        setDAC1(i);
        msg = tuneToVds;
        if msg ~= "SUCCESS"
            if VdsTopBreachAction == "error"
                informLog("FATAL ERROR: TOP BREACH occured while tuning Vds in [Id - Vgs] plot");
                informLog("***");
                error("TOP BREACH occured while tuning Vds to %d",Vds);
            end
            if VdsTopBreachAction == "return"
                results = cell2mat(results);
                informLog("ERROR: [Id - Vgs] plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vds. The program will continue to run");
                results = cell2mat(results);
                return;
            end
            if VdsTopBreachAction == "notice"
                results = cell2mat(results);
                informLog("ERROR: [Id - Vgs] plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vds. The program will continue to run");
                informLog("the option VdsTopBreachAction=notice is not defined yet");
                results = cell2mat(results);
                return;
            end
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    results = cell2mat(results);

    function msg = tuneToVds
        informLog("finding maximum DAC1 to start the DAC1set from");
        msg = tuneBy("Vc","DAC0",Vds,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum < 2
            informLog(['a TOP BREACH occured while trying to tune DAC0 for Vds=' num2str(Vds) ...
                '.Switching to Rc=' num2str(10^(2-CResNum)) 'Ohm']);
            CResNum = CResNum + 1;
            setCRes(CResNum);
            msg = tuneToVds;
        end
        if msg == "TOP BREACH" && CResNum == 2
            informLog(['the TOP BREACH for Vc=' num2str(Vds) ' repeated when Rc=10 Ohm']);
            msg = "TOP BREACH";
            return;
        end
    end
end