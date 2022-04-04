obj_file = 'rms4_20x4.obj';
delta = 0.02;
min_depth = 0.3;
num_bce = 3;
use_refined_mesh = false;
flat_bottom = false;
flat_top = false;

render = false;

% -------------------------------------------------------------------------
addpath(genpath('../WOBJ_toolbox/'));
% -------------------------------------------------------------------------
[filepath, filename, fileext] = fileparts(obj_file);
% -------------------------------------------------------------------------

OBJ = read_wobj(obj_file);
f = [];
for i = 1:length(OBJ.objects)
    f = [f , OBJ.objects(i).data.vertices];
end
v = OBJ.vertices;

% Project mesh vertices onto z=0 plane
v_prj = v;
v_prj(:,3) = 0;

% Create the projected mesh (triangulation); extract free (boundary) edges
tri_prj = triangulation(f, v_prj);
bndry_prj = freeBoundary(tri_prj);

[f_bndry, v_bndry] = freeBoundary(tri_prj);

% Create a polygon from the boundary
start = f_bndry(1,1);
p1 = v_bndry(start,1:2);
next = f_bndry(1,2);
while (next ~= start)
    %%fprintf('%d\n', next);
    p1 = [p1; v_bndry(next, 1:2)];
    next = f_bndry(f_bndry(:,1) == next, 2);
end
poly1 = polyshape(p1);
p1 = poly1.Vertices;

% Expand polygon outwards
poly2 = polybuffer(poly1, delta * num_bce, 'JointType', 'miter');
p2 = poly2.Vertices;

% -------------------------------------------------------------------------

% Find mesh bounding box
vmin = min(v,[],1);
vmax = max(v,[],1);

% Create 2D grid with given spacing to cover expanded polygon
x = min(p2(:,1)) : delta : max(p2(:,1));
y = min(p2(:,2)) : delta : max(p2(:,2));

% Traverse the 2D grid and check if grid node inside poly1 and/or poly2.
% Collect grid nodes in two arrays
est_size = length(x) * length(y);
n1 = zeros(est_size, 2);
n2 = zeros(est_size, 2);
i1 = 0;
i2 = 0;
for ix = 1:length(x)
    for iy = 1:length(y)
        check2 = inpolygon(x(ix), y(iy), p2(:,1), p2(:,2));
        if ~check2
            continue
        end
        check1 = inpolygon(x(ix), y(iy), p1(:,1), p1(:,2));   
        if check1
           i1 = i1 + 1;
           n1(i1,:) = [x(ix) y(iy)];
        else
           i2 = i2 + 1;
           n2(i2,:) = [x(ix) y(iy)];
        end
    end
end
fprintf('Inside points:   %d\n', i1);
fprintf('Wallside points: %d\n', i2);
n1 = n1(1:i1,:);
n2 = n2(1:i2,:);

% -------------------------------------------------------------------------
if render
    figure
    hold on
    axis equal
    triplot(tri_prj)
    plot(poly1)
    plot(poly2)
end
% -------------------------------------------------------------------------

% Create interpolant from original mesh
F = scatteredInterpolant(v(:,1), v(:,2), v(:,3));

% Evaluate interpolant to set height at inner grid nodes
F.Method = 'linear';
h1 = F(n1(:,1), n1(:,2));

% If indicated, use the refined mesh for extrapolation
if use_refined_mesh
    v = [n1, h1];
    F = scatteredInterpolant(v(:,1), v(:,2), v(:,3));
end

% Evaluate interpolant to set height at side wall grid nodes
F.ExtrapolationMethod = 'nearest';
h2 = F(n2(:,1), n2(:,2));

% -------------------------------------------------------------------------
if render
    figure
    hold on
    grid on
    axis equal
    plot3(n1(:,1), n1(:,2), h1, 'g.')
    plot3(n2(:,1), n2(:,2), h2, 'r.')
    view(35,15)
end
% -------------------------------------------------------------------------

% Open output files
delta_mm = cast(delta * 1000, 'uint8');
fname1 = sprintf('%s_%dmm_particles.txt', filename, delta_mm);
fname2 = sprintf('%s_%dmm_bce.txt', filename, delta_mm);
f1 = fopen(fname1, 'w');
f2 = fopen(fname2, 'w');
fprintf(f1, 'x, y, z,\n');
fprintf(f2, 'x, y, z,\n');

% Create initial SPH particle locations and bottom BCE markers.
% For each inner grid point, create markers in a vertical segment
n_part = 0;
n_bce = 0;
for i = 1:length(h1)
    % SPH markers
    if flat_bottom
       h = vmin(3) - min_depth; 
    else
       h = h1(i) - min_depth; 
    end
    while h <= h1(i)
       fprintf(f1, '%f, %f, %f,\n', n1(i,1), n1(i,2), h);
       h = h + delta;
       n_part = n_part + 1;
    end
    
    % Bottom BCE markers
    if flat_bottom
        h = vmin(3) - min_depth - delta;
    else
        h = h1(i) - min_depth - delta;
    end
    for j = 1:num_bce
        fprintf(f2, '%f, %f, %f,\n', n1(i,1), n1(i,2), h);
        h = h - delta;
        n_bce = n_bce + 1;
    end
end

% Create the BCE markers for the side walls.
for i = 1:length(h2)
    if flat_bottom
       h = vmin(3) - min_depth - num_bce * delta; 
    else
       h = h2(i) - min_depth - num_bce * delta;
    end
    if flat_top
        hmax = vmax(3) + num_bce * delta;
    else
        hmax = h2(i) + num_bce * delta; 
    end
    while h <= hmax
        fprintf(f2, '%f, %f, %f,\n', n2(i,1), n2(i,2), h);
        h = h + delta;
        n_bce = n_bce + 1;
    end
end

fclose(f1);
fclose(f2);

fprintf('SPH markers: %d\n', n_part);
fprintf('BCE markers: %d\n', n_bce);

% -------------------------------------------------------------------------
if render
    figure
    hold on
    grid on
    axis equal
    P = csvread(fname1, 1, 0);
    plot3(P(:,1),P(:,2),P(:,3), 'g.')
    B = csvread(fname2, 1, 0);
    plot3(B(:,1),B(:,2),B(:,3), 'r.')
    view(35,15)
end
% -------------------------------------------------------------------------
