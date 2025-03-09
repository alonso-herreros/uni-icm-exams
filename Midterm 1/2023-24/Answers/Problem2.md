## Question 2.1

In order for the operation to be implemented using integers and divisions by
powers of two, and with 8-bit unsigned coefficients, we can follow these steps

1. Find the largest unsigned integer that fits in 8 bits: $2⁸ - 1 = 255$

1. Find the largest scaling factor:

    $$
    k = \left\lfloor \log_2\frac{256}{0.65} \right\rfloor
        = \left\lfloor \log_2 393.8 \right\rfloor
        = \left\lfloor 8.62 \right\rfloor
        = 8
    $$

    So the scaling factor is $K = 2^k = 256$

1. Scale the coefficients up and round to the nearest integer

    $$
    L₀ = \operatorname{round} (l₀ ⋅ K) = \operatorname{round}(0.65 * 256)
        = \operatorname{round}(166.4) = 166 \\
    L₁ = \operatorname{round} (l₁ ⋅ K) = \operatorname{round}(0.39 * 256)
        = \operatorname{round}(99.84) = 100
    $$

1. De-scale the output by dividing by the same scaling coefficient. The final
   formula would look like this:

$$
A' = \frac{1}{2WK} \sum_{i=0}^{W-1} (L₀ cnt_{i+1} + L₁ cntᵢ)²
$$

## Question 2.2

In order to find the number of bits needed to store the result (after proper
de-scaling), we must find an upper bound for $A'$.

Since the input data $cnt$ is an 8-bit unsigned value, its maximum value is 255.

The maximum value for $A'$ is

$$
\begin{aligned}
    \max A' &= \max \frac{1}{2WK} \sum_{i=0}^{W-1} (L₀ cnt_{i+1} + L₁ cntᵢ)² \\
    &= \frac{1}{2WK} \sum_{i=0}^{W-1} (L₀ \max cnt_{i+1} + L₁ \max cntᵢ)² \\
    &= \frac{1}{2W⋅256} \sum_{i=0}^{W-1} (166⋅ 255 + 100⋅ 255)² \\
    &= \frac{W}{512⋅W}⋅4600908900 \\
    &= \frac{4600908900}{512} \\
    &= 8986150.2 \\
\end{aligned}
$$

from which we can obtain the maximum number of bits needed to store it:

$$
size(A') = \left\lceil \log_2 8986150.2 \right\rceil
    = \left\lceil 23.1 \right\rceil
    = 24
$$

So, we'd need 24 bits to store the result.

## Question 2.3

![alt](question2.3.drawio.svg)
