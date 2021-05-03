ft2m = 0.3048;
in2m = 0.0254;

road_length = 1000 * ft2m;
road_width = 15 * ft2m;
desired_RMS = 2 * in2m;

drop = 7.2 * ft2m;
slope = atan(drop/road_length);

crg = simplePSD(road_length, road_width, desired_RMS, ...
    'slope', slope, ...
    'wavelengthRange',[0.3 10], ...
    'correlation', 0.6);

crg_show(crg);

crg_write(crg, 'sample.crg');
crg_write_obj(crg, 'sample.obj');
crg_write_hmap(crg, 'sample.png');
