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

alpha_wave_n = 10000* readmatrix("./final_noise_gen/alphawave.csv");
noise_mat = readmatrix("sensor_background_noise.csv");
dirty_signal = alpha_wave_n + noise_mat(:,1);

filtersize = 100;

P = alpha_wave_n.^2;
[H,R] = corrmtx(dirty_signal.',2000);

h = R^(-1)*P;
clean_signal = conv(h,dirty_signal);

figure
plot(0:2000, alpha_wave_n)
figure
plot(0:4000, clean_signal)
