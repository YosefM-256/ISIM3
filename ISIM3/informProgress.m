function informProgress(info)
    arguments
        info    string
    end
    global app;
    mustBeNonempty(app);
    indents = [repmat([char(9)],1,app.tabs.progress.indents)];
    app.tabs.progress.textarea.Value(end + 1) = {char(strjoin([indents info]))};
    app.tabs.progress.textarea.scroll("bottom");
end