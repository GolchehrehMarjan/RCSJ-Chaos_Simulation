function lyap = lyapunov_exponent(Betha,Idc,Iac,Omega,T,n_periods,discard,d0,opts)
    y = [0;0;d0;0];
    sum_log = 0;

    for k = 1:n_periods
        [~,Y] = ode45(@(t,y)RCSJ_variational(t,y,Betha,Idc,Iac,Omega), ...
                       [(k-1)*T k*T],y,opts);
        y = Y(end,:)';
        d = norm(y(3:4));

        if k > discard
            sum_log = sum_log + log(d/d0);
        end
        y(3:4) = y(3:4)/d*d0;
    end

    lyap = sum_log/((n_periods-discard)*T);
end