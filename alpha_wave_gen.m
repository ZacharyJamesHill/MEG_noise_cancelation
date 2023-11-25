clear
N = 1e4;
max_freq = 100;
sample_freq = 100*max_freq; %Sampling at 10 kHz to get 10k samples in 1s

f = linspace(0,max_freq,N);

p = sqrt(12000*normpdf(f, 10, .2) + 25000*normpdf(f, 10,1));

hfir = fir2(N, f/max_freq, sqrt(p));
[mag_h, h_freq] = freqz(hfir, 1, N, sample_freq);

white_noise = randn(N*100, 1);

% figure
[noise_power, noise_freq] = pwelch(white_noise,[],[],[], sample_freq);
% plot(noise_freq, noise_power)

noise = filter(hfir, 1, white_noise);


[noise_power, noise_freq] = pwelch(noise,[],[],[], 2*max_freq);

noise_power = noise_power*max_freq;

plot(noise_freq, noise_power)
title("PSD of Generated Alpha Rhythm signal")
xlabel("Freq [Hz]")
ylabel("fT^2/Hz")


writematrix(noise, "alphawave_fs_10khz.csv")
       



