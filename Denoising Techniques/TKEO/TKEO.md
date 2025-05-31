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

### Example: Denoising an EMG Signal with TKEO in MATLAB

This example shows how to apply the TKEO to an electromyogram (EMG) recording for noise reduction and feature enhancement.

#### Step 1: Import Data

```matlab
% import data
load emg4TKEO.mat
```

* The EMG data (`emg`) and corresponding time vector (`emgtime`) are loaded from a `.mat` file.

#### Step 2: Apply TKEO (Two Methods)

**a. Loop Version (for understanding):**

```matlab
% initialize filtered signal
emgf = emg;
for i=2:length(emgf)-1
    emgf(i) = emg(i)^2 - emg(i-1)*emg(i+1);
end
```

* For each point (except first and last), calculate TKEO using its current value, the previous value, and the next value.

**b. Vectorized Version (faster in MATLAB):**

```matlab
emgf2 = emg;
emgf2(2:end-1) = emg(2:end-1).^2 - emg(1:end-2).*emg(3:end);
```

* Computes TKEO for all valid points in a single line, which is more efficient in MATLAB.

#### Step 3: Z-score Normalization

```matlab
% find timepoint zero
time0 = dsearchn(emgtime',0);

% convert original EMG to z-score from time-zero
emgZ = (emg-mean(emg(1:time0))) / std(emg(1:time0));

% same for filtered EMG energy
emgZf = (emgf-mean(emgf(1:time0))) / std(emgf(1:time0));
```

* The signals are normalized to **z-scores** using the pre-stimulus period (all points up to `time = 0`).
* Z-scoring means the mean is 0 and the standard deviation is 1 in the baseline, allowing for easier comparison between signals.

#### Step 4: Plot the Results

```matlab
figure(1), clf

% plot "raw" (normalized to max-1)
subplot(211), hold on
plot(emgtime,emg./max(emg),'b','linew',2)
plot(emgtime,emgf./max(emgf),'m','linew',2)

xlabel('Time (ms)'), ylabel('Amplitude or energy')
legend({'EMG';'EMG energy (TKEO)'})

% plot zscored
subplot(212), hold on
plot(emgtime,emgZ,'b','linew',2)
plot(emgtime,emgZf,'m','linew',2)

xlabel('Time (ms)'), ylabel('Zscore relative to pre-stimulus')
legend({'EMG';'EMG energy (TKEO)'})
```

* **First subplot:** Plots original and TKEO-filtered EMG (both normalized by their maximum value for clear visualization).
* **Second subplot:** Plots both signals as z-scores, showing the effect of TKEO on the energy profile.

---

#### **Summary of Effects**

* The **TKEO output** (`emgf`) highlights areas where the EMG signal has bursts or high-frequency activity (e.g., muscle activation), making it easier to distinguish real activity from background noise.
* TKEO is particularly powerful for denoising and feature extraction in short-duration, high-energy signal bursts, as is common in biomedical signals.

---

#### **When to Use TKEO?**

* When you need to detect short, high-energy events in a noisy signal.
* When you want to track the energy or envelope of a nonstationary time series.
* In preprocessing pipelines for EMG/EEG/voice, where feature extraction is needed before classification or further analysis.
