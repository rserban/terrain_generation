% Ensure we reproduce results at each run
rng(0, 'twister')
% ---------------------------------------

ft2m = 0.3048;
in2m = 0.0254;

% Course length and width of each lane
lane_length = 1000 * ft2m;
lane_width = 15 * ft2m;

% Lane slope (drop from East to West)
drop = -7.2 * ft2m;
slope = atan(drop/lane_length);

% RMS lane values (from North to South)
RMS = [3.0, 4.0, 1.0, 1.5, 2.0];  % inches

% Resolution
res = 0.05;

crg = simplePSD_multi(lane_length, lane_width, slope, RMS * in2m, res);

crg_info(crg);
crg_write(crg, 'KRCrms_all.crg');
crg_write_obj(crg, 'KRCrms_all.obj');
crg_write_hmap(crg, 'KRCrms_all.png');
