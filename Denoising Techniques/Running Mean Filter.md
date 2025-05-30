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

---

### **Code Explanation:**

Now, let's break down the MATLAB code provided, which applies a running mean filter to a noisy signal.

#### **1. Signal Creation:**

```matlab
srate = 1000; % Hz
time  = 0:1/srate:3;
n     = length(time);
p     = 15; % poles for random interpolation
```

* **`srate = 1000`**: The sampling rate of the signal is set to 1000 Hz, meaning the signal is sampled 1000 times per second.
* **`time = 0:1/srate:3`**: This generates a time vector that starts at 0 and ends at 3 seconds, with a step size of `1/srate`. The `time` vector represents the time points at which the signal is sampled.
* **`n = length(time)`**: This calculates the total number of samples in the signal, which is the length of the `time` vector.
* **`p = 15`**: This defines the number of "poles" for the random amplitude modulation. It's used to generate a random signal that will be modulated over time.

#### **2. Signal with Noise:**

```matlab
noiseamp = 5; 
ampl   = interp1(rand(p,1)*30, linspace(1,p,n));
noise  = noiseamp * randn(size(time));
signal = ampl + noise;
```

* **`noiseamp = 5`**: This defines the amplitude of the noise, determining how strong the noise will be.
* **`ampl`**: This creates a modulated amplitude signal. The `interp1` function interpolates random values (generated using `rand(p,1)`) to create a smoothly changing amplitude over time.
* **`noise`**: This generates random Gaussian noise with a standard deviation controlled by `noiseamp`. The `randn(size(time))` function generates a noise signal of the same size as the time vector.
* **`signal = ampl + noise`**: This combines the modulated signal (`ampl`) and the noise (`noise`) to form the final noisy signal.

#### **3. Initialize Filtered Signal:**

```matlab
filtsig = zeros(size(signal));
```

* **`filtsig`**: This creates a zero-initialized vector of the same length as the original signal. This vector will store the filtered (smoothed) signal after applying the running mean filter.

#### **4. Apply Running Mean Filter:**

```matlab
k = 20; % filter window is actually k*2+1
for i = k+1:n-k-1
    % each point is the average of k surrounding points
    filtsig(i) = mean(signal(i-k:i+k));
end
```

* **`k = 20`**: The window size for the filter is set to `k*2 + 1 = 41`. This means each point in the signal will be replaced by the average of 41 points: 20 points before it and 20 points after it.
* **Loop**: The `for` loop starts at index `k+1` and ends at `n-k-1`, ensuring that only the points in the middle of the signal (away from the edges) are processed. For each point `i`, the average of the surrounding points is calculated using the `mean` function.

  * **`mean(signal(i-k:i+k))`**: This computes the average of the `2k+1` surrounding points in the signal.

#### **5. Compute Window Size in Milliseconds:**

```matlab
windowsize = 1000*(k*2+1) / srate;
```

* **`windowsize`**: This converts the window size from samples to milliseconds. The window size in samples is `k*2 + 1`, and dividing by the sampling rate (`srate`) gives the window size in seconds. Multiplying by 1000 converts it to milliseconds.

#### **6. Plotting the Results:**

```matlab
figure(1), clf, hold on
plot(time, signal, time, filtsig, 'linew', 2)
```

* **`figure(1), clf, hold on`**: Creates a new figure window and clears any previous plots. `hold on` allows multiple plots to be overlayed on the same figure.
* **`plot(time, signal, time, filtsig, 'linew', 2)`**: This plots both the original noisy signal (`signal`) and the filtered signal (`filtsig`) on the same graph. The `'linew', 2` argument sets the line width to 2 pixels, making the lines thicker.

#### **7. Indicate the Window Size on the Plot:**

```matlab
tidx = dsearchn(time', 1);
ylim = get(gca, 'ylim');
patch(time([tidx-k tidx-k tidx+k tidx+k]), ylim([1 2 2 1]), 'k', 'facealpha', .25, 'linestyle', 'none')
plot(time([tidx tidx]), ylim, 'k--')
```

* **`tidx = dsearchn(time', 1)`**: Finds the index of the time point closest to 1 second in the time vector.
* **`patch(...)`**: This draws a shaded region on the plot to show the size of the filter window, centered around `tidx`. The window spans from `tidx-k` to `tidx+k`.
* **`plot(...)`**: This draws a dashed vertical line at `tidx` to indicate the center of the window.

#### **8. Final Plot Enhancements:**

```matlab
xlabel('Time (sec.)'), ylabel('Amplitude')
title(['Running-mean filter with a k=' num2str(round(windowsize)) '-ms filter'])
legend({'Signal'; 'Filtered'; 'Window'; 'window center'})
```

* **`xlabel`, `ylabel`, `title`**: These functions add labels to the axes and a title to the plot.
* **`legend`**: This adds a legend explaining the different plot elements.

#### **9. Zooming:**

```matlab
zoom on
```

* This enables interactive zooming on the plot.

---

### **Conclusion:**

* The **Running Mean Filter** is a simple and effective tool for smoothing noisy signals by averaging neighboring data points.
* The code creates a noisy signal, applies a running mean filter to reduce the noise, and then visualizes the result.
* By adjusting the window size (parameter `k`), you can control the amount of smoothing, with larger windows resulting in more smoothing.

This technique is commonly used in various applications, such as data preprocessing in machine learning, sensor data analysis, and signal processing, to improve signal clarity by removing unwanted noise.
