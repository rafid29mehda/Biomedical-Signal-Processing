### **Running Mean Filter:**

#### **What is a Running Mean Filter?**

A **Running Mean Filter**, also known as a **Moving Average Filter**, is a simple and commonly used signal processing technique to smooth a noisy signal. The primary goal of this filter is to reduce the effects of high-frequency noise or fluctuations in the signal. It works by taking the average of a set number of neighboring points in the signal and replacing the value of each point with this average.

#### **Characteristics of the Running Mean Filter:**

* **Local Averaging**: The running mean filter computes the average of a set of surrounding data points (a "window"). This averaging reduces random variations in the data, effectively smoothing out the signal.
* **Window Size**: The size of the window (number of points considered in the averaging) is a key parameter. A smaller window smooths less but retains more detail, while a larger window smooths more but may lose finer features of the signal.
* **Simple Implementation**: It is one of the simplest forms of smoothing filters, requiring minimal computation.
* **Linear Filter**: The filter is linear because each output value is a weighted sum of the input values (with equal weights for each point in the window).
* **Edge Effects**: At the edges of the signal (near the start and end), the filter has fewer points to average, which can result in inaccuracies or artifacts. These edge effects can sometimes be handled by padding the signal.

#### **Why and When is it Used?**

* **Noise Reduction**: It is commonly used to reduce high-frequency noise (random variations) in time series data, making the signal clearer.
* **Signal Smoothing**: It is used when the signal contains rapid fluctuations that are not of interest and need to be filtered out for analysis or visualization purposes.
* **Real-Time Processing**: This filter can be implemented in real-time systems to smooth incoming data without requiring complex computations.

#### **How Does It Work?**

The running mean filter works by computing the average of the surrounding data points within a defined window. For a signal `x` and a window size `k`, the value of the signal at point `i` is replaced by the average of the `k` preceding and `k` following points in the signal, as shown:

$$
\text{filtered}(i) = \frac{1}{2k+1} \sum_{j=i-k}^{i+k} x(j)
$$

Where:

* $i$ is the index of the point being filtered.
* $k$ is the half-width of the window (window size is $2k+1$).
* $x(j)$ is the value of the signal at point $j$.

The filter moves through the entire signal, applying this average calculation to each point in the signal, except at the boundaries where fewer points may be available.

![image](https://github.com/user-attachments/assets/d7d9bf93-4fe7-497a-82a1-89f1ff03e643)


---

### **End-to-End Example:**

Let’s walk through an end-to-end example of using a **Running Mean Filter** to denoise a synthetic signal. We will:

1. Generate a noisy signal.
2. Apply the running mean filter.
3. Plot the original and filtered signals.
4. Interpret the results.

---

#### **Step 1: Create a Noisy Signal**

In this step, we generate a signal with random noise added to it.

```matlab
% Define parameters
srate = 1000; % Sampling rate in Hz
time  = 0:1/srate:3; % Time vector from 0 to 3 seconds
n     = length(time); % Length of the time vector

% Create a smooth signal (sinusoidal)
signal_clean = sin(2 * pi * 5 * time); % A 5 Hz sine wave

% Add noise to the signal (Gaussian noise)
noise = 0.5 * randn(size(time)); % Gaussian noise with standard deviation 0.5
signal_noisy = signal_clean + noise; % The noisy signal
```

Here, we create a sinusoidal signal (`signal_clean`) at a frequency of 5 Hz, and then add Gaussian noise to it, resulting in a noisy signal (`signal_noisy`).

#### **Step 2: Apply the Running Mean Filter**

Now, let’s apply the running mean filter to the noisy signal.

```matlab
% Define the window size for the filter
k = 20; % This means the window size is 41 (2k + 1)

% Initialize an array for the filtered signal
filtsig = zeros(size(signal_noisy));

% Apply the running mean filter
for i = k+1:n-k-1
    filtsig(i) = mean(signal_noisy(i-k:i+k)); % Average of surrounding points
end
```

In this code:

* `k = 20` means the filter window includes 41 points (20 before and 20 after the current point).
* We apply the filter to each point by averaging the surrounding points, as described in the formula above.

#### **Step 3: Visualize the Results**

Next, let’s plot the original noisy signal and the filtered signal to compare how well the filter has smoothed the data.

```matlab
% Plot the original and filtered signals
figure, hold on
plot(time, signal_noisy, 'r', 'LineWidth', 1.5); % Plot the noisy signal (in red)
plot(time, filtsig, 'b', 'LineWidth', 2); % Plot the filtered signal (in blue)

% Add labels and title
xlabel('Time (s)');
ylabel('Amplitude');
title('Running Mean Filter: Noisy vs Filtered Signal');
legend({'Noisy Signal', 'Filtered Signal'});
grid on;
```

In this plot:

* The **red line** represents the noisy signal (`signal_noisy`).
* The **blue line** represents the filtered signal (`filtsig`).

#### **Step 4: Interpretation**

When you run the code and view the plot:

* **Noisy Signal**: The red line will show a noisy signal with high-frequency fluctuations (random variations).
* **Filtered Signal**: The blue line will show the signal after applying the running mean filter. The filter smooths the high-frequency noise, retaining the low-frequency structure (such as the sinusoidal waveform) of the original signal.

The running mean filter has successfully reduced the noise by averaging neighboring points, which smooths out the rapid variations, making the signal easier to analyze.

---

### **Conclusion**

In this end-to-end example:

* We created a noisy signal by adding Gaussian noise to a clean sinusoidal signal.
* We applied the **Running Mean Filter** with a window size of 41 (i.e., `k = 20`).
* The result was plotted to visually compare the noisy signal and the filtered signal, showing the effectiveness of the filter in removing noise.

---

### **Key Takeaways:**

* **Running Mean Filter** is effective at removing high-frequency noise in signals by averaging surrounding data points.
* The filter’s **window size** (defined by `k`) controls the level of smoothing.
* While this is a simple technique, it is often used as a first step in signal preprocessing for more complex analysis, such as feature extraction or machine learning.

This is a common approach in real-world applications where noisy data must be cleaned before further analysis, such as in audio processing, sensor data smoothing, or even time-series forecasting.
