clear
close all
config = jsondecode(fileread("./final_noise_gen/config.json"));

sample_freq = config.samplerate_hz;
max_freq = sample_freq/2;
total_samples = config.duration_sec*sample_freq;
N = total_samples*100;


% background noise psd
avg_noise = 100e-12; 
peak_value = 60000e-12; 

f_n_domain = linspace(0,max_freq,N);
f = linspace(0,max_freq,257);
baseline = avg_noise * ones(257,1).';
powerline_peak = peak_value * exp(-1.*abs(f-60));
noise_psd = baseline + powerline_peak; % power in T/sqrt(Hz)

alphawave_psd = (12000*normpdf(f, 10, .2) + 25000*normpdf(f, 10,1)); % power in fT^2/Hz
alphawave_psd = 1e4*sqrt(1e-15*1e-15*alphawave_psd); %Power in T/Hz^1/2

v = 1; %Noise function in the z domain.

noise_mat = readmatrix("sensor_background_noise.csv");
alpha_wave_n = 1e4* readmatrix("./final_noise_gen/alphawave.csv");

dirty_signal = alpha_wave_n +...
    noise_mat(:,1);
[dirty_signal_z, dirty_signal_f] = pwelch(dirty_signal,[],[],[], sample_freq);

plot(dirty_signal_f,dirty_signal_z)

vviner_filter_z = alphawave_psd.'./dirty_signal_z;


hfir = fir2(256, f/max_freq, sqrt(vviner_filter_z));

clean_signal = filter(hfir, 1, dirty_signal);

[clean_signal_z, clean_signal_f] = pwelch(clean_signal,[],[],[], sample_freq);

plot(clean_signal_f,clean_signal_z);

plot([0:2000],clean_signal, [257:2257],alpha_wave_n)


