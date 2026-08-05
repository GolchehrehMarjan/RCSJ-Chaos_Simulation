function dydt = RCSJ(t,y,Betha,Idc,Iac,Omega)
% phi'' + Betha*phi' + sin(phi) = Idc + Iac*cos(Omega*t)
    dydt = [ y(2);
            -Betha*y(2) - sin(y(1)) + Idc + Iac*cos(Omega*t) ];
end    



