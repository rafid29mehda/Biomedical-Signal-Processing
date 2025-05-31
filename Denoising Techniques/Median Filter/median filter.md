## **Median Filter: Complete Documentation and Beginner-Friendly Explanation**

### **What is a Median Filter?**

A **median filter** is a signal processing technique used to **remove spikes or outliers (impulsive noise)** from a signal while preserving the overall trend and shape. Unlike other filters (like the mean filter), the median filter replaces each data point with the **median** (middle value) of its neighboring values. This makes it **very effective at removing large, sudden deviations** (called impulse noise) without blurring the signal.

### **Why Use a Median Filter?**

* Removes sharp noise spikes (called salt-and-pepper or impulse noise).
* Preserves edges and trends in the data better than average (mean) filters.
* Common in image and signal processing where data is corrupted by outliers.

### **Key Concepts**

* **Window size (k)**: Number of data points on each side of the current point considered. The total window is `2k+1` points.
* **Median**: The middle value of sorted numbers. For example, the median of \[2, 7, 4] is 4.

![image](https://github.com/user-attachments/assets/d0f816ad-eba7-41a3-9bb9-cd3b3c76be1e)

---

## **Example Code Walkthrough**

### **Step 1: Create a Synthetic Signal**

```matlab
n = 2000;
signal = cumsum(randn(n,1));
```

* **`n = 2000;`**: We create a signal with 2000 data points.
* **`randn(n,1)`**: Generates 2000 random values from a normal distribution.
* **`cumsum(...)`**: Takes the cumulative sum of the random numbers, simulating a slowly drifting signal (like sensor output over time).

### **Step 2: Add Noise (Outliers)**

```matlab
propnoise = .05;
noisepnts = randperm(n);
noisepnts = noisepnts(1:round(n*propnoise));
signal(noisepnts) = 50 + rand(size(noisepnts))*100;
```

* **`propnoise = 0.05`**: We want 5% of the signal (5% of 2000 = 100 points) to be corrupted.
* **`randperm(n)`**: Creates a shuffled list of indices from 1 to 2000.
* **`noisepnts = noisepnts(1:round(n*propnoise));`**: Picks the first 100 random positions to be noise.
* **`signal(noisepnts) = 50 + rand(...) * 100;`**: Sets those values to a high range (between 50 and 150). These are the artificial outliers or noise spikes.

### **Step 3: Visualize the Noisy Signal**

```matlab
figure(1), clf
histogram(signal,100)
zoom on
```

* Creates a histogram with 100 bins to show how the signal values are distributed.
* The noisy points (values > 50) show up clearly in the histogram.

### **Step 4: Choose a Threshold to Detect Noise**

```matlab
threshold = 40;
suprathresh = find( signal > threshold );
```

* Based on the histogram, we decide anything over 40 is likely an outlier.
* `find(...)` returns the indices of all values in `signal` that are greater than 40. These are the noisy points we want to fix.

### **Step 5: Apply the Median Filter**

```matlab
filtsig = signal;
k = 20; % window size on each side

for ti = 1:length(suprathresh)
    lowbnd = max(1, suprathresh(ti)-k);   % don't go below index 1
    uppbnd = min(suprathresh(ti)+k, n);   % don't go beyond index n

    filtsig(suprathresh(ti)) = median(signal(lowbnd:uppbnd));
end
```

* **`filtsig = signal;`**: Start with a copy of the original signal.
* **`k = 20;`**: Each filter window includes 20 points before and after the noisy point, totaling 41 values.
* For each noisy point:

  * **`lowbnd`** is the start of the window (but not less than 1).
  * **`uppbnd`** is the end of the window (but not more than the signal length).
  * We take all the points from `lowbnd` to `uppbnd` and compute the **median**.
  * The noisy point is then replaced by this median.

This step **replaces only the identified noisy points**, keeping the rest of the signal untouched.

### **Step 6: Plot the Original and Filtered Signal**

```matlab
figure(2), clf
plot(1:n, signal, 1:n, filtsig, 'linew', 2)
zoom on
```

* Plots both the original signal (with noise spikes) and the filtered signal.
* We’ll clearly see that:

  * The original signal has sudden tall spikes.
  * The filtered signal smoothly follows the trend with the spikes removed.

---

## **Summary**

| Step                | Purpose                                          |
| ------------------- | ------------------------------------------------ |
| Create Signal       | Simulate a real-world data stream                |
| Add Noise           | Mimic real-world sensor errors or outliers       |
| Histogram           | Help us choose a noise threshold visually        |
| Find Outliers       | Detect values that are likely corrupted          |
| Apply Median Filter | Fix the corrupted values using nearby clean data |
| Plot                | Visually compare before and after                |

---

## **When Should You Use a Median Filter?**

* When the data has **spiky outliers** or **salt-and-pepper noise**.
* When we want to **preserve the shape** of the signal (unlike a moving average which can blur it).
* In **image processing**, **biomedical signals**, **financial data**, etc.

