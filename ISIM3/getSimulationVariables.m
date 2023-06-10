function simulationVariables = getSimulationVariables(pathsNconsts)
    arguments
        pathsNconsts    struct
    end
    cd(pathsNconsts.homePath);

    % assure the program is running in the home directory
    assert(strcmp(pathsNconsts.homePath, cd), "the program is not running in the home directory");

    variablesFile = fileread(pathsNconsts.variablesFile);
    % splits the text so now there's an array of strings of size Nx2 where
    % N is the number of variables in the variables file
    splitVariablesFile = split(splitlines(string(variablesFile)));
    
    % the first line in the variables file is the "cirNames simNames" line,
    % so simVars and cirVars select one colums each from the second line to
    % the end of the file.
    % this result is transposed, so simVars and cirVars will be horizontal,
    % meaning they'll be 1xN instead of Nx1
    simVars = splitVariablesFile(2:end,2)';
    cirVars = splitVariablesFile(2:end,1)';
    simulationVariables = struct('cirName', num2cell(cirVars), 'simName', num2cell(simVars));
end
    




    