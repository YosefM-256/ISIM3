setCRes(2); setBRes(1);
r = {};

for i = 100:100:4000
    for j = 100:100:4000
        setDAC0(i);
        setDAC1(j);
        r{end+1} = simulate(pathsNconsts,simulationVariables);
    end
end

r = cell2mat(r);

