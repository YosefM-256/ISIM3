function dataToPlot(simulations, plotType, plotPanel)
    arguments
        simulations            {mustBeNonempty}
        plotType               {mustBeMember(plotType,[ "Ic - Vce NPN","hfe - Ic NPN","Vcesat - Ic NPN","Vbesat - Ic NPN", ...
                                                        "Id - Vds NPN","Rdson - Id NPN","Id - Vgs NPN","Rdson - Vgs NPN"])}
        plotPanel   
    end
%     global app;
%     mustBeNonempty(app);

    if plotType == "Ic - Vce NPN"
        dataToPlotIcVce;
    end
    if plotType == "hfe - Ic NPN"
        dataToPlothfeIc;
    end
    if ismember(plotType,["Vcesat - Ic NPN" "Vbesat - Ic NPN"])
        dataToPlotVsatIc
    end
    if plotType == "Id - Vds"
        dataToPlotIdVds
    end
    if plotType == "Rdson - Id"
        dataToPlotRdsonId
    end
    if plotType == "Id - Vgs"
        dataToPlotIdVgs
    end
    if plotType == "Rdson - Vgs"
        dataToPlotRdsonVgs
    end

    function dataToPlotIcVce
        ax = uiaxes(plotPanel,'NextPlot','add');
        title(ax,plotType);
        xlabel(ax,"$$Vce$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$I_c$$",Interpreter="latex",FontAngle="normal",Rotation=0);
        for ib = simulations
            plot(ax, [ib.data.Vc]-[ib.data.Ve], [ib.data.Ic]);
        end
        legend(ax,string([simulations.Ib]));
    end

    function dataToPlothfeIc
        ax = uiaxes(plotPanel,'XScale','log');
        title(ax,"$$\beta - I_c$$",Interpreter="latex");
        xlabel(ax,"$$Ic$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$\beta$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
        plot(ax, [simulations.Ic], [simulations.Ic]./[simulations.Ib]);
        ax.YLim(1) = 0;
    end

    function dataToPlotVsatIc
        ax = uiaxes(plotPanel,'XScale','log');
        xlabel(ax,"$$Ic$$",Interpreter="latex",FontAngle="normal");
        if plotType == "Vcesat - Ic"
            ylabel(ax,"$$V_{CE}$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
            plot(ax, [simulations.Ic], [simulations.Vc]-[simulations.Ve]);
        elseif plotType == "Vbesat - Ic"
            ylabel(ax,"$$V_{BE}$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
            plot(ax, [simulations.Ic], [simulations.Vb]-[simulations.Ve]);         
        end
        ax.YLim(1) = 0;
    end

    function dataToPlotIdVds
        ax = uiaxes(plotPanel);
        xlabel(ax,"$$V_{DS}$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$I_D$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
        for Vgs = simulations
            plot(ax, [Vgs.data.Vc], [Vgs.data.Ic]);
        end
        legend(ax,string([simulations.Vgs]));
    end
     
    function dataToPlotRdsonId
        ax = uiaxes(plotPanel);
        xlabel(ax,"$$I_{D}$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$R_{DS_{on}}$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
        for Vgs = simulations
            Rdson = [Vgs.data.Vc]./[Vgs.data.Ic];
            plot(ax, [Vgs.data.Ic], Rdson);
        end
        legend(ax,string([simulations.Vgs]));
    end
    
    function dataToPlotIdVgs
        ax = uiaxes(plotPanel,'YScale','log');
        xlabel(ax,"$$V_{GS}$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$I_D$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
        Id = abs([simulations.Ic]);
        plot(ax, [simulations.Vb], Id);
    end

    function dataToPlotRdsonVgs
        ax = uiaxes(plotPanel);
        xlabel(ax,"$$V_{GS}$$",Interpreter="latex",FontAngle="normal");
        ylabel(ax,"$$R_{DS_{on}}$$",Interpreter="latex",FontAngle="normal",Rotation=0,FontWeight="bold");
        Rdson = [simulations.Vc]./[simulations.Ic];
        plot(ax, [simulations.Vb], Rdson);
        ax.XLim(1) = 0;
    end

end