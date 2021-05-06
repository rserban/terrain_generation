function [crg] = simplePSD_multi(lane_length, lane_width, slope, RMS, du)
% simplePSD_multi - create CRG description for multiple adjacent RMS lanes,
%                   each of the given width, using PSD (size of RMS array)
%    crg = simplePSD_multi(lane_length, lane_width, slope, RMS, du)
% where the lane length and width, as well as the desired residual mean
% square (RMS) values are provided in meters.  The function returns an
% OpenCRG structure (see crg_intro).
%
% Based on listing 2.2 from
%    G. Rill "Road Vehicle Dynamics: Fundamentals and Modeling",
%            ISBN 978-1-4398-9744-7 www.crcpress.com
%
% See also CRG_WRITE, CRG_READ, CRG_SHOW
% --------------------------------------------------------------
% Rainer Gerike, Radu Serban
%

% Extract parameters
Lmin = 0.3;
Lmax = 10;
w = 2;
Phi0 = 1e-5;
nsamp = 200;

if du > Lmin/2
    disp('Resolution is too large!')
    disp('Must be less than half the smallest wavelength.')
    return
end

% maximum wave number
Omax = 2*pi/Lmin;
% minimum wave number
Omin = 2*pi/Lmax;
% vector of wave numbers
dOm = (Omax-Omin)/(nsamp-1);
Om = Omin:dOm:Omax;
% typical constant
Om0 = 1;

% PSD values of Omega
Phi = Phi0.*(Om./Om0).^(-w);

% Magnitude of the resulting Fourier coefficients
Amp = sqrt(2*Phi*dOm);

x = 0:du:lane_length;
nu = length(x);
nlanes = length(RMS);
nv = 2 * nlanes;
v = zeros(1, nv);
z = zeros(nu, nv);

sep = 0.1;

for i = 1:nlanes
    Psi = 2*pi*rand(size(Om));
    
    z1 = zeros(nu, 1);
    for j=1:nu
        z1(j) = sinStep(x(j),0,0,1,1)*sum( Amp.*sin(Om*x(j)+Psi) );
    end
    r1 = rms(z1);
    z1 = z1 * RMS(i)/r1;
    
    z(:, 2*i - 1) = z1;
    z(:, 2*i) = z1;
   
    v(2*i - 1) = (i-1)*lane_width + sep / 2;
    v(2*i) = i * lane_width - sep / 2;
end

% Create CRG data structure
data.u = (nu-1)*du;
data.v = [0 v nlanes*lane_width];
data.p = 0;
data.s = slope;
data.z = [z(:,1) z z(:,end)];

% Leave a comment
data.ct{1} = 'Random Road';
data.ct{2} = ['Length = ', num2str(data.u), ' m'];
data.ct{3} = ['Width = ', num2str(lane_width), ' m'];
data.ct{4} = ['RMS = ', num2str(RMS), ' m'];

crg = crg_check(crg_single(data));
