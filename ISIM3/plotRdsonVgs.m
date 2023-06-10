function results = plotRdsonVgs(Id, VgsSet, pathsNconsts, simulationVariables)
    arguments
        Id                      double      {mustBeInRange(Id,0,1)}
        VgsSet                  double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgsSet),"The Vgs set must be in ascending order");
    VgsSet = VgsSet(end:-1:1);
    informLog(["** starting [Rdson - Vgs](NMOS) plot for Id=" num2str(Id) " **"]);
    
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
            informProgress(["[Rdson - Vgs](NMOS) plot for Id=" num2str(Id) " was completed successfully"]);
            results = cell2mat(results);
            return;
        end
    end
    informProgress(["[Rdson - Vgs](NMOS) plot for Id=" num2str(Id) " was completed successfully"]);
    results = cell2mat(results);

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