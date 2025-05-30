### **Gaussian-Smooth Time Series Filter: Documentation**

#### **What is a Gaussian-Smooth Time Series Filter?**

A **Gaussian-smooth filter** (or **Gaussian filter**) is a type of **low-pass filter** that smooths or "blurs" a time series signal. It works by weighing the neighboring points of each sample based on a Gaussian distribution, which has the shape of a bell curve. The purpose of this filter is to remove high-frequency noise from a signal while preserving the underlying low-frequency components, such as trends or patterns.

![image](https://github.com/user-attachments/assets/ce30a6f8-6edd-4d66-837e-cb6200e536a5)


The key features of a Gaussian filter are:

* **Gaussian Kernel**: The kernel (filter window) is created using a Gaussian function, which is a bell-shaped curve. The function has the general form:

  ![image](https://github.com/user-attachments/assets/276552d3-7d37-43b4-bbea-ce96ba1a8a35)


  Where $\sigma$ controls the width of the bell curve.

* **Full Width Half Maximum (FWHM)**: This parameter defines the width of the Gaussian window at half of its peak value. In practice, the FWHM controls how much of the surrounding signal will be considered in the smoothing process. A smaller FWHM means the filter will only consider nearby points, while a larger FWHM considers a wider range of points.

* **Smoothing Effect**: The Gaussian filter is effective at smoothing signals, especially when the signal has high-frequency noise (rapid fluctuations) that you want to remove, such as in ECG signals, audio signals, or financial data.

* **Normalization**: The Gaussian kernel is normalized to have unit energy, ensuring that the filter doesn't amplify or attenuate the signal during the smoothing process.

---

#### **Why and When is it Used?**

A Gaussian smoothing filter is commonly used when:

* **Noise Removal**: To remove high-frequency noise from a signal without distorting its underlying features.
* **Signal Smoothing**: To smooth out fluctuations and make a signal more interpretable, especially when visualizing or analyzing time series data.
* **Preprocessing for Analysis**: Often applied as a preprocessing step in various analyses, such as feature extraction, time series forecasting, or machine learning.

---

### **Code Explanation**

Now, let’s go through the **MATLAB code** step-by-step, explaining each section, function, and operation.

---

#### **Step 1: Creating the Noisy Signal**

```matlab
% create signal
srate = 1000; % Hz
time  = 0:1/srate:3;
n     = length(time);
p     = 15; % poles for random interpolation

% noise level, measured in standard deviations
noiseamp = 5; 

% amplitude modulator and noise level
ampl   = interp1(rand(p,1)*30, linspace(1,p,n));
noise  = noiseamp * randn(size(time));
signal = ampl + noise;
```

1. **Sampling Rate (`srate`)**:

   * **`srate = 1000;`** sets the **sampling rate** to 1000 Hz, meaning the signal is sampled 1000 times per second.

2. **Time Vector (`time`)**:

   * **`time = 0:1/srate:3;`** creates a **time vector** that starts from 0 and goes up to 3 seconds, with a time step of `1/srate` (0.001 seconds). This creates a total of 3001 time points.

3. **Noise Parameters (`noiseamp`)**:

   * **`noiseamp = 5;`** defines the noise amplitude. It controls how strong the noise will be when added to the signal.

4. **Amplitude Modulator (`ampl`)**:

   * **`ampl = interp1(rand(p,1)*30, linspace(1,p,n));`** generates an **amplitude modulated signal** using linear interpolation of random values. This modulates the amplitude of the signal over time.

5. **Gaussian Noise (`noise`)**:

   * **`noise = noiseamp * randn(size(time));`** generates **Gaussian noise** with a standard deviation controlled by `noiseamp`. The function `randn(size(time))` generates random values from a standard normal distribution.

6. **Final Signal (`signal`)**:

   * **`signal = ampl + noise;`** adds the modulated amplitude (`ampl`) to the noise (`noise`), creating the final noisy signal.

---

#### **Step 2: Creating the Gaussian Kernel (Filter)**

```matlab
% full-width half-maximum: the key Gaussian parameter
fwhm = 25; % in ms

% normalized time vector in ms
k = 100;
gtime = 1000*(-k:k)/srate;

% create Gaussian window
gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );

% compute empirical FWHM
pstPeakHalf = k + dsearchn(gauswin(k+1:end)', .5);
prePeakHalf = dsearchn(gauswin(1:k)', .5);

empFWHM = gtime(pstPeakHalf) - gtime(prePeakHalf);

% show the Gaussian
figure(1), clf, hold on
plot(gtime, gauswin, 'ko-', 'markerfacecolor', 'w', 'linew', 2)
plot(gtime([prePeakHalf pstPeakHalf]), gauswin([prePeakHalf pstPeakHalf]), 'm', 'linew', 3)

% then normalize Gaussian to unit energy
gauswin = gauswin / sum(gauswin);
title([ 'Gaussian kernel with requested FWHM ' num2str(fwhm) ' ms (' num2str(empFWHM) ' ms achieved)' ])
xlabel('Time (ms)'), ylabel('Gain')
```

1. **Full Width Half Maximum (`fwhm`)**:

   * **`fwhm = 25;`** sets the **Full Width Half Maximum** (FWHM) of the Gaussian window to 25 ms. This determines the width of the Gaussian curve at half its peak value.

2. **Time Vector for Gaussian (`gtime`)**:

   * **`gtime = 1000*(-k:k)/srate;`** creates a time vector `gtime` that spans from -100 ms to 100 ms (i.e., 201 time points). This vector represents the time points for the Gaussian window, and is scaled by the sampling rate.

3. **Gaussian Window Calculation (`gauswin`)**:

   * **`gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );`** creates the **Gaussian window** using the standard formula for a Gaussian function:

![image](https://github.com/user-attachments/assets/49f2c6f6-9cde-4e4c-9808-5aa78f09b22e)


     The factor `(4*log(2))` and division by `fwhm^2` ensures the correct scaling for the FWHM.

4. **Empirical FWHM Calculation (`empFWHM`)**:

   * **`dsearchn`** finds the time points where the Gaussian window reaches half of its peak value. This is used to calculate the **empirical FWHM** for comparison with the requested FWHM.

5. **Plotting the Gaussian Window**:

   * The Gaussian window (`gauswin`) is plotted to visualize its shape. The **magenta line** highlights the points where the window reaches half of its peak.

6. **Normalization**:

   * **`gauswin = gauswin / sum(gauswin);`** normalizes the Gaussian window so that the sum of the window equals 1. This ensures that the filter does not distort the signal’s amplitude during smoothing.

---

#### **Step 3: Applying the Gaussian Filter**

```matlab
% initialize filtered signal vector
filtsigG = signal;

% implement the Gaussian filter
for i = k+1:n-k-1
    % each point is the weighted average of k surrounding points
    filtsigG(i) = sum( signal(i-k:i+k).*gauswin );
end
```

1. **Filtered Signal Initialization (`filtsigG`)**:

   * **`filtsigG = signal;`** initializes the filtered signal (`filtsigG`) as a copy of the noisy signal (`signal`).

2. **Gaussian Filtering**:

   * **`for i = k+1:n-k-1`** iterates through the signal, except for the edges where there aren't enough points for filtering.
   * **`filtsigG(i) = sum( signal(i-k:i+k).*gauswin );`** applies the **Gaussian filter** by taking the weighted sum of `2k+1` points from the signal, weighted by the Gaussian window `gauswin`.

---

#### **Step 4: Plotting the Noisy and Filtered Signals**

```matlab
figure(2), clf, hold on
plot(time, signal, 'r') % Plot the noisy signal in red
plot(time, filtsigG, 'k', 'linew', 3) % Plot the Gaussian-filtered signal in black

xlabel('Time (s)'), ylabel('amp. (a.u.)')
legend({'Original signal'; 'Gaussian-filtered'})
title('Gaussian smoothing filter')
```

1. **Plot the Signals**:

   * The **noisy signal** (`signal`) is plotted in **red**.
   * The **filtered signal** (`filtsigG`) is plotted in **black** with a line width of 3 for emphasis.
   * This provides a visual comparison of the original noisy signal and the signal after Gaussian filtering.

---

#### **Step 5: Comparison with Running Mean Filter**

```matlab
% initialize filtered signal vector
filtsigMean = zeros(size(signal));

% implement the running mean filter
k = 20; % filter window is actually k*2+1
for i = k+1:n-k-1
    % each point is the average of k surrounding points
    filtsigMean(i) = mean(signal(i-k:i+k));
end

plot(time, filtsigMean, 'b', 'linew', 2) % Plot the mean-filtered signal in blue
legend({'Original signal'; 'Gaussian-filtered'; 'Running mean'})
zoom on
```

1. **Running Mean Filter**:

   * A **running mean filter** is applied to compare with the Gaussian filter. The running mean calculates the **simple average** of `2k+1` neighboring points.
   * This is done by iterating through the signal and computing the average for each point.

2. **Comparison Plot**:

   * The filtered signal from the **Gaussian filter** and the **running mean filter** are compared alongside the original noisy signal.

---

### **Conclusion**

In this code, the **Gaussian filter** is applied to smooth a noisy signal, and the result is compared to a **mean filter**. The Gaussian filter, being a weighted average, effectively smooths the signal while preserving its general trend, unlike the mean filter, which averages the points equally.

#### Key Concepts:

* **Gaussian Filter**: Uses a bell-shaped curve (Gaussian function) for weighted averaging.
* **Running Mean Filter**: A simpler filter that takes an average over neighboring points, without considering the weights of points based on their proximity.
* **FWHM**: Determines the width of the Gaussian filter, controlling how much surrounding data is considered during smoothing.

By using a Gaussian smoothing filter, we can remove noise from signals while preserving the underlying structure, which is useful in many fields like signal processing, image processing, and time-series analysis.
