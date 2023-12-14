clear
close all

N = 300;


alpha_wave_n = 1000000 * readmatrix("./final_noise_gen/alphawave.csv");
noise_mat = readmatrix("sensor_background_noise.csv");

duration = size(noise_mat,1);
sensor_n = size(noise_mat,2);

dirty_signals = repmat(alpha_wave_n,1,sensor_n) + noise_mat;

autocorrelations = zeros(N,N,(duration-N+1)*sensor_n);
weighted_values = zeros(N,(duration-N+1)*sensor_n);

for i = 1:duration-N+1
    for j = 1:sensor_n
        autocorrelations(:,:,i+(j-1)*sensor_n) = dirty_signals(i:i+N-1,j)*dirty_signals(i:i+N-1,j).';
        weighted_values(:,i+(j-1)*sensor_n) = dirty_signals(i:i+N-1,j).*alpha_wave_n(i:i+N-1);
    end
end

R = mean(autocorrelations,3);
P = mean(weighted_values,2);

H = R^(-1)*P;
y = conv(H,dirty_signals(:,1));

figure

