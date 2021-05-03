function [] = crg_info(crg)
% crg_info - display information about the CRG road
%    crg_info(crg)

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

disp(['Road length: ', num2str(len)])
disp(['Road width:  ', num2str(width)])
disp(['Resolution:  ', num2str(du)])
disp(['Min z:       ', num2str(zmin)])
disp(['Max z:       ', num2str(zmax)])
disp(['RMS:         ', num2str(mean(rms(z)))])

