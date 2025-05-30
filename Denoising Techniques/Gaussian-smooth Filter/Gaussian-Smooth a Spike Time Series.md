### **Gaussian-Smooth a Spike Time Series: Documentation and Code Explanation**

---

#### **Objective:**

This example demonstrates how to generate a time series of **spikes** (e.g., in neural data), apply a **Gaussian smoothing filter** to smooth the spike data, and visualize the result. The Gaussian filter will help in estimating the **probability density function (PDF)** of the spike events over time.

#### **Key Concepts:**

* **Spike Train**: A series of discrete events (spikes) that occur in a time series.
* **Inter-Spike Interval (ISI)**: The time between consecutive spikes. In this case, the ISI is modeled using an **exponential distribution** to create bursts of spikes.
* **Gaussian Filter**: A weighted moving average filter that smooths the data using a Gaussian window. This is particularly useful to estimate the probability density of spike events over time, reducing high-frequency noise.

---

### **Code Breakdown:**

#### **Step 1: Generate Time Series of Random Spikes**

```matlab
% number of spikes
n = 300;

% inter-spike intervals (exponential distribution for bursts)
isi = round(exp( randn(n,1) )*10);

% generate spike time series
spikets = 0;
for i=1:n
    spikets(sum(isi(1:i))) = 1;
end

% plot
figure(1), clf, hold on
h = plot(spikets);
set(gca,'ylim',[0 1.01],'xlim',[0 length(spikets)+1])
set(h,'color',[1 1 1]*.7)
xlabel('Time (a.u.)')
```

1. **Number of Spikes (`n`)**:

   * **`n = 300;`** sets the **number of spikes** to 300. This is how many individual spike events will be generated in the time series.

2. **Inter-Spike Interval (`isi`)**:

   * **`isi = round(exp(randn(n,1)) * 10);`** generates the **inter-spike intervals** (ISI) for the spike train.

     * The ISI is modeled using an **exponential distribution** scaled by `10`. This gives a **random distribution of time gaps** between spikes, simulating bursts of activity with variable time intervals.
     * The `round` function rounds these values to the nearest integer to create discrete spike intervals.

3. **Generating the Spike Train (`spikets`)**:

   * The **spike time series** (`spikets`) is created by setting entries at positions corresponding to the cumulative sum of ISI values to 1 (indicating a spike event at those times).

     * **`spikets(sum(isi(1:i))) = 1;`** assigns a spike at time `sum(isi(1:i))`, simulating a spike at those time points.

4. **Plotting the Spike Train**:

   * **`plot(spikets)`** plots the spike train, with a value of 1 representing a spike and 0 representing no spike.
   * **`set(h,'color',[1 1 1]*.7)`** adjusts the color of the plot to a light gray.
   * The **`xlim` and `ylim`** functions adjust the plot's axis limits to ensure proper visualization.

---

#### **Step 2: Create and Implement the Gaussian Window (Kernel)**

```matlab
% full-width half-maximum: the key Gaussian parameter
fwhm = 25; % in points

% normalized time vector in ms
k = 100;
gtime = -k:k;

% create Gaussian window
gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );
gauswin = gauswin / sum(gauswin);
```

1. **Full Width Half Maximum (FWHM)**:

   * **`fwhm = 25;`** defines the **FWHM** of the Gaussian window, which is the width at half of the peak value. This controls how wide the Gaussian window is. A smaller FWHM will result in a more localized smoothing effect, while a larger FWHM will average over a wider range of time points.
2. **Gaussian Time Vector (`gtime`)**:

   * **`gtime = -k:k;`** creates a vector `gtime` that spans from `-k` to `k` points. This defines the range of time points that will be used for the Gaussian window. The value of `k = 100` means the window will consider a total of 201 time points (from -100 to 100).
3. **Gaussian Window Calculation (`gauswin`)**:

   * **`gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );`** computes the Gaussian window using the formula for a Gaussian distribution:

     $$
     G(x) = \exp\left(-\frac{x^2}{2\sigma^2}\right)
     $$

     where `x` is the time vector `gtime`, and the standard deviation $\sigma$ is derived from the FWHM. The expression `(4*log(2))` scales the Gaussian to match the desired FWHM.
4. **Normalization of the Gaussian Window**:

   * **`gauswin = gauswin / sum(gauswin);`** normalizes the Gaussian window to have **unit energy** (i.e., the sum of the weights equals 1). This ensures that the filter does not distort the signal’s amplitude when applied.

---

#### **Step 3: Apply the Gaussian Filter (Weighted Running Mean)**

```matlab
% initialize filtered signal vector
filtsigG = zeros(size(spikets));

% implement the weighted running mean filter
for i=k+1:length(spikets)-k-1
    filtsigG(i) = sum( spikets(i-k:i+k).*gauswin );
end
```

1. **Filtered Signal Initialization (`filtsigG`)**:

   * **`filtsigG = zeros(size(spikets));`** initializes the **filtered signal** (`filtsigG`) as a zero vector with the same size as the original spike time series (`spikets`).

2. **Gaussian Smoothing**:

   * **`for i=k+1:length(spikets)-k-1`** iterates over the spike time series, starting at index `k+1` and ending at `length(spikets)-k-1` to avoid issues near the edges of the signal where there are not enough neighboring points to apply the filter.
   * **`filtsigG(i) = sum( spikets(i-k:i+k).*gauswin );`** applies the **weighted running mean** filter:

     * For each time point `i`, the sum of the products of the signal values within a window of size `2k+1` (surrounding points) and the Gaussian window `gauswin` is calculated.
     * This weighted sum smooths the spike train, giving the **probability density** of spike events at each point in time.

---

#### **Step 4: Plot the Results (Spike Train and Probability Density)**

```matlab
% plot the filtered signal (spike probability density)
plot(filtsigG,'r','linew',2)
legend({'Spikes','Spike p.d.'})
title('Spikes and spike probability density')
zoom on
```

1. **Plot the Smoothed Signal**:

   * **`plot(filtsigG, 'r', 'linew', 2)`** plots the **filtered signal** (`filtsigG`) in **red** with a line width of 2.
   * This smoothed signal represents the **spike probability density** over time.

2. **Legend and Title**:

   * **`legend({'Spikes','Spike p.d.'})`** adds a legend to the plot to label the original spike events and the filtered (smoothed) spike probability density.
   * **`title('Spikes and spike probability density')`** adds a title to the plot.

---

### **Conclusion**

This code demonstrates how to:

1. **Generate a random spike train** with exponentially distributed **inter-spike intervals** (ISI).
2. **Apply a Gaussian filter** to the spike train to smooth it and estimate the spike **probability density**.
3. **Visualize the original spike train** and the **smoothed spike probability density**.

#### Key Concepts:

* **Spike Train**: A time series of discrete events (spikes).
* **Inter-Spike Interval (ISI)**: The time between consecutive spikes.
* **Gaussian Filter**: A smoothing filter that applies weights based on a Gaussian distribution to reduce noise and estimate the probability density of events.
* **Smoothed Spike Probability Density**: The filtered version of the spike train, showing the likelihood of spike events over time.

This technique is often used in neural signal processing and other applications where spikes or events need to be smoothed to better understand underlying patterns and densities.
