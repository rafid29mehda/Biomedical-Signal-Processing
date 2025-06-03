Let’s go step by step and **learn Polynomial Detrend in MATLAB** from the very basics. I’ll explain everything: what it is, why you need it, how it works, and break down the code line by line with extra notes and examples.

---

## What is Polynomial Detrending?

**Detrending** is the process of removing a trend (slowly changing component) from your data to analyze the remaining fluctuations (fast changes or noise).

* **Polynomial detrending** uses a polynomial (curve) to fit the trend, and then subtracts this fit from the original signal, leaving only the “residual” or detrended signal.

### Why is Detrending Useful?

* Many signals, especially in experimental data, have unwanted slow drifts (artifacts, baseline wandering, instrument drift).
* Removing the trend helps to **analyze the true signal** (e.g., for detecting peaks, events, or applying further processing).
* In machine learning, removing trends can help algorithms focus on relevant patterns rather than artifacts.

---

## Key Concepts: What is a Polynomial?

A **polynomial** is a mathematical function like:

$$
y = a_0 + a_1x + a_2x^2 + ... + a_nx^n
$$

* **Order 0**: a flat line.
* **Order 1**: a straight line.
* **Order 2**: a parabola.
* Higher orders: more wavy curves.

The **order** tells you how flexible the fit is. Higher order = fits more twists in the data.

---

## Step-by-Step Code Breakdown

### 1. **Polynomial Intuition**

**Code:**

```matlab
order = 0;
x = linspace(-15,15,100);

y = zeros(size(x));
for i=1:order+1
    y = y + randn*x.^(i-1);
end

figure(1), clf
hold on
plot(x,y,'linew',4)
title([ 'Order-' num2str(order) ' polynomial' ])
```

#### **Explanation:**

* `order = 0;` — Order of polynomial (change to 1, 2, etc. to see different curves).
* `x = linspace(-15,15,100);` — 100 evenly spaced points between -15 and 15.
* `y = zeros(size(x));` — Make an empty y array.
* The **for-loop** builds a random polynomial:
  For order 0: just a constant line.
  For higher orders: adds more curviness.
* `plot(x,y,'linew',4)` — Plots the polynomial.

> **Try changing `order` to 1, 2, 3, etc., and see how the curve changes!**

---

### 2. **Generate a Signal with Slow Polynomial Artifact**

```matlab
n = 10000;
t = (1:n)';
k = 10; % number of poles for random amplitudes
slowdrift = interp1(100*randn(k,1),linspace(1,k,n),'pchip')';
signal = slowdrift + 20*randn(n,1);

figure(2), clf, hold on
h = plot(t,signal);
set(h,'color',[1 1 1]*.6)
xlabel('Time (a.u.)'), ylabel('Amplitude')
```

#### **Explanation:**

* **Purpose:** Simulate a signal with slow drift (artifact) + fast random noise.
* `n = 10000;` — Signal length.
* `t = (1:n)';` — Time vector.
* `k = 10;` — Number of random points to create the drift.
* `slowdrift = interp1(...);` — Makes a slowly-varying trend by interpolating between random points.
* `signal = slowdrift + 20*randn(n,1);` — Adds fast noise to the slow drift.
* **Plot:** Shows a noisy signal with slow drift (like many real signals!).

---

### 3. **Fit a 3rd-Order Polynomial to Remove the Drift**

```matlab
% polynomial fit (returns coefficients)
p = polyfit(t,signal,3);

% predicted data is evaluation of polynomial
yHat = polyval(p,t);

% compute residual (the cleaned signal)
residual = signal - yHat;

% plot the fit and residual
plot(t,yHat,'r','linew',4)
plot(t,residual,'k','linew',2)
legend({'Original';'Polyfit';'Filtered signal'})
```

#### **Explanation:**

* `p = polyfit(t,signal,3);` — Fits a 3rd-order polynomial to your signal.

  * Returns coefficients that define the best-fit curve.
* `yHat = polyval(p,t);` — Calculates the polynomial values at each time point (the trend estimate).
* `residual = signal - yHat;` — Subtracts the trend from the original signal (gives you the detrended signal).
* **Plot:** Shows original signal, polynomial fit (red), and filtered signal (black).


---

### Step 4: Bayes Information Criterion (BIC) for Optimal Polynomial Order

### **Full Code Block**

