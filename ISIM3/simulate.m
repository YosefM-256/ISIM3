function results = simulate(pathsNconsts, simulationVariables)
    arguments
        pathsNconsts        struct
        simulationVariables struct
    end
    [isInDatabase, results] = checkDatabase(pathsNconsts);
    if ~isInDatabase
        setUpCirFile(pathsNconsts,strjoin([simulationVariables.cirName]));
        runSimulation(pathsNconsts);
        results = readResults(pathsNconsts, simulationVariables);
    end
    results = checkCurrents(results);
    results = addSpecs(results);
    updateDatabase(results);
    upCirDiagram(results);
    results.Ve
end

function runSimulation(pathsNconsts)
    arguments
        pathsNconsts        struct
    end
    cd(pathsNconsts.LTSpicePath);   % changes directory to the LTSpice directory
    system([pathsNconsts.simulationCommand ' ' pathsNconsts.homePath '\' pathsNconsts.cirFileName]);    % execute the simulation
    cd(pathsNconsts.homePath);      % changes directory back to the home directory
end

function results = readResults(pathsNconsts, simulationVariables)
    arguments
        pathsNconsts        struct
        simulationVariables struct  % is of the format cirName: "BOB", simName: "JOSH"
    end
    % makes sure that the program is in the home directory
    assert(strcmp(pathsNconsts.homePath, cd), "the program is not in the home directory");
    rawFile = fileread(pathsNconsts.rawFileName);
    rawFileSplit = splitlines(string(rawFile));
    
    varsLine = find(rawFileSplit == "Variables:");
    valuesLine = find(rawFileSplit == "Values:");
    varsAmount = valuesLine-varsLine-1;     % the number of variables present in the .raw file

    vars = split(rawFileSplit(varsLine+1:valuesLine-1)); 
    vars = vars(:,3);      % vars become a string array of the cir name of the variables
    values = split(rawFileSplit(valuesLine+1:valuesLine+varsAmount));
    values = values(:,2);

    % varsNum is the amount of variables in simulationVariables
    varsNum = size(simulationVariables,2);

    % start a cell array of shape 2xN where N is the amount of variables in
    % simulationVariables
    cellResults = cell(2, varsNum);  

    for v = 1:varsNum
        cellResults{1, v} = simulationVariables(v).simName;
        cellResults{2, v} = str2double(values(find(strcmp(vars,simulationVariables(v).cirName))));
    end
    results = struct(cellResults{:});
end

function results = checkCurrents(results)
    arguments
        results     struct      {mustBeNonempty}
    end
    if ~isfield(results, 'Ic')
        results.Ic = results.IRC1k + results.IRC10;
    end
    if ~isfield(results, 'Ib')
        results.Ib = results.IRB100;
    end
    if ~isfield(results, 'Ie')
        results.Ie = -1*(results.Ib + results.Ic);
    end

end

function results = addSpecs(results)
    arguments
        results     struct      {mustBeNonempty}
    end
    global DAC0 DAC1 CRes EpwrPin;
    results.DAC0 = DAC0;
    results.DAC1 = DAC1;
    results.CRes = CRes;
    results.EpwrPin = EpwrPin;
end

function [isInDatabase, results] = checkDatabase(pathsNconsts)
    arguments
        pathsNconsts        struct
    end

    global DAC0 DAC1 CRes EpwrPin;

    global database databasePath;

    databaseFileExists = checkDatabaseFileExists;
    if ~databaseFileExists
        isInDatabase = false;
        results = 0;
        return;
    end
    if isempty(database)
        database = loadDatabase;
        databasePath = pathsNconsts.databasePath;
    elseif databasePath ~= pathsNconsts.databasePath
        database = loadDatabase;
        databasePath = pathsNconsts.databasePath;
    end

    isInDatabase =  ([database.DAC0] == DAC0) & ...
                    ([database.DAC1] == DAC1) & ...
                    ([database.CRes] == CRes) & ...
                    ([database.EpwrPin] == EpwrPin);
    if any(isInDatabase)
        matchingResults = find(isInDatabase);
        results = database(matchingResults(1));
        isInDatabase = true;
        return
    else
        isInDatabase = false;
        results = 0;
        return
    end

    function database = loadDatabase
        assert(isfield(pathsNconsts,'databasePath'),"the database path is not defined in pathsNconsts");
        database = load(pathsNconsts.databasePath);
        assert(isfield(database,'database'), 'the database is not saved as "database" field');
        database = database.database;
        informLog([num2str(length(database)) "simulations loaded from database " pathsNconsts.databasePath]);
    end

    function dataBaseFileExists = checkDatabaseFileExists
        filesInDirectory = string({dir().name});
        dataBaseFileExists = any(filesInDirectory == pathsNconsts.databasePath);
    end
end

function updateDatabase(results)
    global database;
    if isempty(database)
        database = results;
        return;
    end
    database(end+1) = results;
end

    

