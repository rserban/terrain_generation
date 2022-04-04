

%%

% Path waypoints (will be smoothed with piecewise cubic Hermite)
path = [ 0 0; 5 0; 10 2; 15 4; 20 2; 25 2];

% Road width
width = 4;

% Desired RMS (road roughness) in inches
RMS = 4; 

% Slope in radians
slope = 0;

% Left/right RMS correlation
corr = 1.0;

% SPH separation
sph_delta = 0.02;

% Show CRG plots?
show_crg = true;

% Show SPH plots?
show_sph = true;

%%
addpath(genpath('RMS_generator'));
addpath(genpath('SPH_generator'));

% Create output directory
out_dir = sprintf('rms%.1f_%.1f_%.1f', RMS, width, slope);
mkdir('.', 'DATA');
mkdir('DATA', out_dir);

%% Create road mesh

% Create CRG road specification
in2m = 0.0254;
crg = simplePSD_path(path, width, RMS * in2m, ...
    'slope', slope, ...
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