```matlab
% possible orders
orders = (5:40)';

% sum of squared errors (sse is reserved!)
sse1 = zeros(length(orders),1); 

% loop through orders
for ri=1:length(orders)
    
    % compute polynomial (fitting time series)
    yHat = polyval(polyfit(t,signal,orders(ri)),t);
    
    % compute fit of model to data (sum of squared errors)
    sse1(ri) = sum( (yHat-signal).^2 )/n;
end

% Bayes information criterion
bic = n*log(sse1) + orders*log(n);

% best parameter has lowest BIC
[bestP,idx] = min(bic);

% would continue getting smaller without adding parameters

% plot the BIC
figure(4), clf, hold on
plot(orders,bic,'ks-','markerfacecolor','w','markersize',8)
plot(orders(idx),bestP,'ro','markersize',10,'markerfacecolor','r')
xlabel('Polynomial order'), ylabel('Bayes information criterion')
zoom on
```

---

### **Detailed Line-by-Line Explanation**

#### **1. Setting Up Orders to Try**

```matlab
orders = (5:40)';
```

* **What it does:**
  Creates a column vector `orders` containing values from 5 to 40.
  These are the different polynomial orders (degrees) that will be tested for detrending.
* **Why:**
  To compare different polynomial complexities and pick the best one.

#### **2. Preallocate Array for Error Storage**

```matlab
sse1 = zeros(length(orders),1);
```

* **What it does:**
  Creates a column vector of zeros (same length as `orders`) to store the error value for each tested order.
* **Why:**
  Preallocating memory for speed and organization.
  `sse1` will later contain the average sum of squared errors (SSE) for each polynomial order.

#### **3. Loop Over Each Polynomial Order**

```matlab
for ri=1:length(orders)
```

* **What it does:**
  Begins a loop over each value in the `orders` array.
  `ri` is the loop index (row index).

---

#### **4. Fit and Evaluate the Polynomial at Each Order**

```matlab
    yHat = polyval(polyfit(t,signal,orders(ri)),t);
```

* **What it does:**

  * `polyfit(t,signal,orders(ri))`: Fits a polynomial of degree `orders(ri)` to the data (`t`, `signal`). Returns coefficients.
  * `polyval(...,t)`: Evaluates this polynomial at all time points `t`.
  * The result, `yHat`, is the fitted trend for this specific polynomial order.
* **Why:**
  This gives the estimated trend for the current order, so you can measure how well it fits the original signal.

---

#### **5. Compute the Fit Error**

```matlab
    sse1(ri) = sum( (yHat-signal).^2 )/n;
```

* **What it does:**

  * Calculates the **sum of squared errors** (SSE) between the fitted polynomial (`yHat`) and the actual signal.
  * The error is divided by `n` (number of samples) to get the **mean squared error**.
  * Stores this error in the array `sse1` at the current index.
* **Why:**
  The SSE measures how close the polynomial fit is to the real data. Lower means a better fit.

---

#### **6. End the Loop**

```matlab
end
```

* **What it does:**
  Marks the end of the `for` loop that tests each polynomial order.

---

#### **7. Calculate Bayes Information Criterion (BIC) for Each Order**

```matlab
bic = n*log(sse1) + orders*log(n);
```

* **What it does:**
  Calculates the BIC value for each polynomial order.

  * `n*log(sse1)`: Penalizes high error.
  * `orders*log(n)`: Penalizes model complexity (more parameters = higher penalty).
  * `bic` is a vector with one value per polynomial order.
* **Why:**
  BIC balances “fit quality” and “model complexity.”
  Lower BIC = better model that avoids overfitting.

---

#### **8. Find the Best Order (Minimum BIC)**

```matlab
[bestP,idx] = min(bic);
```

* **What it does:**

  * `min(bic)` returns the smallest BIC value (`bestP`) and its index (`idx`).
  * `idx` tells you which polynomial order (from `orders`) is optimal.
* **Why:**
  The polynomial order with the lowest BIC is the best compromise between fitting the data and not being too complicated.

---

#### **9. (Optional Comment)**

```matlab
% would continue getting smaller without adding parameters
```

* **What it does:**
  This is a comment (not executed).
  It notes that BIC helps prevent the temptation to keep increasing model complexity, which might lower error but leads to overfitting.

---

#### **10. Plot the BIC Values**

```matlab
figure(4), clf, hold on
plot(orders,bic,'ks-','markerfacecolor','w','markersize',8)
plot(orders(idx),bestP,'ro','markersize',10,'markerfacecolor','r')
xlabel('Polynomial order'), ylabel('Bayes information criterion')
zoom on
```

* **What it does:**

  * `figure(4), clf, hold on`: Opens figure window #4, clears it, allows multiple plots.
  * `plot(orders,bic,'ks-','markerfacecolor','w','markersize',8)`: Plots BIC vs. order as black squares connected by lines.
  * `plot(orders(idx),bestP,'ro','markersize',10,'markerfacecolor','r')`: Highlights the best order in red.
  * `xlabel`, `ylabel`: Adds axis labels.
  * `zoom on`: Enables zooming on the plot.
* **Why:**
  Visualizes how BIC changes with order and highlights the optimal choice.

---

### Step 5: Detrend Using the Best Polynomial Order

