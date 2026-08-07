# Chaos in the RCSJ Josephson Junction Model

Numerical simulation of a current-driven Josephson junction under the **Resistively and Capacitively Shunted Junction (RCSJ)** model, exploring the transition from phase-locked periodic dynamics to deterministic chaos under combined DC + AC current drive.

![MATLAB](https://img.shields.io/badge/MATLAB-R2022%2B-orange)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![Topic](https://img.shields.io/badge/topic-nonlinear%20dynamics%20%7C%20chaos-blue)

---

## Overview

A Josephson junction — two superconductors separated by a thin insulating barrier — is mathematically equivalent to a **driven, damped pendulum**. This project numerically solves the normalized RCSJ equation of motion for the superconducting phase difference φ(t):

```math
\beta\,\ddot{\phi} + \dot{\phi} + \sin\phi = I_{dc} + I_{ac}\cos(\Omega t)
```

where:

| Symbol | Meaning |
|---|---|
| φ(t) | Superconducting phase difference across the junction |
| β | McCumber damping parameter (capacitive damping) |
| I_dc | Applied DC bias current |
| I_ac, Ω | Amplitude and angular frequency of the AC drive |
| ⟨V⟩ = ⟨φ̇⟩ | Average voltage across the junction (2nd Josephson relation) |

The goal is to characterize how the junction's dynamics evolve from **superconducting / phase-locked** behavior, through **Shapiro steps**, into **quasi-periodic and chaotic** regimes as the drive parameters change — and to confirm chaos quantitatively (not just visually) using multiple independent diagnostics.

## Methods

- Equation of motion reduced to a first-order system (x₁ = φ, x₂ = φ̇) and integrated with MATLAB's `ode45` (tight tolerances, RelTol = 1e-10 / AbsTol = 1e-12 for reference trajectories).
- Transients discarded before extracting steady-state observables.
- **Largest Lyapunov exponent** λ_max computed via the two-trajectory divergence method (initial separation d₀ = 1e-6, periodic renormalization every 500 drive periods).
- **Poincaré sections** built by stroboscopic sampling at t_n = nT, T = 2π/Ω.
- Parameter sweeps (I_dc, and the 2D (I_dc, I_ac) regime map) parallelized with `parfor` / `parpool`, cutting a ~1044-point 2D grid from serial runtime down to **1.8 minutes**.

## Results

### 1. Phase portrait
At (I_dc, I_ac, Ω) = (0.740, 2.550, 0.5), the unwrapped phase grows with repeated 2π phase slips (nonzero average voltage — "running" state), while φ̇ oscillates irregularly in roughly [−3, 5.5]. Wrapped mod 2π, the trajectory fills a dense, tangled network rather than closing a simple loop — an early qualitative signature of chaos.

### 2. I–V curve and Shapiro steps
Sweeping I_dc ∈ [0, 1.4] at fixed I_ac = 2.550, Ω = 0.5 reveals four regimes:
- **I_dc ≲ 0.30** — superconducting branch, ⟨V⟩ ≈ 0 (phase-locked, no net voltage drop)
- **I_dc ≈ 0.30–0.60** — first Shapiro step at ⟨V⟩ ≈ 1.1 (frequency-locking to Ω)
- **I_dc ≈ 0.60–0.90** — the step breaks into a highly irregular, noisy curve — chaos disrupting phase-locking
- **I_dc ≈ 0.90–1.30** — second Shapiro step (⟨V⟩ ≈ 2.8), followed by a steeper linear branch

### 3. Poincaré section
At I_dc = 0.740, the stroboscopic Poincaré map (3000 transient periods discarded, 7000 points retained) does not converge to a finite set of points, but instead traces a continuous, folded, multi-branch structure — characteristic of a strange attractor's cross-section.

### 4. Bifurcation diagram
Sweeping I_dc ∈ [0.4, 1.2] shows a thin regular branch below I_dc ≈ 0.55, a thick chaotic band (with narrow periodic windows) for I_dc ≈ 0.57–0.90, and a return to a narrow regular branch above I_dc ≈ 0.90 — consistent with the second Shapiro step.

### 5. Largest Lyapunov exponent
λ_max > 0 (typically 0.08–0.12) across most of I_dc ∈ [0.55, 0.90], confirming genuine chaos. It dips sharply negative at a few isolated values (≈0.65, 0.75–0.76, 0.80–0.87), matching the periodic windows seen in the bifurcation diagram exactly — cross-validating the two independent methods.

### 6. Bonus: 2D dynamical regime map
λ_max computed over a (I_dc, I_ac) grid (36 × 29 ≈ 1044 points) reveals a banded, diagonal pattern of alternating regular/chaotic strips reminiscent of **Arnold tongues** in driven nonlinear oscillators. At larger I_ac these bands merge into a broad "chaos sea." Global extrema: λ_max ∈ [−0.250, 0.110], with the most chaotic point at (I_dc, I_ac) = (0.460, 2.300).

## Physical interpretation

The interplay of three mechanisms drives this behavior: the **sin φ nonlinearity** (restoring force), **damping** set by β, and **phase-locking** to the external AC drive. At low I_dc the phase is trapped in a washboard potential well (zero voltage). As I_dc increases, the phase runs, and Shapiro steps emerge from frequency-locking to Ω. In the intermediate I_dc range, competition between the drive's continuous energy injection and the system's nonlinearity destabilizes periodic orbits — confirmed independently by the bifurcation diagram, the breakdown of I–V steps, the Poincaré section's continuous structure, and positive λ_max. The narrow periodic windows within the chaotic band show this transition is not monotonic, but a continuous competition between periodic and chaotic attractors.

## Files

| File | Purpose |
|---|---|
| `RCSJ.m` | **Core model** (single source of truth): right-hand side of the driven, damped RCSJ (pendulum) equation φ'' + βφ' + sinφ = I_dc + I_ac·cos(Ωt), written as a first-order 2D system. Every other script calls this. |
| `RCSJ_variational.m` | Linearized (tangent-space) version of `RCSJ.m` — propagates a small perturbation (δφ, δφ̇) alongside the trajectory. Needed only for the Lyapunov-exponent calculation. |
| `lyapunov_exponent.m` | Computes the largest Lyapunov exponent with the Benettin algorithm: integrates one drive period at a time, renormalizes the perturbation vector back to size `d0`, and averages the log growth rate over `n_periods` after discarding an initial transient (`discard` periods). |
| `RCSJmain.m` | **Main script.** Runs everything sequentially and produces all required outputs: phase portrait, I–V curve (Shapiro steps), Poincaré section, bifurcation diagram, 1D Lyapunov sweep, and the bonus 2D (I_dc–I_ac) regime map. Generates every figure, but the regime map at the end makes the full run slow. |
| `OptimizedRCSJmain.m` | Identical pipeline to `RCSJmain.m`, except the 2D regime map — by far the most expensive part — is parallelized with `parfor` across all available workers (Parallel Computing Toolbox), which cuts the total run time noticeably. Nothing else in the script is changed. |

## Requirements

- MATLAB R2022a or later
- Parallel Computing Toolbox (only needed for `OptimizedRCSJmain.m`; `RCSJmain.m` runs without it)

## Usage

```matlab
RCSJmain.m            % full serial run — reproduces every figure
OptimizedRCSJmain.m   % same outputs, faster regime map (requires Parallel Computing Toolbox)
```

Both scripts are organized in `%%` cells, so each part (phase portrait, I–V curve, Poincaré section, bifurcation diagram, Lyapunov sweep, regime map) can also be run independently.

### Why two main scripts

`RCSJmain.m` is the reference, fully serial version — simplest to read and verify. The 2D regime map alone requires `length(Idc_grid) × length(Iac_grid) × n_periods` independent ODE integrations, which dominates the total run time. `OptimizedRCSJmain.m` parallelizes exactly that part:

- The (I_ac, I_dc) grid is flattened into a single `parfor` loop (instead of nesting `parfor` inside a serial outer loop), so all workers stay evenly loaded regardless of grid shape.
- It checks for an already-running pool with `gcp('nocreate')` before opening a new one, and closes the pool with `delete(gcp)` once the grid is done.

Everything upstream of the regime map (phase portrait, I–V curve, Poincaré section, bifurcation diagram, 1D Lyapunov sweep) is untouched between the two scripts.

## Future work

- Vary the McCumber parameter β to study the role of capacitive damping.
- Study dependence on drive frequency Ω and its effect on Arnold tongue boundaries.
- Compute the full Lyapunov spectrum and attractor fractal dimension.
- Compare against experimental Josephson junction I–V data.

## References

1. Barone, A. & Paternò, G. — *Physics and Applications of the Josephson Effect*
2. Strogatz, S. H. — *Nonlinear Dynamics and Chaos*
3. Kautz, R. L. — *Noise, chaos, and the Josephson voltage standard*
4. MATLAB documentation — `ode45`, Parallel Computing Toolbox

## Author

Marjan Golchehreh — M.Sc. Physics, Amirkabir University of Technology
Course: Computational Physics — Project category: Chaos
