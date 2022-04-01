function [] = crg_write_obj(crg, filename)
% crg_write_obj - export the CRG road surface to a Wavefront obj file
%    crg_write_obj(crg, filename)

addpath(genpath('../WOBJ_toolbox/'));

z = crg.z;
nu = size(z, 1);

if length(crg.u) == 1
    len = crg.u;
else
    len = crg.u(2) - crg.u(1);
end

if length(crg.v) == 1
    v = [-crg.v crg.v];
else
    v = crg.v;
end

du = len / (nu-1);
u = (0:du:len);

% Create triangularization
[x,y] = meshgrid(double(u), double(v));
T = delaunay(x,y);

% Evaluate z at all mesh points
zz = crg_eval_uv2z(crg, [x(:) y(:)]);

% Calculate surface normals
[nx,ny,nz] = surfnorm(x,y,z');

% % figure
% % fasp = 0.01;
% % if isfield(crg, 'fopt') && isfield(crg.fopt, 'asp')
% %     fasp = crg.fopt.asp;
% % end
% % trisurf(T,x,y,z')
% % shading interp
% % daspect([1 1 fasp])
% % axis vis3d
% % view(0,0)
% % grid on

% Create OBJ structure
OBJ.vertices = [x(:) y(:) zz];
OBJ.vertices_normal = [nx(:) ny(:) nz(:)];
OBJ.objects(1).type = 'f';
OBJ.objects(1).data.vertices = T;
OBJ.objects(1).data.normal = T;

write_wobj(OBJ, filename);


