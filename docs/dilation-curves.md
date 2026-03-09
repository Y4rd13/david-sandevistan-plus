# Time Dilation Curves — Technical Reference

How the Sandevistan's time dilation degrades as runtime depletes, per cyberpsychosis stage.

## Concepts

- **timeScale** — Engine value where `0.10` = 90% dilation (world runs at 10% speed), `0.0065` = 99.35%
- **Dilation %** — `(1 - timeScale) * 100`. Higher = faster Sandy = more strain on V
- **maxTS** — timeScale at full runtime (peak dilation)
- **minTS** — timeScale at zero runtime (degraded dilation)
- **rtRatio** — `runTime / MaxRunTime` (1.0 = full, 0.0 = empty)
- **exp** — Curve exponent. Higher = dilation drops faster from peak

## Formula

```
timeScale = minTS + (maxTS - minTS) * rtRatio^exp
```

- `exp = 1.0` — Linear (constant degradation rate)
- `exp > 1.0` — Concave (fast drop from peak, slow approach to minimum)
- Higher psycho stage → higher exponent → shorter time at peak dilation

## Stage Parameters

| Stage | Name | maxTS | minTS | Dilation Range | exp | Character |
|-------|------|-------|-------|----------------|-----|-----------|
| 0 | Normal | 0.10 | — | 90% (fixed) | — | Base config value, no curve |
| 1 | Unstable | 0.075 | 0.10 | 92.5% → 90% | 1.5 | Subtle, almost linear |
| 2 | Glitching | 0.065 | 0.10 | 93.5% → 90% | 1.8 | Slight acceleration |
| 3 | Losing It | 0.05 | 0.10 | 95% → 90% | 2.0 | Quadratic — noticeable drop |
| 4 | On The Edge | 0.035 | 0.13 | 96.5% → 87% | 2.3 | Aggressive — peak fades fast |
| 5 | Cyberpsycho | 0.025 | 0.15 | 97.5% → 85% | 2.8 | Very aggressive — brief peak |
| 6 | Last Breath | special | 0.10 | 99.35% → 90% | ~2.5 | Multi-phase (see below) |

## Curve Visualizations

### Stage 1 (exp=1.5) — 92.5% → 90%

Small range, nearly linear. V barely notices the degradation.

```
RT%  Dilation
100  ████████████████ 92.5%
 90  ███████████████▌ 92.1%
 80  ██████████████▊  91.8%
 70  █████████████▊   91.3%
 60  ████████████▋    90.9%
 50  ███████████▍     90.4%
 40  █████████▊       89.9%  ← crosses below 90% (minTS territory)
 30  ████████         89.3%
 20  ██████           88.7%
 10  ███▌             87.9%
  0  █████████████    90.0%
```

### Stage 2 (exp=1.8) — 93.5% → 90%

```
RT%  Dilation
100  █████████████████ 93.5%
 90  ████████████████  92.9%
 80  ██████████████▊   92.2%
 70  █████████████▌    91.6%
 60  ████████████      91.0%
 50  ██████████▌       90.4%
 40  █████████         90.0%  ← reaches minTS earlier than linear
 30  ███████▌          89.6%
 20  ██████            89.3%
 10  ████              89.0%
  0  █████████████     90.0%
```

### Stage 3 (exp=2.0) — 95% → 90%

Quadratic curve. Peak dilation (95%) only lasts while runtime is above ~80%.

```
RT%  Dilation
100  ██████████████████ 95.0%
 90  ████████████████▌  94.0%
 80  ██████████████▊    93.2%
 70  █████████████      92.5%
 60  ███████████▌       91.8%
 50  █████████▊         91.3%
 40  ████████           90.8%
 30  ██████▌            90.5%
 20  █████              90.2%
 10  ████               90.1%
  0  █████████████      90.0%
```

### Stage 4 (exp=2.3) — 96.5% → 87%

Aggressive drop. V's body is struggling — the peak fades quickly.

```
RT%  Dilation
100  ████████████████████ 96.5%
 90  █████████████████▌   95.0%
 80  ███████████████▊     93.5%
 70  █████████████▌       92.0%
 60  ███████████▌         90.7%
 50  █████████▊           89.6%
 40  ████████             88.7%
 30  ██████▌              88.0%
 20  █████                87.5%
 10  ████                 87.2%
  0  ██████████████       87.0%
```

