%% Fast auditory periodic stimulation - for EEG
% From the other two scripts ToPLAY

openparallelport_inpout32(hex2dec('d010'))


b = 200;
sendparallelbyte(b);   
sendparallelbyte(0);
