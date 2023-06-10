function setCRes(CResNum)
    mustBeMember(CResNum,[0 1]);
    global CRes;
    CRes = CResNum;
end