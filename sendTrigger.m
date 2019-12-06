function sendTrigger(action, Cfg)

if strcmp(Cfg.device, 'EEG')
    switch action
        case 'open'
            openparallelport_inpout32(hex2dec('d010'))
    
        case 'start'
            sendparallelbyte(Cfg.trigger.start);
    
        case 'reset'
            sendparallelbyte(0);
            
        case 'event'
            sendparallelbyte(Cfg.trigger.start);
            
        case 'abort'    
            sendparallelbyte(Cfg.trigger.abort);
            
        case 'end'
            sendparallelbyte(Cfg.trigger.end);
            
        case 'resp'
            sendparallelbyte(Cfg.trigger.resp);
            
            
    end
end

end