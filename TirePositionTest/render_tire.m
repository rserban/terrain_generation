addpath(genpath('../WOBJ_toolbox/'));

data_point = '45_0';
wheel = 3;

% -------------------------------------------------------------------------

soil_file = sprintf('soil_%s_w%d.csv', data_point, wheel);
vehicle_file = sprintf('vehicle_%s.csv', data_point);

s = csvread(soil_file);
v = csvread(vehicle_file);

wp = v(3+wheel,1:3);  % FL wheel position
wr = v(3+wheel,4:7);  % FL wheel orientation
wA = quat2rotm(wr);

OBJ = read_wobj('Polaris_tire_collision.obj');
FV.vertices=OBJ.vertices;
FV.faces=OBJ.objects(5).data.vertices;

figure
patch(FV,'facecolor',[1 0 0]);
camlight
view(30,20)
axis equal

v_mod = repmat(wp', 1, size(FV.vertices,1)) + wA * FV.vertices';
FV.vertices = v_mod';

figure
subplot(1,2,1)
hold on
%%patch(FV,'facecolor',[1 0 0], 'facealpha', 'flat', 'FaceVertexAlphaData', 0.8)
patch(FV,'facecolor',[0.6 0.6 0.6])
plot3(s(:,1), s(:,2), s(:,3), 'g.')
camlight
view(30,20)
axis equal

subplot(1,2,2)
hold on
%%patch(FV,'facecolor',[1 0 0], 'facealpha', 'flat', 'FaceVertexAlphaData', 0.8)
patch(FV,'facecolor',[0.6 0.6 0.6])
plot3(s(:,1), s(:,2), s(:,3), 'g.')
camlight
view(30,20)
axis equal
yy = ylim;
ylim([wp(2) yy(2)])

