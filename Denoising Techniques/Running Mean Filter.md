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

#### **Step 1: Define Parameters and Create a Time Vector**

```matlab
% Define parameters
srate = 1000; % Sampling rate in Hz
time  = 0:1/srate:3; % Time vector from 0 to 3 seconds
n     = length(time); % Length of the time vector
```

1. **`srate = 1000;`**

   * This sets the **sampling rate** to **1000 Hz**. This means the signal is sampled 1000 times per second.
   * The sampling rate determines how often the data points (samples) are collected. A higher rate means more detailed information over time.

2. **`time  = 0:1/srate:3;`**

   * This creates a **time vector** named `time`.
   * The syntax `0:1/srate:3` means "start at 0, increase by `1/srate` (which is `1/1000` = 0.001 seconds), and stop at 3 seconds." This will create values like 0, 0.001, 0.002, ..., up to 3 seconds.
   * The `time` vector will have values that represent the time at each sampled data point.
   * The **sampling interval** is `1/srate` (i.e., 1 ms).

3. **`n     = length(time);`**

   * This finds the total **number of data points** (samples) in the `time` vector. The length of the `time` vector is calculated by `length(time)` and stored in `n`.
   * In our case, `n` will be the number of time points from 0 to 3 seconds with a step size of 0.001 seconds. For 3 seconds at 1000 samples per second, `n = 3001`.

---

#### **Step 2: Create a Noisy Signal**

```matlab
% Create a smooth signal (sinusoidal)
signal_clean = sin(2 * pi * 5 * time); % A 5 Hz sine wave

% Add noise to the signal (Gaussian noise)
noise = 0.5 * randn(size(time)); % Gaussian noise with standard deviation 0.5
signal_noisy = signal_clean + noise; % The noisy signal
```

1. **`signal_clean = sin(2 * pi * 5 * time);`**

   * This generates a **clean signal**, which is a simple **sine wave**. The equation `sin(2 * pi * 5 * time)` generates a sine wave at a frequency of 5 Hz.
   * `2 * pi * 5` defines the **angular frequency** (in radians per second), and `time` is the time vector that determines how the sine wave oscillates over time.
   * The sine wave will oscillate 5 times per second (since it's 5 Hz), and the amplitude of the wave will oscillate between -1 and 1.

2. **`noise = 0.5 * randn(size(time));`**

   * **`randn(size(time))`** generates random noise with a **normal distribution** (Gaussian noise) that has a mean of 0 and a standard deviation of 1.
   * **`0.5 * randn(size(time))`** scales the generated random noise to have a standard deviation of 0.5. This means the noise is not too extreme but still significant enough to distort the signal.

3. **`signal_noisy = signal_clean + noise;`**

   * This **adds the noise** to the clean sine wave, resulting in a noisy signal (`signal_noisy`).
   * The `signal_noisy` is now a combination of the clean sine wave and random Gaussian noise, which simulates a real-world noisy measurement.

---

#### **Step 3: Apply the Running Mean Filter**

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

1. **`k = 20;`**

   * The variable `k` determines the **half-width** of the window used for the running mean filter.
   * The window size will be `2k + 1`. In this case, `k = 20` means the window will cover **41 points** (20 before and 20 after each data point).
   * This will be used to compute the average of 41 neighboring points in the signal for each data point.

2. **`filtsig = zeros(size(signal_noisy));`**

   * This initializes a new array `filtsig` to store the **filtered signal**.
   * The size of `filtsig` is the same as `signal_noisy` since we are applying the filter to all points in the noisy signal.

3. **`for i = k+1:n-k-1`**

   * This loop iterates over each data point `i` in the noisy signal, except the first `k` and last `k` points. The reason for excluding the edges is that there are not enough surrounding points to average when you are at the beginning or end of the signal.
   * `i` will range from `k+1` to `n-k-1`, ensuring that only points in the middle are processed.

4. **`filtsig(i) = mean(signal_noisy(i-k:i+k));`**

   * This is where the **running mean** is applied.
   * For each point `i`, the function `mean(signal_noisy(i-k:i+k))` calculates the average of the `2k + 1 = 41` surrounding points, from `i-k` to `i+k`.
   * This average is then assigned to `filtsig(i)`, effectively replacing the noisy value at `i` with the average of its neighbors.

---

#### **Step 4: Plot the Original and Filtered Signals**

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

1. **`figure, hold on`**

   * This creates a new figure for plotting.
   * **`hold on`** ensures that multiple plot commands are drawn on the same graph without clearing the previous ones.

2. **`plot(time, signal_noisy, 'r', 'LineWidth', 1.5);`**

   * This plots the **noisy signal** (`signal_noisy`) using the red color (`'r'`) and sets the line width to 1.5. The `time` vector is used for the x-axis, and the noisy signal is plotted on the y-axis.

3. **`plot(time, filtsig, 'b', 'LineWidth', 2);`**

   * This plots the **filtered signal** (`filtsig`) using the blue color (`'b'`) and sets the line width to 2. This will overlay the filtered version of the noisy signal.

4. **`xlabel('Time (s)'); ylabel('Amplitude');`**

   * These commands label the x-axis and y-axis with appropriate descriptions: "Time (s)" for the x-axis and "Amplitude" for the y-axis.

5. **`title('Running Mean Filter: Noisy vs Filtered Signal');`**

   * This adds a **title** to the plot that describes the purpose of the plot.

6. **`legend({'Noisy Signal', 'Filtered Signal'});`**

   * This adds a **legend** to the plot that distinguishes between the noisy signal and the filtered signal.

7. **`grid on;`**

   * This enables the **grid** on the plot for better visibility of the data points.

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
