function h = sinStep(x,x1,h1,x2,h2)
%sinStep - sinusoidal approximation to step function

if x <= x1
    h = h1;
else
    if x >= x2
        h = h2;
    else
        dh = h2-h1;
        dx = x2-x1;
        h = h1+dh/dx*(x-x1)-(dh/2/pi)*sin(2*pi/dx*(x-x1));
    end
end