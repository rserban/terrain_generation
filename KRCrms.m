ft2m = 0.3048;
in2m = 0.0254;

road_length = 1000 * ft2m;
road_width = 15 * ft2m;

drop = -7.2 * ft2m;
slope = atan(drop/road_length);

res = 0.05;

RMS = [1, 1.5, 2, 3, 4];  % inches

for i = 1:length(RMS)
   name = sprintf('KRCrms_%.1f', RMS(i));
   fprintf('\n-----------\n%s\n-----------\n', name);
   crg = simplePSD(road_length, road_width, RMS(i)*in2m, ...
       'slope', slope, ...
       'resolution', res, ...
       'wavelengthRange', [0.3 10], ...
       'correlation', 1.0);
    
   crg_info(crg);
   crg_write(crg, strcat(name, '.crg'));
   crg_write_obj(crg, strcat(name, '.obj'));
   crg_write_hmap(crg, strcat(name, '.png'));
end