% Running Mean Filter: Full Code Example
% This script generates a noisy sine wave signal and applies a running mean filter to smooth the signal.

% Step 1: Define parameters and create a time vector
srate = 1000; % Sampling rate in Hz
time  = 0:1/srate:3; % Time vector from 0 to 3 seconds
n     = length(time); % Length of the time vector

% Step 2: Create a smooth signal (sinusoidal) and add noise to it
signal_clean = sin(2 * pi * 5 * time); % A 5 Hz sine wave

% Add Gaussian noise to the signal
noise = 0.5 * randn(size(time)); % Gaussian noise with standard deviation 0.5
signal_noisy = signal_clean + noise; % The noisy signal

% Step 3: Apply the running mean filter
% Define the window size for the filter
k = 20; % This means the window size is 41 (2k + 1)

% Initialize an array for the filtered signal
filtsig = zeros(size(signal_noisy));

% Apply the running mean filter
for i = k+1:n-k-1
    filtsig(i) = mean(signal_noisy(i-k:i+k)); % Average of surrounding points
end

% Step 4: Plot the original and filtered signals
figure, hold on
plot(time, signal_noisy, 'r', 'LineWidth', 1.5); % Plot the noisy signal (in red)
plot(time, filtsig, 'b', 'LineWidth', 2); % Plot the filtered signal (in blue)

% Add labels and title
xlabel('Time (s)');
ylabel('Amplitude');
title('Running Mean Filter: Noisy vs Filtered Signal');
legend({'Noisy Signal', 'Filtered Signal'});
grid on;
