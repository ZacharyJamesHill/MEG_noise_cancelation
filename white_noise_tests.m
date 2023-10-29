clear
close all

fs = 200;
x = randn(100000,1);

histogram(x)
title(sprintf("Variance = %d Mean = %d", round(var(x)), round(mean(x))))

[p, f] = pwelch(x, [], [], [], fs);

figure
subplot(2,1,1)
plot(f,p)
subplot(2,1,2)
plot(f,p*(fs/2))
mean(p*fs)