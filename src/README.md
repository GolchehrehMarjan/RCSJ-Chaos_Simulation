# Project 14 — Josephson Junction: Periodic-to-Chaotic Transition (RCSJ Model)

Computational Physics course — chaos category project.

## Files

| File | Purpose |
|---|---|
| `RCSJ.m` | **Core model** (single source of truth): right-hand side of the driven, damped RCSJ (pendulum) equation φ'' + βφ' + sinφ = I_dc + I_ac·cos(Ωt), written as a first-order 2D system. Every other script calls this. |
| `RCSJ_variational.m` | Linearized (tangent-space) version of `RCSJ.m` — propagates a small perturbation (δφ, δφ̇) alongside the trajectory. Needed only for the Lyapunov-exponent calculation. |
| `lyapunov_exponent.m` | Computes the largest Lyapunov exponent with the Benettin algorithm: integrates one drive period at a time, renormalizes the perturbation vector back to size `d0`, and averages the log growth rate over `n_periods` after discarding an initial transient (`discard` periods). |
| `RCSJmain.m` | **Main script.** Runs everything sequentially and produces all required outputs: phase portrait, I–V curve (Shapiro steps), Poincaré section, bifurcation diagram, 1D Lyapunov sweep, and the bonus 2D (I_dc–I_ac) regime map. Generates every figure, but the regime map at the end makes the full run slow. |
| `OptimizedRCSJmain.m` | Identical pipeline to `RCSJmain.m`, except the 2D regime map — by far the most expensive part — is parallelized with `parfor` across all available workers (Parallel Computing Toolbox), which cuts the total run time noticeably. Nothing else in the script is changed. |

## How to run

```matlab
RCSJmain.m            % full serial run — reproduces every figure
OptimizedRCSJmain.m   % same outputs, faster regime map (requires Parallel Computing Toolbox)
```

Both scripts are organized in `%%` cells, so each part (phase portrait, I–V curve, Poincaré section, bifurcation diagram, Lyapunov sweep, regime map) can also be run independently.

## Model

```
φ'' + β·φ' + sin(φ) = I_dc + I_ac·cos(Ω t)
⟨V⟩ = ⟨φ̇⟩
```

Default parameters: β = 0.5, I_dc = 0.740, I_ac = 2.550, Ω = 0.5 (overridden locally within each sweep/section).

## Outputs (mapped to the project requirements)

1. Phase portrait (φ, φ̇) and its mod-2π projection — phase difference and phase velocity
2. I–V curve (⟨V⟩ vs. I_dc) — Shapiro steps
3. Poincaré section
4. Bifurcation diagram vs. I_dc
5. Largest Lyapunov exponent vs. I_dc — separates periodic from chaotic regimes
6. **Bonus:** 2D Lyapunov regime map over (I_dc, I_ac), with the zero-crossing contour marking the periodic/chaotic boundary

## Why two main scripts

`RCSJmain.m` is the reference, fully serial version — simplest to read and verify. The 2D regime map alone requires `length(Idc_grid) × length(Iac_grid) × n_periods` independent ODE integrations, which dominates the total run time. `OptimizedRCSJmain.m` parallelizes exactly that part:

- The (I_ac, I_dc) grid is flattened into a single `parfor` loop (instead of nesting `parfor` inside a serial outer loop), so all workers stay evenly loaded regardless of grid shape.
- It checks for an already-running pool with `gcp('nocreate')` before opening a new one, and closes the pool with `delete(gcp)` once the grid is done.

Everything upstream of the regime map (phase portrait, I–V curve, Poincaré section, bifurcation diagram, 1D Lyapunov sweep) is untouched between the two scripts.
