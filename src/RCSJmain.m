clc; clear; close all;

%% ===== پارامترهای مشترک =====
Betha = 0.5;
Idc   = 0.740;
Iac   = 2.550;
Omega = 0.5;
T     = 2*pi/Omega;
y0    = [0;0];

opts_tight = odeset('RelTol',1e-10,'AbsTol',1e-12);
opts_loose = odeset('RelTol',1e-7 ,'AbsTol',1e-9);
opts_lyap=odeset('RelTol',1e-8,'AbsTol',1e-10);
%% ===== 1) فضای فاز =====
tspan = [0 2500];
[~,y] = ode45(@(t,y)RCSJ(t,y,Betha,Idc,Iac,Omega),tspan,y0,opts_tight);
N = size(y,1); steady = round(0.8*N):N;

figure;
subplot(2,1,1);
plot(y(steady,1),y(steady,2),'LineWidth',1.5);
xlabel('\phi'); ylabel('\phi dot'); title('Phase Portrait');

subplot(2,1,2);
plot(mod(y(steady,1),2*pi),y(steady,2),'LineWidth',1.5);
xlabel('\phi mod 2\pi'); ylabel('\phi dot');

%% ===== 2) منحنی I-V =====
Idc_sweep = 0:0.005:1.4;
Vavg = zeros(size(Idc_sweep));

for k = 1:length(Idc_sweep)
    [~,y] = ode45(@(t,y)RCSJ(t,y,Betha,Idc_sweep(k),Iac,Omega),tspan,y0,opts_loose);
    N = size(y,1);
    Vavg(k) = mean(y(round(0.95*N):end,2));
end

figure;
plot(Idc_sweep,Vavg,'LineWidth',2);
xlabel('I_{dc}'); ylabel('<V>'); grid on;
title('I-V Curve & Shapiro Steps');

%% ===== 3) مقطع پوانکاره =====
n  = 3000:10000;
tspan_p = [0 (n(end)+50)*T];

[t,y] = ode45(@(t,y)RCSJ(t,y,Betha,Idc,Iac,Omega),tspan_p,y0,opts_tight);
phi_p    = mod(interp1(t,y(:,1),n*T),2*pi);
phidot_p = interp1(t,y(:,2),n*T);

figure;
plot(phi_p,phidot_p,'.','MarkerSize',12);
xlim([2 6]); ylim([2 5]);
xlabel('\phi'); ylabel('\phi dot'); title('Poincare Section');

%% ===== 4) دیاگرام دوشاخگی =====
Idc_bif = 0.4:0.005:1.2;
n_bif   = 1500:1800;
tspan_bif = [0 (n_bif(end)+20)*T];

figure; hold on;
for k = 1:length(Idc_bif)
    [t,y] = ode45(@(t,y)RCSJ(t,y,Betha,Idc_bif(k),Iac,Omega),tspan_bif,y0,opts_loose);
    phidot_p = interp1(t,y(:,2),n_bif*T);
    plot(Idc_bif(k)*ones(size(phidot_p)),phidot_p,'.k','MarkerSize',5);
end
xlabel('I_{dc}'); ylabel('\phi dot'); title('Bifurcation Diagram');

%% ===== 5) بزرگ‌ترین توان لیاپانوف =====
Idc_range = 0.55:0.005:0.9;
lyap      = zeros(size(Idc_range));
n_periods = 500;
discard   = 100;
d0        = 1e-6;

for j = 1:length(Idc_range)
    lyap(j) = lyapunov_exponent(Betha,Idc_range(j),Iac,Omega,T,n_periods,discard,d0,opts_lyap);
    fprintf('Idc=%.3f   Lyap=%.5f\n',Idc_range(j),lyap(j));
end

figure;
plot(Idc_range,lyap,'LineWidth',2); hold on;
yline(0,'r--'); grid on;
xlabel('I_{dc}'); ylabel('\lambda_{max}'); title('Largest Lyapunov Exponent');

%% ===== بخش امتیازی: نقشه دوبعدی رژیم‌ها (Idc - Iac) =====
Idc_grid = 0.4:0.02:1.1;
Iac_grid = 1.2:0.05:2.6;

n_periods = 1500;
discard   = 400;
d0        = 1e-8;

lyap_map = zeros(length(Iac_grid),length(Idc_grid));

tic;
for ii = 1:length(Iac_grid)
    for jj = 1:length(Idc_grid)
        lyap_map(ii,jj) = lyapunov_exponent(Betha,Idc_grid(jj),Iac_grid(ii), ...
                                             Omega,T,n_periods,discard,d0,opts_lyap);
    end
    fprintf('Iac = %.2f done | elapsed = %.1f min\n',Iac_grid(ii),toc/60);
end

%% ===== Plot Lyapunov Regime Map =====
figure;
imagesc(Idc_grid,Iac_grid,lyap_map);
set(gca,'YDir','normal');
colorbar; colormap(turbo);
caxis([-0.02 0.02]);
xlabel('I_{dc}'); ylabel('I_{ac}'); title('Lyapunov Regime Map');

hold on;
contour(Idc_grid,Iac_grid,lyap_map,[0 0],'k','LineWidth',1.5);
hold off;

fprintf('\nMaximum Lyapunov = %.5f\n',max(lyap_map(:)));
fprintf('Minimum Lyapunov = %.5f\n',min(lyap_map(:)));

[~,idx] = max(lyap_map(:));
[row,col] = ind2sub(size(lyap_map),idx);
fprintf('Most chaotic point: Idc=%.3f, Iac=%.3f\n',Idc_grid(col),Iac_grid(row));