# Homelab Agent
**Thibaud FRICHET, 2026**

🏠 Self-hosted LLM infrastructure running locally on a dual RTX 3060 workstation, fully offline.

This repository documents a privacy-first, reproducible stack for on-premise inference, designed to keep all prompts and data on the machine.

It consolidates the Ollama service configuration, a catalog of custom Modelfiles (naming scheme, context sizes, quantizations), a benchmark matrix with VRAM footprint and throughput measurements, and curated notes on hardware and inference behavior to support informed model selection per workload.

## 🧩 Stack
- **LLM server** — [Ollama](https://ollama.com/)
- **Coding CLI** — [opencode](https://opencode.ai/)
  - Plugin: [oc-tps](https://github.com/Tarquinen/oc-tps) (tokens/s counter)
  - Tools disabled in `~/.config/opencode/opencode.json` to reduce system-prompt footprint: `skill`, `todowrite`, `question`, `invalid`
  - Example configuration file: [opencode.example.json](opencode.example.json)
  - Permissions: All commands and modifications require authorization, except for reads (read, glob, ls, etc.). Security first.

## 📁 Contents
- [TESTS.md](TESTS.md) — benchmark scenarios and per-model observations
- [opencode.example.json](opencode.example.json) — example opencode configuration file with security permissions
- `models/*.Modelfile` — build files for custom models (naming scheme, context sizes, quantizations)
- `utils/sync_opencode_ollama.sh` — synchronizes Ollama models into the opencode configuration (run after any model addition or removal)

## 🧪 Tests Summary

Benchmarks cover code comprehension and code authoring scenarios. Full matrix and per-model observations are available in [TESTS.md](TESTS.md).

| Role | Model |
|---|---|
| Daily driver | `qwen3-coder-30b-a3b-q4_k_m-32k` |
| Heavy tasks (fallback) | `qwen3.6-27b-q4_k_m-20k` |
| Occasional / reference | `qwen3.5-9b-q8_0-64k`, `gpt-oss-20b`, `gemma4-26b` |

## 💻 Hardware
| Component | Details |
|---|---|
| CPU | AMD Ryzen 5 5600X (6c/12t) |
| RAM | 32 GB |
| GPU 0 | NVIDIA RTX 3060 12 GB (compute 8.6) — compute |
| GPU 1 | NVIDIA RTX 3060 12 GB (compute 8.6) — display |

## ⚙️ Ollama Configuration

File: `/etc/systemd/system/ollama.service.d/override.conf`

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_FLASH_ATTENTION=1"     # accelerates attention on long contexts
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"    # quantized KV cache (~2x VRAM reduction)
Environment="OLLAMA_NUM_PARALLEL=1"        # dedicates all resources to a single request
Environment="OLLAMA_MAX_LOADED_MODELS=1"   # keeps a single model resident in VRAM
```

## 📊 VRAM Budget

Dual GPU (2× 12 GB = 24 GB total). GPU 1 drives the display (~600 MB reserved), leaving ~11.4 GB usable.

```
Q4_K_M 70B model  : ~39 GB  → exceeds VRAM, spills to RAM
Q4_K_M 32B model  : ~19 GB  → fits across both GPUs
Q8_0 8B model     : ~8.9 GB → fits on a single GPU

Effective budget  : ~23.4 GB usable (12 GB GPU 0 + 11.4 GB GPU 1)
```

## 🏷️ Custom Models

### Naming convention

Format: `{base}-{variant}-{quant}-{ctx}`

- **base** — model family (e.g. `qwen3`, `gemma4`, `llama4`)
- **variant** — size or specific variant (e.g. `8b`, `27b`, `e4b`, `30b-a3b`)
- **quant** — exact quantization, llama.cpp format (e.g. `q4_k_m`, `q6_k`, `q8_0`)
- **ctx** — context window (e.g. `16k`, `32k`, `128k`)

### Build

```bash
ollama create qwen3.5-9b-q8_0-64k -f models/qwen3.5-9b-q8_0-64k.Modelfile
```

## 📚 Technical Concepts

Concise glossary of the terminology used throughout the configurations and benchmarks.

- **Token** — approximately ¾ of a word (FR/EN). A 32k context ≈ 25k words; tool-use loops consume it rapidly.
- **Context (`num_ctx`)** — maximum number of tokens processed in a single pass (prompt + history + response). Larger contexts proportionally increase KV cache VRAM usage.
- **Sampling** — `temperature` (randomness), `top_k` / `top_p` (candidate cutoff), `repeat_penalty`. Tool use favors low values (`T=0.3`, `top_k=20`); creative workloads favor higher (`T=0.7–1.0`, `top_k=40–64`).
- **Precision** — `fp16` / `bf16` serve as training and inference baselines; `int8` / `int4` are used for quantized inference.
- **Quantization** — compresses model weights to fit within VRAM. llama.cpp suffixes: `_0` uniform, `_K_S` / `_K_M` / `_K_L` k-quant variants, `IQ2–IQ4` importance-weighted. `Q4_K_M` is the standard sweet spot; `Q8_0` approaches fp16 quality at half the footprint.
- **Inference** — two phases: prefill (parallelized, fast) and decode (sequential, the bottleneck). Decode throughput is bound by VRAM **bandwidth**, not raw compute.
- **KV cache** — stores K/V vectors per token to avoid recomputation. Scales with context × model size, and is independently quantizable (`q8_0` halves the footprint with negligible quality impact).
- **Flash Attention** — computes attention in on-chip SRAM blocks rather than round-tripping to VRAM. Yields faster execution and reduced memory usage; enabled globally.
- **MoE (Mixture of Experts)** — architecture with many expert subnetworks, only a subset active per token (e.g. Qwen3-30B-A3B: 30B total, 3B active). Delivers fast decode and compact KV, but the full weight set must still reside in VRAM.
- **Layer offloading / CPU spillover** — Ollama populates GPUs layer by layer; overflow executes on CPU and significantly degrades decode speed (PCIe ~11× slower than VRAM, DDR4 ~7×). Rule of thumb: ~1% slowdown per spilled layer. Inspect `ollama ps` → `PROCESSOR` column; target `100% GPU` for latency-sensitive workloads.