### **Full Code Block**

```matlab
% polynomial fit
polycoefs = polyfit(t,signal,orders(idx));

% estimated data based on the coefficients
yHat = polyval(polycoefs,t);

% filtered signal is residual
filtsig = signal - yHat;

%%% plotting
figure(5), clf, hold on
h = plot(t,signal);
set(h,'color',[1 1 1]*.6)
plot(t,yHat,'r','linew',2)
plot(t,filtsig,'k')
set(gca,'xlim',t([1 end]))

xlabel('Time (a.u.)'), ylabel('Amplitude')
legend({'Original';'Polynomial fit';'Filtered'})
```

---

### **Detailed Line-by-Line Explanation**

#### **1. Fit the Best Polynomial**

```matlab
polycoefs = polyfit(t,signal,orders(idx));
```

* **What it does:**
  Fits a polynomial of optimal order (found in previous step) to the data, returns its coefficients as `polycoefs`.
* **Why:**
  To obtain the best trend estimate to subtract.

---

#### **2. Evaluate the Polynomial at All Time Points**

```matlab
yHat = polyval(polycoefs,t);
```

* **What it does:**
  Calculates the trend values at each time point using the optimal polynomial.
* **Why:**
  To know the value of the fitted trend at each sample.

---

#### **3. Compute the Detrended (Filtered) Signal**

```matlab
filtsig = signal - yHat;
```

* **What it does:**
  Subtracts the fitted trend from the original signal to get the “detrended” or “filtered” signal, stored in `filtsig`.
* **Why:**
  Removes the slow-varying artifact, leaving only the interesting (fast) part.

---

#### **4. Plotting the Result**

```matlab
figure(5), clf, hold on
h = plot(t,signal);
set(h,'color',[1 1 1]*.6)
plot(t,yHat,'r','linew',2)
plot(t,filtsig,'k')
set(gca,'xlim',t([1 end]))

xlabel('Time (a.u.)'), ylabel('Amplitude')
legend({'Original';'Polynomial fit';'Filtered'})
```

* **What it does:**

  * `figure(5), clf, hold on`: Opens new figure, clears it, allows overplotting.
  * `plot(t,signal)`: Plots the original signal.
  * `set(h,'color',[1 1 1]*.6)`: Sets the color of the original signal to a light gray.
  * `plot(t,yHat,'r','linew',2)`: Plots the polynomial fit in red with a thick line.
  * `plot(t,filtsig,'k')`: Plots the filtered (detrended) signal in black.
  * `set(gca,'xlim',t([1 end]))`: Sets the x-axis to the full time range.
  * Adds labels and a legend.
* **Why:**
  So you can visually confirm that the trend has been properly removed.


---

## Summary Table

| Step                | What it Does                 | Key Function         | Output           |
| ------------------- | ---------------------------- | -------------------- | ---------------- |
| Generate Polynomial | Shows different polynomials  | `polyfit`, `polyval` | Random curve     |
| Simulate Signal     | Noisy signal with slow drift | `interp1`, `randn`   | Realistic signal |
| Fit Polynomial      | Removes slow trend           | `polyfit`, `polyval` | Detrended signal |
| Find Best Order     | Picks best polynomial order  | BIC calculation      | Optimal fit      |
| Detrend Signal      | Removes optimal trend        | Subtraction          | Cleaned signal   |

---

## When to Use Polynomial Detrending?

* When your data has slow, smooth trends (not sudden jumps).
* Before spectral analysis, event detection, or ML, to remove artifacts.
* Not for step-like artifacts (use median filter or other).

---

## MATLAB Built-in Function for Simple Detrending

For **linear detrending** (order 1), you can use:

```matlab
detrended = detrend(signal);
```

This just removes a straight-line trend.

---

## End-to-End Example: Detrending a Realistic Signal

```matlab
n = 1000;
t = (1:n)';
signal = 2*t.^2 - 0.5*t + 10 + randn(n,1)*20; % Quadratic trend + noise

% Fit and subtract 2nd order polynomial
p = polyfit(t,signal,2);
trend = polyval(p,t);
detrended = signal - trend;

figure; hold on;
plot(t,signal,'b')
plot(t,trend,'r','LineWidth',2)
plot(t,detrended,'k')
legend('Original','Trend','Detrended')
xlabel('Time'), ylabel('Amplitude')
title('Polynomial Detrending Example')
```

* Try running this to see a quadratic drift being removed!

---

## Key Functions Summary

* `polyfit(x,y,n)`: Finds polynomial coefficients of order n that fit data (x, y).
* `polyval(p,x)`: Evaluates polynomial with coefficients p at points x.
* `detrend(y)`: Removes linear trend (MATLAB built-in).

---

### If you have any confusion, or want to see a specific part in even more detail, just ask!

