function [] = crg_write_obj(crg, filename)
% crg_write_obj - export the CRG road surface to a Wavefront obj file
%    crg_write_obj(crg, filename)

% -------------------------------------------------------------------------
% Radu Serban
% -------------------------------------------------------------------------

addpath(genpath('../WOBJ_toolbox/'));

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

du = crg.head.uinc;
u = (0:du:len);

z = crg.z';

% Create mesh grid in (uv) space
[U, V] = meshgrid(double(u), double(v));
T = delaunay(U,V);

% Create triangularization in (xy) space
XY = crg_eval_uv2xy(crg, [U(:) V(:)]);
x = reshape(XY(:,1), size(U));
y = reshape(XY(:,2), size(U));

% Calculate surface normals
[nx,ny,nz] = surfnorm(x,y,z);

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
OBJ.vertices = [x(:) y(:) z(:)];
OBJ.vertices_normal = [nx(:) ny(:) nz(:)];
OBJ.objects(1).type = 'f';
OBJ.objects(1).data.vertices = T;
OBJ.objects(1).data.normal = T;

write_wobj(OBJ, filename);


