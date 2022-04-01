function [] = crg_write_hmap(crg, filename)
% crg_write_hmap - export the CRG road surface to a height map image
%    crg_write_obj(crg, filename)
% Note that crg_write_hmap always writes a 16-bit PNG format, regardless
% of the file extension in 'filename'.  

z = crg.z;
nu = size(z, 1);

if length(crg.u) == 1
    len = crg.u;
else
    len = crg.u(2) - crg.u(1);
end

if length(crg.v) == 1
    width = 2 * crg.v;
else
    width = crg.v(end) - crg.v(1);
end

du = len / (nu-1);
u = (0:du:len);
v = (0:du:width);
nv = length(v);

% Create triangularization
[x,y] = meshgrid(double(u), double(v));

% Evaluate z at all mesh points
z2 = crg_eval_uv2z(crg, [x(:) y(:)]);
zmin = min(z2);
zmax = max(z2);

% Option1:  Rescale in [0,1], reshape, and convert to uint16
alpha = 1.0 / (zmax - zmin);
beta = -alpha * zmin;
z3 = reshape(alpha * z2 + beta, [nv,nu]);
z4 = im2uint16(z3);

% % % Option 2: Rescale to [0, 65535], reshape, and convert to uint16
% % alpha = 65535.0 / (zmax - zmin);
% % beta = -alpha * zmin;
% % z3 = reshape(alpha * z2 + beta, size(z'));
% % z4 = uint16(z3);

% Write PNG
%%class(z4)
imwrite(z4, filename, 'png', 'BitDepth', 16);

