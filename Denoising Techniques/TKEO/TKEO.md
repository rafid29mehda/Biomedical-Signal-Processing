### Taeger-Kaiser Energy-Tracking Operator (TKEO)

---

#### What is the Taeger-Kaiser Energy-Tracking Operator (TKEO)?

The **Taeger-Kaiser Energy-Tracking Operator (TKEO)** is a nonlinear signal processing operator used for analyzing the *instantaneous energy* of a signal, especially in time series data such as EMG (electromyogram) or EEG (electroencephalogram) recordings. TKEO is highly effective for highlighting signal features like bursts, spikes, and rapid oscillations. It is especially useful for **denoising** (reducing noise), **feature extraction**, and **event detection** in biomedical signals.

##### Mathematical Formula

For a real-valued discrete signal $x[n]$, the TKEO is defined as:

$$
\Psi\{x[n]\} = x[n]^2 - x[n-1] \cdot x[n+1]
$$

* $x[n]$: Value of the signal at time (sample) n
* $x[n-1]$: Previous sample
* $x[n+1]$: Next sample

This operator computes an "instantaneous energy" value for each point in the signal, reflecting both the signal's amplitude and its local oscillatory behavior.

##### Key Properties

* **Nonlinear:** Unlike simple linear filters, TKEO is nonlinear and can enhance short-lived, high-energy features like spikes or bursts.
* **Edge Detection:** TKEO is sensitive to abrupt changes and is often used for detecting onsets or bursts in signals.
* **Noise Reduction:** It can suppress low-energy noise and highlight significant features, improving the clarity of noisy signals.
* **Computationally Simple:** Easy to implement with just a few arithmetic operations per sample.

##### Typical Applications

* Denoising EMG, EEG, or other biosignals
* Voice or speech signal analysis
* Seismic and mechanical signal monitoring
* Instantaneous frequency and energy tracking

---

### Example 1: Denoising an EMG Signal with TKEO in MATLAB

This example shows how to apply the TKEO to an electromyogram (EMG) recording for noise reduction and feature enhancement.

### **Step 1: Load the Data**

```matlab
load emg4TKEO.mat
```

* Loads the EMG signal and time vector from a file into your MATLAB workspace.
* You now have:

  * `emg` — the raw EMG data.
  * `emgtime` — time points for each sample.

---

### **Step 2: Apply the TKEO**

#### **A. Loop Version (easy to understand):**

```matlab
emgf = emg; % Start with a copy of the original
for i = 2:length(emgf)-1
    emgf(i) = emg(i)^2 - emg(i-1)*emg(i+1);
end
```

* This for-loop runs from the 2nd sample to the second-last sample.
* For each sample `i`, it applies the TKEO formula.

  * It squares the value at position `i` (the current value).
  * Then subtracts the product of the value before and after.
* The output `emgf` is the **energy-tracked** version of the signal.

#### **B. Vectorized Version (fast and compact in MATLAB):**

```matlab
emgf2 = emg;
emgf2(2:end-1) = emg(2:end-1).^2 - emg(1:end-2).*emg(3:end);
```

* Does the same thing as above, but for all valid points at once (without a loop).
* Faster and more efficient in MATLAB.

---

### **Step 3: Convert Both Signals to Z-Score**

**What is z-score?**

* A z-score tells you how far a value is from the mean in units of standard deviation. It's helpful for comparing signals with different amplitudes.

```matlab
time0 = dsearchn(emgtime', 0); % Find the index where time is closest to 0

% Normalize both signals based on pre-stimulus (before time = 0)
emgZ = (emg - mean(emg(1:time0))) / std(emg(1:time0));
emgZf = (emgf - mean(emgf(1:time0))) / std(emgf(1:time0));
```

* **`dsearchn(emgtime', 0)`** finds the index in the time vector where time is closest to zero.
* For both the raw EMG and the TKEO output, we:

  * Subtract the mean before time=0.
  * Divide by the standard deviation before time=0.
* This means before any event, both signals have a mean of 0 and a standard deviation of 1.

---

### **Step 4: Plot the Results**

```matlab
figure(1), clf

% First plot: raw and TKEO (normalized to their maximum for clear comparison)
subplot(211), hold on
plot(emgtime, emg./max(emg), 'b', 'linew', 2)
plot(emgtime, emgf./max(emgf), 'm', 'linew', 2)
xlabel('Time (ms)'), ylabel('Amplitude or energy')
legend({'EMG', 'EMG energy (TKEO)'})

% Second plot: z-scored versions
subplot(212), hold on
plot(emgtime, emgZ, 'b', 'linew', 2)
plot(emgtime, emgZf, 'm', 'linew', 2)
xlabel('Time (ms)'), ylabel('Zscore relative to pre-stimulus')
legend({'EMG', 'EMG energy (TKEO)'})
```

* **First subplot**: Plots the original EMG signal (blue) and the TKEO-filtered signal (magenta). Both are divided by their max value to be on the same scale.
* **Second subplot**: Plots the z-scored versions of both signals. This shows, in terms of standard deviations, how much energy is present after an event.

---

### **What Does TKEO Do Here?**

* TKEO makes the energy bursts (like muscle activation in EMG) **much more visible**, especially when compared to background noise.
* You can more easily detect **when and where events happen** in your signal.

---

## **Summary Table**

| Step                  | What it Does                                   |
| --------------------- | ---------------------------------------------- |
| Load data             | Brings EMG and time into MATLAB                |
| Apply TKEO            | Highlights bursts, suppresses noise            |
| Z-score normalization | Allows easy comparison (units: std dev)        |
| Plot results          | Visualizes original and energy-tracked signals |


