road_length = 100;
road_width = 10;
desired_RMS = 0.0254;
crg = simplePSD(road_length, road_width, desired_RMS, ...
    'slope',4, ...
    'wavelengthRange',[0.3 10], ...
    'correlation',0.6);

crg_write(crg, 'sample.crg');
crg_show(crg);
