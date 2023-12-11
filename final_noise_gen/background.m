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

n_sources = 300;

% Generating an array of noise signals 
white_noise_signals =randn(N, n_sources);


for i = 1:n_sources
    sources(:,i) = filter(hfir, 1, white_noise_signals(:,i));
end
%Grabbing end of filtered noise to compensate for FIR delay
sources = sources(end-total_samples:end, :);
% creating points on circle for sources redefinition is to prevent double
% source at 0/2pi
phases = linspace(0,2*pi,n_sources+1); 
phases = phases(1:end-1); 
r = 1.985; % distance from origin in meters
x_coords = r*cos(phases);
y_coords = r*sin(phases);



% Creating signals at sensors



signals = [];
sensor_xpos = config.sensor_xpos;
sensor_ypos = config.sensor_ypos;


for i = 1:length(sensor_xpos)
    signals(:,i) = gen_signal(sensor_xpos(i), sensor_ypos(i), sources, x_coords, y_coords);
end

writematrix(signals, "sensor_background_noise.csv")


[noise_power, noise_freq] = pwelch(signals(:,1),[],[],[], sample_freq);

noise_power = noise_power*max_freq;
figure
plot(noise_freq, noise_power)
title("PSD of Filtered Noise")
xlabel("Freq [Hz]")
ylabel("T/Hz^{1/2}")

% Generates a signal by mixing from a circle of signals acoording to
% distance to each signal from the input xy coordinate
function [signal] = gen_signal(x,y, sources, x_coords, y_coords)
     
    distances = sqrt((x- x_coords).^2 + (y-y_coords).^2);
    
    mixing_weights = distances / sum(distances);
    
    signal = sqrt(length(mixing_weights)) * sum(sources.*mixing_weights, 2); %fudge factor involved
    
end




