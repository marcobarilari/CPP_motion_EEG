function [QUIT, responseTime] = getBehResp(Cfg, responseTime)

QUIT = false;

[Keypr, KeyTime, Key] = KbCheck;

if Keypr
    if Key(Cfg.KeyCodes.Escape)
        
        QUIT= true;
        
    elseif Key(Cfg.KeyCodes.Resp)
        
        
        
        
        
        % only collects responses if there was no previous response 
        % need to find a way to collect several responses
        
        
        
        
        
        if isempty(responseTime)
            
            responseTime = KeyTime - Cfg.Experiment_start;
            
            sendTrigger('resp', Cfg)
            sendTrigger('reset', Cfg)
            
        end
        
    end
    
end

end

