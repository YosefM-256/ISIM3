function setUpCirfile(pathsNconsts, variablesToSave)
    arguments
        pathsNconsts        struct
        variablesToSave     char
    end
    cirFileName = pathsNconsts.cirFileName;
    cirFile = fileread(cirFileName);
    splitCirfile = splitlines(string(cirFile));

    circuitParams = setUpParams(variablesToSave);
    for param = circuitParams
        paramIndex = find(contains(splitCirfile, param.lineInCirfile));
        splitCirfile(paramIndex) = param.lineInCirfile + num2str(param.value,8);
    end

    file = fopen(cirFileName, 'w');
    fprintf(file, strjoin(splitCirfile, "\n"));
    fclose(file);
end

function circuitParams = setUpParams(variablesToSave)
    global DAC0 DAC1;           % DACx has to be an integer
    global CRes;                % CRes being the collector resistor
    global EpwrPin;             % controls the emitter voltage (0 or 5V) 
    
    % THAT COULD IMPROVE
    % confirms that the global variabels have been initialized
    globalCheck = find([isempty(DAC0), isempty(DAC1), isempty(CRes), isempty(EpwrPin)],1);
    if globalCheck
        varsForError = ["DAC0" "DAC1" "CRes" "EpwrPin"];
        errorMSG = varsForError(globalCheck) + " is not initialized";
        error(errorMSG);
    end

    % makes sure all the global variables have valid values
    mustBeInteger(DAC0); mustBeInRange(DAC0,0,4095);
    mustBeInteger(DAC1); mustBeInRange(DAC1,0,4095);
    mustBeMember(CRes,[0 1]);
    mustBeMember(EpwrPin,[0 1]);
%     
%     assert(isinteger(DAC0), "DAC0 is not an integer");
%     assert(isinteger(DAC1), "DAC1 is not an integer");
%     assert(DAC0 < 4096 && DAC0 >= 0, "%d is not a valid value for DAC0", DAC0);
%     assert(DAC1 < 4096 && DAC1 >= 0, "%d is not a valid value for DAC0", DAC1);
%     assert(any(CRes == int16([0 1 2])));
%     assert(any(BRes == int16([0 1])));
% 
    % creates 5 structs with equal fileds:
    % "lineInCirfile"   - the beginning of the relevant line in the SPICE file
    % "value"           - the value which is written after the line
    % the structs include the two DACs, the collector resistor (CRes), the
    % base resistor (BRes) and all the variables to save
    circuitParams = ...
        [struct( 'lineInCirfile', {".PARAM DAC0Param=",".PARAM DAC1Param=",".PARAM CRes=",".PARAM EpwrPin="}, ...
                'value', {DACbinToVolt(DAC0), DACbinToVolt(DAC1), CRes, EpwrPin}), ...
         struct( 'lineInCirfile', ".SAVE ", 'value', variablesToSave)];

end