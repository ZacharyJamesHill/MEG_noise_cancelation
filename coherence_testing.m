clear
close all
max_freq = 100;
sample_freq = 2*max_freq; 

x = randn(8000, 1);
y = randn(8000, 1);

noise_magnitudes = linspace(0,1,100);
coherences = [];
for i = noise_magnitudes
    
    [coherence_xy, f] = mscohere(x,x*(1-i)+i*y, [], [],[], sample_freq);
    coherences = [coherences mean(coherence_xy)];
end
% figure
% plot(noise_magnitudes, coherences)


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


white_noise = randn(N*8, 1);
noise_1 = filter(hfir, 1, white_noise);

white_noise = randn(N*8, 1);
noise_2 = filter(hfir, 1, white_noise);

%  Checking out coherence
% noise_magnitudes = linspace(0,1,100);
% coherences = [];
% for i = noise_magnitudes
% 
%     [coherence_xy, f] = mscohere(noise_1,noise_1*(1-i)+i*(noise_2), [], [],[], sample_freq);
%     coherences = [coherences mean(coherence_xy)];
% end
% figure
% plot(noise_magnitudes, coherences)


% Generating an array of noise signals 
white_noise_signals =randn(N*8, 300);

n_sources = 300;

for i = 1:n_sources
    sources(:,i) = filter(hfir, 1, white_noise_signals(:,i));
end

% creating points on circle for sources
phases = linspace(0,2*pi,n_sources);
r = 1.985; % distance from origin in meters
x_coords = r*cos(phases);
y_coords = r*sin(phases);

% Testing example mixed signal
[signal] = gen_signal(.01,.2, sources, x_coords, y_coords);

figure
[noise_power, noise_freq] = pwelch(sources(:,1),[],[],[], sample_freq);

noise_power = noise_power*max_freq;

plot(noise_freq, noise_power)
title("PSD of example Noise")
xlabel("Freq [Hz]")
ylabel("T/Hz^{1/2}")

figure
[noise_power, noise_freq] = pwelch(signal,[],[],[], sample_freq);

noise_power = noise_power*max_freq;

plot(noise_freq, noise_power)
title("PSD of Mixed Noise")
xlabel("Freq [Hz]")
ylabel("T/Hz^{1/2}")


% creating grid of points to test pairwise coherence distance relationship
num_points = 5;
x = linspace(-sqrt(1/8),sqrt(1/8),num_points);
y = linspace(-sqrt(1/8),sqrt(1/8),num_points);




[A,B] = meshgrid(x,y);
c=cat(2,A',B');
xy=reshape(c,[],2);


figure
hold on
scatter(xy(:,1), xy(:,2), ".")
scatter(x_coords, y_coords, ".")
xlim([-2.5,2.5])
ylim([-2.5,2.5])

pbaspect([1 1 1])
title("Test Sensor Grid and Sources")
xlabel("x [m]")
ylabel("y [m]")
legend("Sensors", "Sources")
saveas(gcf,'Coherence_test_sensor_grid.png')
hold off

signals = [];

for i = 1:length(xy)
    signals(:,i) = gen_signal(xy(i,1), xy(i,2), sources, x_coords, y_coords);
end


pairs = [];

distances = [];
coherences = [];
% Looping through all pairs of points calulating distances and coherences
for i= 1:length(xy)-1

    for k = i+1:length(xy)
        

        distance = sqrt((xy(i,1)- xy(k,1)).^2 + (xy(i,2)- xy(k,2)).^2);
        distances = [distances distance];

        [coherence_xy, f] = mscohere(signals(:,i),signals(:,k), [], [],[], sample_freq);
        coherences = [coherences mean(coherence_xy)];
        
        pair = [xy(i,:) xy(k,:)];
        pairs = vertcat(pairs, pair);
    end

end

% Plotting coherence dropoff with distance to verify
figure
hold on
scatter(distances, coherences, ".")
load("coherence_coefs.mat")
x = linspace(0,1,100);
plot(x, polyval(coefs,x))
hold off
ylim([-inf, 1])
title("Coherence vs Distance between sensors")
xlabel("Distance [m]")
ylabel("Coherence")
legend("Simulated Coherence Dropoff", "Experimental Coherence Dropoff");
saveas(gcf,'Coherence_test.png')


% Generates a signal by mixing from a circle of signals acoording to
% distance to each signal from the input xy coordinate
function [signal] = gen_signal(x,y, sources, x_coords, y_coords)
     
    distances = sqrt((x- x_coords).^2 + (y-y_coords).^2);
    
    mixing_weights = distances / sum(distances);
    
    signal = sqrt(length(mixing_weights)) * sum(sources.*mixing_weights, 2); %fudge factor involved
    
end




