function info = crg_info(crg)
% crg_info - display and return information about the CRG road
%    info = crg_info(crg)
% where info is a structure with the following fields:
% length, width, resolution, zmin, zmax, rms.

% -------------------------------------------------------------------------
% Radu Serban
% -------------------------------------------------------------------------

if length(crg.u) == 1
    len = crg.u;
else
    len = crg.u(2) - crg.u(1);
end

if length(crg.v) == 1
    width = 2 * crg.v;
    v = [-crg.v crg.v];
else
    width = crg.v(end) - crg.v(1);
    v = crg.v;
end

z = crg.z;
nu = size(z, 1);
du = len / (nu-1);
u = (0:du:len);

[x,y] = meshgrid(double(u), double(v));
z2 = crg_eval_uv2z(crg, [x(:) y(:)]);
zmin = min(z2);
zmax = max(z2);

info.length = len;
info.width = width;
info.resolution = du;
info.zmin = zmin;
info.zmax = zmax;
info.rms = rms(z);

disp(['Road length: ', num2str(len), ' m'])
disp(['Road width:  ', num2str(width), ' m'])
disp(['Resolution:  ', num2str(du), ' m'])
disp(['Min z:       ', num2str(zmin), ' m'])
disp(['Max z:       ', num2str(zmax), ' m'])
disp(['Mean RMS:    ', num2str(mean(rms(z))), ' m'])

