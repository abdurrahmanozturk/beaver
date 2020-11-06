format long;
clear all;
hold on;
mu = 2500;
sigma = 500;
K0 = 9.037e-13;
A = 0;
A_th = K0 * (500 - 1) * exp(-((500 - mu) ^ 2) / (2 * sigma ^ 2)) / (sigma * (2 * pi) ^ 0.5);
for
  i = 1 : 5001 x(i) = i - 1;
y(i) = K0 * exp(-((x(i) - mu + sigma) ^ 2) / (2 * sigma ^ 2)) /
       ((0.4 / sigma) * sigma * (2 * pi) ^ 0.5);
if
  i > mu y2(i) = 0;
else
  y2(i) = 0.25 * K0 * (1 - (x(i) / mu) ^ 2);
end y3(i) = y(i) + y2(i);
% if i < mu % xx = 1.2 * mu - x(i);
% y(i) = y(i) + K0 * exp(-((xx - mu) ^ 2) / (2 * sigma ^ 2)) /
                    ((0.4 / sigma) * sigma * (2 * pi) ^ 0.5);
% end if i > 1 A = A + 0.5 * (y(i) + y(i - 1)) * (x(i) - x(i - 1));
end

        end %
    yyaxis left % plot(x, y) %
    plot(x, y2) plot(x, y3) text(mu, K0, '\leftarrow A=' + string(A)) xlabel('x')
        ylabel('K0') grid on;