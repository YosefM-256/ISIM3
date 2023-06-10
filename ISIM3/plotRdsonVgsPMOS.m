function results = plotRdsonVgsPMOS(Id, VgsSet, pathsNconsts, simulationVariables)
    arguments
        Id                      double      {mustBeInRange(Id,0,1)}
        VgsSet                  double      {mustBeNonempty, mustBePositive, mustBeInRange(VgsSet,0,4095)}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgsSet),"The Vgs set must be in ascending order");
    informLog(["** starting [Rdson - Vgs](PMOS) plot for Id=" num2str(Id) " **"]);
    
    setBRes(1);
    CResNum = 0;
    setCRes(CResNum);
    results = {};

    for i = VgsSet
        setDAC1(i);
        msg = tuneToId;
        if msg == "SUCCESS"
            results{end+1} = simulate(pathsNconsts,simulationVariables);
        else
            results = cell2mat(results);
            informProgress(['[Rdson - Vgs](PMOS) plot for Id=' num2str(Id) ' completed']);
            return;
        end
    end
    results = cell2mat(results);
    informProgress(['[Rdson - Vgs](PMOS) plot for Id=' num2string(Id) ' completed']);

    function msg = tuneToId
        msg = tuneBy("Ic","DAC0",Id,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum < 2
            informLog(['a TOP BREACH occured while trying to tune DAC0 for Id=' num2str(Id) ...
                '.Switching to Rc=' num2str(10^(2-CResNum)) 'Ohm']);
            CResNum = CResNum + 1;
            setCRes(CResNum);
            msg = tuneToId;
        end
        if msg == "TOP BREACH" && CResNum == 2
            informLog(['the TOP BREACH for Id=' num2str(Id) ' repeated when Rc=10 Ohm']);
            msg = "TOP BREACH";
            return;
        end
    end 
end