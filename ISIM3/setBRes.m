function setBRes(BResNum)
    error("the BRes option was deactivated");
    mustBeMember(BResNum,[0 1]);
    global BRes;
    BRes = BResNum;
end