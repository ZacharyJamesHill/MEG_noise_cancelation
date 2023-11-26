clear
close all
config = jsondecode(fileread("config.json"));

sample_freq = config.samplerate_hz;
max_freq = sample_freq/2;
total_samples = config.duration_sec*sample_freq;

N = total_samples*10;

f = linspace(0,max_freq,N);

p = (12000*normpdf(f, 10, .2) + 25000*normpdf(f, 10,1)); % power in fT^2/Hz
p = sqrt(1e-15*1e-15*p); %Power in T/Hz^1/2
figure
plot(f, p)
hfir = fir2(N, f/max_freq, sqrt(p));

white_noise = randn(N, 1);

noise = filter(hfir, 1, white_noise);
%Taking end of generated noise to compensate for FIR filter delay
noise = noise(end-total_samples:end);

[noise_power, noise_freq] = pwelch(noise,[],[],[], sample_freq);

noise_power = noise_power*max_freq;
figure
plot(noise_freq, noise_power)

writematrix(noise, "alphawave.csv")
       



