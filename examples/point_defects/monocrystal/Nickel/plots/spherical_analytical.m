format long;
clear all;
hold on;
Cs = 1e18;
Di = 1.1066108307323346e-09;
Dv = 2.0050685348844685e-13;
k0 = 1e-6;
kis = 4.8949408023459335e-17;
kvs = 8.869144879425032e-21;
a = 500;
ki=(kis*Cs/Di)^0.5
kv=(kvs*Cs/Dv)^0.5

for i=1:501
    x(i)=i-1;
ci(i) = (k0 / (Di * ki * ki)) * (1 - a * sinh(ki * x(i)) / (x(i) * sinh(ki * a)));
cv(i) = (k0 / (Dv * kv * kv)) * (1 - a * sinh(kv * x(i)) / (x(i) * sinh(kv * a)));
end

    % yyaxis left plot(x, ci) plot(x, cv) xlabel('x') ylabel('Defect Concentration') grid on;