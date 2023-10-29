clear
close all
N = 1e3;
avg_noise = 100e-12;
peak_value = 60000e-12; 

max_freq = 100;
sample_freq = 2*max_freq;

f = linspace(0,max_freq,N);
baseline = avg_noise * ones(N,1).';
powerline_peak = peak_value * exp(-1.*abs(f-60));
p = baseline + powerline_peak;

hfir = fir2(N, f/max_freq, sqrt(p));
[mag_h, h_freq] = freqz(hfir, 1, N, sample_freq);


% figure
% subplot(2,1,1)
% plot(f,p)
% subplot(2,1,2)
% plot(h_freq, abs(mag_h).*abs(mag_h))


white_noise = randn(N*8, 1);

% figure
[noise_power, noise_freq] = pwelch(white_noise,[],[],[], sample_freq);
% plot(noise_freq, noise_power)

noise = filter(hfir, 1, white_noise);

figure
subplot(2,1,1)
plot(white_noise)
title("Input White Noise")
subplot(2,1,2)
plot(noise)
title("Output Filtered Noise")

[noise_power, noise_freq] = pwelch(noise,[],[],[], sample_freq);

noise_power = noise_power*max_freq;
       

figure
subplot(2,1,1)
plot(f,p)
title("Specified PSD")
xlabel("Freq [Hz]")
ylabel("T/Hz^{1/2}")
subplot(2,1,2)
plot(noise_freq, noise_power)
title("PSD of Filtered Noise")
xlabel("Freq [Hz]")
ylabel("T/Hz^{1/2}")


