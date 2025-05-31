## **Taeger-Kaiser Energy-Tracking Operator (TKEO): Documentation**

### **What is TKEO?**

The **Taeger-Kaiser Energy-Tracking Operator (TKEO)** is a mathematical tool used to analyze the instantaneous energy in a signal. It is especially useful in **biomedical signal processing** (like EMG and EEG), speech analysis, and other areas where detecting bursts, spikes, or high-energy events is important. TKEO is a nonlinear operator that highlights regions of high activity and suppresses noise.

#### **TKEO Formula**

For a real-valued discrete-time signal $x[n]$:

$$
\Psi\{x[n]\} = x[n]^2 - x[n-1] \cdot x[n+1]
$$

* $x[n]$ is the signal at time $n$.
* The result is a new time series that reflects the *local energy* of the original signal.

#### **Key Properties**

* **Nonlinear**: Sensitive to sudden changes, bursts, and oscillations.
* **Noise Reduction**: Suppresses background noise, making features like muscle bursts (in EMG) more visible.
* **Edge Detector**: Responds strongly to spikes and abrupt transitions.
* **Fast and Simple**: Can be computed efficiently with basic arithmetic.

#### **When is TKEO Used?**

* **EMG/EEG/biomedical analysis**: Detecting muscle activations, brain events, or spikes.
* **Speech/sound**: Envelope extraction and burst detection.
* **Seismic/mechanical monitoring**: Identifying transient events.

---

## **Example: Denoising EMG with TKEO in MATLAB**

### **Step 1: Import Data**

```matlab
load emg4TKEO.mat
```

* Loads two variables: `emg` (the EMG signal) and `emgtime` (time vector).

### **Step 2: Apply TKEO**

**Loop version (to show the algorithm step-by-step):**

```matlab
emgf = emg;
for i=2:length(emgf)-1
    emgf(i) = emg(i)^2 - emg(i-1)*emg(i+1);
end
```

* For each sample except the first and last, the TKEO is computed.

**Vectorized version (faster for MATLAB):**

```matlab
emgf2 = emg;
emgf2(2:end-1) = emg(2:end-1).^2 - emg(1:end-2).*emg(3:end);
```

* Same as above, but computes all values at once.

### **Step 3: Z-score Normalization**

```matlab
time0 = dsearchn(emgtime',0);

emgZ = (emg-mean(emg(1:time0))) / std(emg(1:time0));
emgZf = (emgf-mean(emgf(1:time0))) / std(emgf(1:time0));
```

* Finds the time point corresponding to zero (pre-stimulus).
* Normalizes both the raw and filtered signals using the mean and standard deviation before time zero, giving them a *z-score* relative to the baseline.

### **Step 4: Plot Results**

```matlab
figure(1), clf

% First subplot: normalized amplitude/energy
subplot(211), hold on
plot(emgtime, emg./max(emg), 'b', 'linew', 2)
plot(emgtime, emgf./max(emgf), 'm', 'linew', 2)
xlabel('Time (ms)'), ylabel('Amplitude or energy')
legend({'EMG', 'EMG energy (TKEO)'})

% Second subplot: z-scored
subplot(212), hold on
plot(emgtime, emgZ, 'b', 'linew', 2)
plot(emgtime, emgZf, 'm', 'linew', 2)
xlabel('Time (ms)'), ylabel('Zscore relative to pre-stimulus')
legend({'EMG', 'EMG energy (TKEO)'})
```

* **Top subplot**: Compares the original EMG (blue) and TKEO-filtered signal (magenta), both normalized by their maximum value.
* **Bottom subplot**: Plots the z-scored versions of the signals, which helps to see the energy relative to the pre-stimulus baseline.

---

### **Summary:**

* The **TKEO** emphasizes periods of high energy and suppresses background noise, making it easier to detect bursts or events in a signal.
* In EMG, TKEO can reveal muscle activation more clearly than the raw signal.
* This technique is valuable wherever you need to **track instantaneous energy** or highlight events within a noisy time series.

