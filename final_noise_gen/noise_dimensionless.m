clear
close all

config = jsondecode(fileread("config.json"));

sample_freq = config.samplerate_hz;
max_freq = sample_freq/2;
total_samples = config.duration_sec*sample_freq;

N = total_samples*100;
avg_noise = 100e-12; 
peak_value = 60000e-12; 


f = linspace(0,max_freq,N);
baseline = avg_noise * ones(N,1).';
powerline_peak = peak_value * exp(-1.*abs(f-60));
p = baseline + powerline_peak;

hfir = fir2(N, f/max_freq, sqrt(p));

n_sources = 1e3;

% Generating an array of noise signals 
white_noise_signals =randn(N, n_sources);

sources = zeros(N, n_sources);

for i = 1:n_sources
    sources(:,i) = filter(hfir, 1, white_noise_signals(:,i));
end
%Grabbing end of filtered noise to compensate for FIR delay
sources = sources(end-total_samples:end, :);

writematrix(sources, "./final_noise_gen/sensor_background_noise.csv")





