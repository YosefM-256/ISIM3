function addProgressIndent
    global app;
    mustBeNonempty(app);
    app.tabs.progress.indents = app.tabs.progress.indents + 1;
end