---

## Example 2

---

## **Step 1: Create a Synthetic Noisy Signal with a Burst**

```matlab
srate = 1000; % Samples per second
n = 2000; % Number of data points (for 2 seconds of data)
time = (0:n-1)/srate; % Make a vector with each time point in seconds
```

**Explanation:**

* `srate = 1000` means you are simulating a signal that is sampled 1000 times every second (like a 1000 Hz digital recording).
* `n = 2000` sets the length of the signal to 2000 points. If each point is 1 ms apart (since 1/1000 seconds), this means the total signal length is 2 seconds.
* `time = (0:n-1)/srate` creates a vector that holds the actual time (in seconds) for each sample. The first sample is at 0 seconds, the last is at (n-1)/1000 seconds.

---

```matlab
signal = randn(1, n) * 0.3; % Make noise (mean=0, std=0.3), size: 1 x n
```

* `randn(1, n)` makes a row of n numbers randomly chosen from a normal (Gaussian) distribution.
* Multiplying by 0.3 means the noise is not too big.
* This simulates real-world background noise that you might see in any sensor or biomedical signal.

---

```matlab
burst_start = 800; % Start of the burst (data point 800)
burst_end = 1200; % End of the burst (data point 1200)
signal(burst_start:burst_end) = signal(burst_start:burst_end) + sin(2*pi*20*time(burst_start:burst_end)) * 3;
```

* We want to simulate an 'event' (like a muscle contracting). We choose a region from data point 800 to 1200.
* `sin(2*pi*20*time(...))` makes a sine wave with 20 cycles per second (20 Hz) just in this region.
* Multiplying the sine wave by 3 makes this burst much bigger than the noise.
* We add this burst to the noise only in this segment.

Now, the signal is mostly small random noise, but has a big, obvious burst in the middle (like a brief event).

---

## **Step 2: Apply TKEO to the Signal**

```matlab
tkeo = zeros(1, n); % Make a zero vector the same size as signal
for i = 2:n-1
    tkeo(i) = signal(i)^2 - signal(i-1)*signal(i+1);
end
```

* `tkeo = zeros(1, n);` creates a vector (row of numbers) full of zeros to store the TKEO result. It's the same length as `signal`.
* The `for` loop goes from the 2nd data point to the 2nd-to-last. This is because the TKEO formula needs to look at each point, the point before, and the point after. At the very start and end, you can't do this, so we skip them.
* `tkeo(i) = signal(i)^2 - signal(i-1)*signal(i+1);` applies the TKEO formula for each point:

  * Square the value at position i
  * Multiply the values just before and after i, and subtract that from the square
* The result: **tkeo** will have small values during noise, and much bigger values where there's a burst/event.

---

## **Step 3: Normalize Both Signals (so they're easy to compare visually)**

```matlab
signal_norm = signal / max(abs(signal)); % Now signal's biggest value is 1 or -1
tkeo_norm = tkeo / max(abs(tkeo));       % Same for TKEO result
```

* Dividing by the biggest value in the signal makes the whole signal fit between -1 and 1. This is just for plotting, so both signals show up nicely on the graph.

---

## **Step 4: Plot Both Signals for Comparison**

```matlab
figure;
subplot(2,1,1);
plot(time, signal_norm, 'b'); % Plot noisy signal in blue
hold on;
plot(time(burst_start:burst_end), signal_norm(burst_start:burst_end), 'r', 'LineWidth', 2); % Highlight the burst in red
title('Original Noisy Signal (Normalized)');
ylabel('Amplitude');

subplot(2,1,2);
plot(time, tkeo_norm, 'm'); % Plot TKEO result in magenta
hold on;
plot(time(burst_start:burst_end), tkeo_norm(burst_start:burst_end), 'r', 'LineWidth', 2); % Highlight the burst in red
title('TKEO Output (Normalized)');
xlabel('Time (seconds)');
ylabel('Energy');
```

* `figure;` opens a new window for the plot.
* `subplot(2,1,1);` splits the window: the first (top) plot will be for the original signal.
* `plot(time, signal_norm, 'b');` draws the noisy signal in blue.
* `plot(time(burst_start:burst_end), signal_norm(burst_start:burst_end), 'r', 'LineWidth', 2);` highlights the burst segment in red for clarity.
* `title` and `ylabel` add labels so you know what you are looking at.

The second subplot is for the TKEO output:

* `plot(time, tkeo_norm, 'm');` plots the TKEO result ("energy") in magenta.
* The burst is again highlighted in red.
* Notice how in the TKEO plot, the burst becomes much more obvious!

---

## **What does this show you?**

* The original signal has noise everywhere, but you can see the burst if you look closely.
* In the TKEO output, the burst pops out **very clearly**. The noisy background is mostly small, while the event is big and obvious.

This is why TKEO is so useful for detecting bursts or events in real (noisy) signals.

---


#### **Summary of Effects**

* The **TKEO output** (`emgf`) highlights areas where the EMG signal has bursts or high-frequency activity (e.g., muscle activation), making it easier to distinguish real activity from background noise.
* TKEO is particularly powerful for denoising and feature extraction in short-duration, high-energy signal bursts, as is common in biomedical signals.

---

#### **When to Use TKEO?**

* When you need to detect short, high-energy events in a noisy signal.
* When you want to track the energy or envelope of a nonstationary time series.
* In preprocessing pipelines for EMG/EEG/voice, where feature extraction is needed before classification or further analysis.
