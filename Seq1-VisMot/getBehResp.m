function [QUIT, responseTime] = getBehResp(Cfg, responseTime)

QUIT = false;

[Keypr, secs, Key] = KbCheck;

if Keypr
    if Key(Cfg.KeyCodes.Escape)
        QUIT= true;
    elseif Key(Cfg.KeyCodes.Resp) 
        responseTime(end+1) = secs;
    end
end

end

