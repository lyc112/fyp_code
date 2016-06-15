% convert km/h to m/s
function ms_dataOut = kmh2ms(kmh_dataIn)

ratio = 3.6; % ratio of 1 km/h to 1 m/s

ms_dataOut = kmh_dataIn/ratio;

end