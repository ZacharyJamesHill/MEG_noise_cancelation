clear                             %Clears matlab
close all                         %Closes all matlab figure windows
N = 1e4;                          %Number of entries in arrays
avg_noise = 100e-12;              %T/Hz^1/2
peak_value = 60000e-12;           %T/Hz^1/2

max_freq = 100;                   %Hz
sample_freq = 2*max_freq;         %Hz

f = linspace(0,max_freq,N);       %Hz
baseline = avg_noise * ones(1,N); %T/Hz^1/2
powerline_peak = peak_value * exp(-1*abs(f-60)); %T/Hz^1/2
p = baseline + powerline_peak;    %T/Hz^1/2

hfir = fir2(5e2, f/max_freq, sqrt(p));  %Generates fir filter coefficients
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


