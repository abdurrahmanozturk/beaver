format long;
clear all;
hold on;
mu = 250;
sigma = 50;
K0 = 9.037e-13;
A = 0;
A_th=K0*(500-1)*exp(-((500-mu)^2)/(2*sigma^2))/(sigma*(2*pi)^0.5)
for i=1:501
    x(i)=i-1;
y(i) = K0 * exp(-((x(i) - mu) ^ 2) / (2 * sigma ^ 2)) / ((0.4 / sigma) * sigma * (2 * pi) ^ 0.5);
if
  i > 1 A = A + 0.5 * (y(i) + y(i - 1)) * (x(i) - x(i - 1));
end end yyaxis left plot(x, y) text(mu, K0, '\leftarrow A=' + string(A)) mu = 2500;
sigma = 500;
K0 = 9.037e-15;
A = 0;
A_th=K0*(5000-1)*exp(-((5000-mu)^2)/(2*sigma^2))/(sigma*(2*pi)^0.5)
for i=1:5001
    x(i)=(i-1);
y(i) = K0 * exp(-((x(i) - mu) ^ 2) / (2 * sigma ^ 2)) / ((0.4 / sigma) * sigma * (2 * pi) ^ 0.5);
if
  i > 1 A = A + 0.5 * (y(i) + y(i - 1)) * (x(i) - x(i - 1));
end end yyaxis right plot(x, y) text(mu, K0, '\leftarrow A=' + string(A)) xlabel('x')
    ylabel('K0') grid on;