in2m = 0.0254;

length = 20;
width = 4;
desired_RMS = 4 * in2m;

drop = 0;
slope = atan(drop/length);

%path = [0 0; length 0];
path = [ 0 0; 5 0; 10 2; 15 4; 20 2; 25 2];

% -------------------------------------------------------------------------

poly = polybuffer(path, 'lines', width/2);
figure
hold on
grid on
plot(path(:,1), path(:,2), 'r.', 'MarkerSize', 10);
plot(poly)
axis equal

% -------------------------------------------------------------------------

crg = simplePSD_path(path, width, desired_RMS, ...
    'slope', slope, ...
    'wavelengthRange',[0.3 10], ...
    'correlation', 0.4);

crg_show(crg);
crg_info(crg);
crg_write(crg, 'sample.crg');
crg_write_obj(crg, 'sample.obj');
crg_write_hmap(crg, 'sample.png');
