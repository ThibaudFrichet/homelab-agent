# Test Results

## Current campaign (2026-11, opencode 2.3.2, Ollama 0.34.4)

| Model | ctx | Role | HA agentic test |
|---|---|---|---|
| `gpt-oss-20b-mxfp4-128k` | 128k | Daily driver, fast | 🟠 OK with a hint · 61 tk/s |
| `qwen3.8-27b-q4_k_m-48k` | 48k | Heavy and agentic tasks | 🟢 OK · 15 tk/s |
| `qwen3-coder-30b-a3b-q4_k_m-32k` | 32k | Code (to confirm) | 🔴 KO · 64 tk/s |
| `gemma4-12b-q8_0-128k` | 128k | No clear role | 🔴 KO · 20 tk/s |

HA agentic test: answer three questions (current value, yesterday's history, lights on) by exploring the Home Assistant REST API alone.

### VRAM by context

Load only, KV cache q8_0, flash attention on.

| Model | Native max | Largest 100% GPU context | VRAM there | Notes |
|---|---|---|---|---|
| `gemma4-12b-q8_0` | 256k | 256k | 16.4 GB | 14.8 GB at 64k and 128k (sliding window) |
| `qwen3.5-9b-q8_0` | 256k | 256k | 17.8 GB | 11.2 GB at 64k, 13.4 GB at 128k |
| `gpt-oss-20b-mxfp4` | 128k | 128k | 14.4 GB | 13.9 GB at 48k |
| `gemma4-26b-a4b-qat-q4_0` | 256k | 32k | 16.0 GB | 48k: 5% CPU |
| `qwen3-coder-30b-a3b-q4_k_m` | 256k | 32k | 20.6 GB | 48k: 2% CPU |
| `qwen3.6-27b-q4_k_m` | 256k | none | — | 6% CPU from 8k to 32k, 7% at 48k, 11% at 64k, 16% at 96k, 22% at 128k |
| `qwen3.8-27b-q4_k_m` | 256k | none | — | 6% CPU from 12k to 48k, 10% at 64k, 17% at 96k, 22% at 128k; load at 8k crashed (llama-server segfault) |

## Previous campaign (opencode v1)

### Summary

| Role | Model |
|---|---|
| Daily driver | `qwen3-coder-30b-a3b-q4_k_m-32k` |
| Heavy tasks (fallback) | `qwen3.6-27b-q4_k_m-20k` |
| Occasional / reference | `qwen3.5-9b-q8_0-64k`, `gpt-oss-20b`, `gemma4-26b` |
| Superseded / also tested | `qwen3.5-27b`, `qwen3.6-35b-a3b` |

### Models

#### Daily driver — `qwen3-coder-30b-a3b-q4_k_m-32k`

- **VRAM fit** : 🟢 20 GB GPU, 100% GPU
- **Speed (code reading)** : 🟢 30 tk/s
- **Code — reading** : 🟢 **OK** (very good results)
- **Code — writing** : 🟢 **OK** (good results)
- **Code — CURL HA** : 🟢 **OK** (good results)

#### Heavy tasks (fallback) — `qwen3.6-27b-q4_k_m-20k`

- **VRAM fit** : 🔴 12%/88% CPU/GPU
- **Speed (code reading)** : 🔴 5 tk/s
- **Code — reading** : 🟢 **OK** (very good results, but slow)
- **Code — writing** : 🟢 **OK** (good results)
- **Code — CURL HA** : 🟢 **OK** (good results)

#### Occasional / reference

##### `qwen3.5-9b-q8_0-64k`

- **VRAM fit** : 🟢 16G GPU
- **Speed (code reading)** : 🟢 30 tk/s
- **Code — reading** : 🟢 **OK**
- **Code — writing** : 🟢 **OK**
- **Code — CURL HA** : 🟢 **OK**

##### `gpt-oss-20b-mxfp4-48k`

- **VRAM fit** : 🟢 15G GPU
- **Speed (code reading)** : not measured
- **Code — reading** : 🟢 **OK** (good results)
- **Code — writing** : 🟠 **Medium** (good results but slow)
- **Code — CURL HA** : 🟠 **Medium** (can call HA and read data with some guidance)

##### `gemma4-26b-a4b-q4_k_m-20k`

- **VRAM fit** : 🟢 20G GPU
- **Speed (code reading)** : 🟢 20 tk/s
- **Code — reading** : 🟢 **OK** (excellent results)
- **Code — writing** : 🟢 **OK** (good and fast)
- **Code — CURL HA** : 🔴 **KO** (cannot perform the call)

#### Superseded / also tested

##### `qwen3.5-27b-q4_k_m-20k` — superseded by `qwen3.6-27b`

- **VRAM fit** : 🔴 12-24%/76-88% CPU/GPU
- **Speed (code reading)** : 🔴 2 tk/s
- **Code — reading** : not tested
- **Code — writing** : not tested
- **Code — CURL HA** : 🟢 **OK**

##### `qwen3.6-35b-a3b-q4_k_m-32k`

- **VRAM fit** : not measured
- **Speed (code reading)** : 🔴 3 tk/s
- **Code — reading** : 🟢 **OK** (very good results, but slow)
- **Code — writing** : not tested
- **Code — CURL HA** : not tested

## Test Scenarios

### 1. Code — code reading
- Prompt 1 : "Décris la stack du projet"
- Prompt 2 : "Liste les patterns et les modèles métiers"

### 2. Code — code writing
- Prompt 1 : "Refactoring de fichier"

### 3. Code — CURL HomeAssistant
- Prompt 1 : "Appelle mon instance HomeAssistant via CURL"
