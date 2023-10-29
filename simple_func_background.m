clear
close all
N = 1e4;

max_freq = 100;
sample_freq = 2*max_freq;

f = linspace(0,max_freq,N);
p = heaviside(-1*f+10);

hfir = fir2(N, f/max_freq, sqrt(p));
[mag_h, h_freq] = freqz(hfir, 1, N*2, sample_freq);


figure
subplot(2,1,1)
plot(f,p)
subplot(2,1,2)
plot(h_freq, abs(mag_h).*abs(mag_h))


white_noise = randn(N*8, 1);

noise = filter(hfir, 1, white_noise);
% % noise = noise(N/2:end);

figure
subplot(2,1,1)
plot(white_noise)
subplot(2,1,2)
plot(noise)

[noise_power, noise_freq] = pwelch(noise,[],[],[], sample_freq);

noise_power = noise_power*max_freq;
       

figure
subplot(3,1,1)
plot(f,p)
subplot(3,1,2)
plot(noise_freq, noise_power)
% subplot(3,1,3)
% plot(f, p.'-noise_power(1:1000))


