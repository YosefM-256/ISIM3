function setEpwr(Epwr)
    mustBeMember(Epwr,[0 1]);
    global EpwrPin;
    EpwrPin = Epwr;
end