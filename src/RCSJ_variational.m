function dydt = RCSJ_variational(t,y,Betha,Idc,Iac,Omega)
% y = [phi; phidot; delta_phi; delta_phidot]
    phi      = y(1);
    phidot   = y(2);
    dphi     = y(3);
    dphidot  = y(4);

    dydt = [ phidot;
            -Betha*phidot - sin(phi) + Idc + Iac*cos(Omega*t);
             dphidot;
            -Betha*dphidot - cos(phi)*dphi ];
end