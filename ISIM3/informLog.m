function informLog(info)
    arguments
        info string
    end
    global app;
    mustBeNonempty(app);
    app.tabs.log.textarea.Value(end + 1) = {char(strjoin(info))};
    app.tabs.log.textarea.scroll("bottom");
end