### Stage 5 (exp=2.8) — 97.5% → 85%

V's body is failing. The 97.5% peak is barely a flash — by 70% runtime, dilation is already near 89%.

```
RT%  Dilation
100  ██████████████████████ 97.5%
 90  █████████████████▌    94.4%
 80  ██████████████▊       91.4%
 70  ████████████▌         89.0%
 60  ██████████▌           87.1%
 50  █████████             85.8%
 40  ████████              85.3%
 30  ███████▌              85.1%
 20  ███████               85.0%
 10  ██████▊               85.0%
  0  ██████▊               85.0%
```

## Stage 6 — Last Breath (Multi-Phase)

Last Breath uses a time-based curve (elapsed seconds), not runtime ratio. This represents David's final moment — a brief spike of perfect clarity before the inevitable collapse.

### Phase Timeline

```
Tiempo →  0s      3s  5s      10s     15s     20s                          ~120s
          │       │   │       │       │       │                              │
 99.35% ─ │       │   │    ╱──┼───────┤╲                                    │
          │       │   │   ╱   │       │  ╲                                  │
 97.5%  ─ │       │   │  ╱    │       │    ╲                                │
          │       │   │ ╱     │       │      ╲╲                             │
 93.5%  ─ │       │   │╱      │       │         ╲╲╲                         │
 92.5%  ─ │       │  ╱│       │       │             ╲╲╲╲                    │
          │       │╱  │       │       │                 ╲╲╲╲╲╲╲╲            │
 90%    ─ ├───────┤───┤───────┤───────┤─────────────────────────╲╲╲╲────────┤
          │       │   │       │       │                              ▼      │
          │ wait  │ramp up   │ 99.35 │  decay (exp ~2.5)          90%     │
          │(song  │ 5s       │ peak  │  fast drop from peak                │
          │ @3s)  │          │ 10s   │  slow approach to 90%               │
          │       │          │ max   │                                     │
```

### Phase Details

| Phase | Time | Dilation | Description |
|-------|------|----------|-------------|
| **Wait** | 0–5s | 90% (base) | V revives. Song starts at 3s. No Sandy yet |
| **Ramp** | 5–10s | 90% → 99.35% | Sandy activates, dilation climbs to peak |
| **Peak** | 10–20s | 99.35% | Maximum clarity — David's perfect moment |
| **Decay** | 20s+ | 99.35% → 90% | Exponential decay (exp ~2.5), fast initial drop |
| **Death** | runtime=0 | ~90% | "THE MOON... I CAN SEE IT" → FLATLINED |

### Decay Phase Formula

```
elapsed = time since decay started
decayDuration = total remaining runtime at decay start
progress = elapsed / decayDuration
timeScale = 0.10 + (0.0065 - 0.10) * (1 - progress)^2.5
```

The `(1 - progress)^2.5` creates the exponential decay: dilation drops quickly from 99.35% in the first seconds, then slows as it approaches 90% — V's last sensation fading gradually.

### Dilation Milestones During Decay

```
Progress  Dilation  Feeling
   0%     99.35%    Perfect clarity — time nearly frozen
  10%     97.1%     Still extraordinary — barely noticeable drop
  20%     93.8%     World starting to speed up
  30%     91.2%     Significant loss — V feels it slipping
  50%     88.2%     Half the range gone — approaching baseline
  70%     87.1%     Almost at floor — crawling toward 90%
  90%     86.2%     Near-baseline — the end is close
 100%     90.0%     Baseline — runtime depleted → death
```

## Lore Context

The curve design follows David Martinez's arc in Edgerunners:

- **Stages 1–3**: The Sandy works well. Degradation is subtle — David barely feels it
- **Stage 4**: The body fights back. Peak performance fades quickly, like David's nosebleeds
- **Stage 5**: V's body is failing. The 97.5% flash is David pushing through despite everything
- **Stage 6**: The final stand. A moment of perfect clarity (99.35%) that can't last — the exponential decay mirrors David's consciousness fading in Episode 10
