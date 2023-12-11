clear
close all
config = jsonencode(fileread("../config.json"));

sample_freq = config.samplerate_hz;
max_freq = sample_freq/2;
total_samples = config.duration_sec*sample_freq;
N = total_samples*100;


% background noise psd
avg_noise = 100e-12; 
peak_value = 60000e-12; 


f = linspace(0,max_freq,N);
baseline = avg_noise * ones(N,1).';
powerline_peak = peak_value * exp(-1.*abs(f-60));
noise_psd = baseline + powerline_peak; % power in T/sqrt(Hz)

alphawave_psd = (12000*normpdf(f, 10, .2) + 25000*normpdf(f, 10,1)); % power in fT^2/Hz
alphawave_psd = sqrt(1e-15*1e-15*alphawave_psd); %Power in T/Hz^1/2


