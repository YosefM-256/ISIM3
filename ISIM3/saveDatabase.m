function saveDatabase(pathsNconsts)
    arguments
        pathsNconsts        struct      
    end
    assert(isfield(pathsNconsts,'databasePath'));
    global database;
    assert(~isempty(database),"the database is empty");
    save(pathsNconsts.databasePath,"database");
    informLog([num2str(length(database)) "simulations were saved into the database"]);
end

