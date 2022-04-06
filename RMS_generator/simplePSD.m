function [crg] = simplePSD(len, width, RMS, varargin)
% simplePSD - create CRG description for an RMS lane using PSD
%    crg = simplePSD(length, width, RMS)
% where the road length and width, as well as the desired residual mean
% square (RMS) are provided in meters.  The function returns an OpenCRG
% structure (see crg_intro).
% Optional arguments:
%    'resolution'      - spatial resolution [m] (default: 0.1)
%    'slope'           - lane slope [rad] (default: 0)
%    'wavelengthRange' - min/max PSD wavelength [m] (default: [0.3 10])
%    'w'               - PSD angular frequency (???) (default: 2)
%    'phi0'            - PSD ??? (default: 1e-5)
%    'numSamples'      - number of Fourier coefficients (default: 200)
%    'correlation'     - left/right road side correlation (default: 0)
%                        (0: uncorrelated, 1: identical)
%
% Based on listing 2.2 from
%    G. Rill "Road Vehicle Dynamics: Fundamentals and Modeling",
%            ISBN 978-1-4398-9744-7 www.crcpress.com
%
% See also CRG_WRITE, CRG_READ, CRG_SHOW

% -------------------------------------------------------------------------
% Rainer Gerike, Radu Serban
% -------------------------------------------------------------------------

% Parse inputs
p = inputParser;

addRequired(p,'length',@isnumeric);
addRequired(p,'width',@isnumeric);
addRequired(p,'RMS',@isnumeric);

checkRange = @(x) isnumeric(x) & length(x)==2 & x(2)>x(1);
%checkRange = @(x) isnumeric(x) & x(2)>x(1);
checkCorrelation = @(x) isnumeric(x) & x>=0 & x<=1;

addOptional(p, 'resolution', 0.1, @isnumeric);
addOptional(p, 'slope', 0.0, @isnumeric);
addOptional(p, 'wavelengthRange', [0.3 10.0], checkRange);
addOptional(p, 'w', 2.0, @isnumeric);
addOptional(p, 'phi0', 1e-5, @isnumeric);
addOptional(p, 'correlation', 0.0, checkCorrelation);
addOptional(p, 'numSamples', 200, @isnumeric);

parse(p,len,width,RMS,varargin{:});
disp('Parameters:');
disp(p.Results)
if ~isempty(p.UsingDefaults)
   disp('Using defaults for: ')
   disp(p.UsingDefaults)
end

% Extract parameters
du = p.Results.resolution;
slope = p.Results.slope;
Lrange = p.Results.wavelengthRange;
Lmin = Lrange(1);
Lmax = Lrange(2);
w = p.Results.w;
Phi0 = p.Results.phi0;
nsamp = p.Results.numSamples;
c = p.Results.correlation;

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

% the Fourier coefficients lack phase angles,
% we invent some by generating equally distributed random numbers
Psi1 = 2*pi*rand(size(Om)); % left half
% we want a second set for the other road half
Psit = 2*pi*rand(size(Om)); 
% both road side excitations will be statistically independent
% the correlation between left and right is about zero
% making Psi1 and Psi2 identical means correlation = one
% naive model to consider correlation
Psi2 = Psi1 * c + Psit * (1-c); % possible correlated right coeffs

%
x = 0:du:len;
z1 = zeros(size(x));
z2 = zeros(size(x));
n = length(x);
for i=1:n
    z1(i) = sinStep(x(i),0,0,1,1)*sum( Amp.*sin(Om*x(i)+Psi1) );
    z2(i) = sinStep(x(i),0,0,1,1)*sum( Amp.*sin(Om*x(i)+Psi2) );
end
r1 = rms(z1);
r2 = rms(z2);
z1 = z1 * RMS/r1;
z2 = z2 * RMS/r2;
rmsFinal = (rms(z1) + rms(z2))/2;
 
% Create CRG data structure
uinc = du;
nu = length(x);
nv = 4;
data.u = (nu-1)*uinc;
data.v = [-width/2 -0.05 0.05 width/2];
data.p = 0;
data.s = slope;
data.z = zeros(nu,nv);
data.z(1:end,1) = z1';
data.z(1:end,2) = z1';
data.z(1:end,3) = z2';
data.z(1:end,4) = z2';
% we leave a comment
data.ct{1} = 'Random Road';
data.ct{2} = ['Length = ', num2str(data.u), ' m'];
data.ct{3} = ['Width = ', num2str(width), ' m'];
data.ct{4} = ['RMS = ', num2str(rmsFinal), ' m'];
data.ct{5} = ['Simple Correlation = ', num2str(c), 'left/right'];

crg = crg_check(crg_single(data));
