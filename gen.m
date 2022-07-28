%% Problem specification
%
% Driver for generating SPH and BCE markers for an RMS lane along path

% -------------------------------------------------------------------------
% Radu Serban
% -------------------------------------------------------------------------

% Prefix for output directory.
% The output directory (under DATA/) will be named
%    [prefix]_rms[A]-[B]_[C]-[D]-[E]
% where
%    A - RMS value (inches)
%    B - lane RMS correlation
%    C - lane width (m)
%    D - slope (rad)
%    E - banking (rad)
prefix = 'Scurve';

% Path waypoints (will be smoothed with piecewise cubic Hermite)
% x-y pairs (m)
path = [ 0 0; 10 0; 20 5; 25 5];

% Road width (m)
width = 4;

% Desired road roughness as RMS (inches)
RMS = 0;

% Slope (rad)
slope = 0 * (pi / 180);

% Banking (rad)
banking = 0 * (pi / 180);

% Left/right RMS correlation
corr = 1.0;

% SPH separation (m)
sph_delta = 0.02;

% Show CRG plots?
show_crg = true;

% Show SPH plots?
show_sph = true;

%% Create output directory

out_dir = sprintf('%s_rms%.1f-%.1f_%.1f-%.1f-%.1f', prefix, ...
    RMS, corr, ...
    width, slope, banking);
mkdir('.', 'DATA');
mkdir('DATA', out_dir);

addpath(genpath('OpenCRG_toolbox'));
crg_init
addpath(genpath('RMS_generator'));
addpath(genpath('SPH_generator'));

%% Write slope and banking

slope_file = sprintf('DATA/%s/slope.txt', out_dir);
fs = fopen(slope_file, 'w');
fprintf(fs, '%f %f\n', slope, banking);
fclose(fs);

%% Write path file

n = size(path, 1);

pz = zeros(n, 1);
for i = 2:n
   dx = path(i,1) - path(i-1,1);
   dy = path(i,2) - path(i-1,2);
   pz(i) = pz(i-1) + dx * tan(slope) + dy * tan(banking);
end

path_file = sprintf('DATA/%s/path.txt', out_dir);
fp = fopen(path_file, 'w');
fprintf(fp, '%d 3\n', n);
fprintf(fp, '%f %f %f\n', [path  pz]');
fclose(fp);

%% Create road mesh

% Create CRG road specification
in2m = 0.0254;
crg = simplePSD_path(path, width, RMS * in2m, ...
    'slope', slope, ...
    'banking', banking, ...
    'wavelengthRange',[0.3 10], ...
    'correlation', corr);

if show_crg
   crg_show(crg);
   crg_info(crg);
end

% Write OBJ file
mesh_file = sprintf('DATA/%s/mesh.obj', out_dir);
crg_write_obj(crg, mesh_file);

%% Create SPH and BCE markers

sph_gen(mesh_file, sph_delta, show_sph);




