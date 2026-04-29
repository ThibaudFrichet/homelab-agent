# Test Results

## Summary

| Role | Model |
|---|---|
| Daily driver | `qwen3-coder-30b-a3b-q4_k_m-32k` |
| Heavy tasks (fallback) | `qwen3.6-27b-q4_k_m-20k` |
| Occasional / reference | `qwen3.5-9b-q8_0-64k`, `gpt-oss-20b`, `gemma4-26b` |
| Superseded / also tested | `qwen3.5-27b`, `qwen3.6-35b-a3b` |

## Models

### Daily driver — `qwen3-coder-30b-a3b-q4_k_m-32k`

- **VRAM fit** : 🟢 20 GB GPU, 100% GPU
- **Speed (code reading)** : 🟢 30 tk/s
- **Code — reading** : 🟢 **OK** (very good results)
- **Code — writing** : 🟢 **OK** (good results)
- **Code — CURL HA** : 🟢 **OK** (good results)

### Heavy tasks (fallback) — `qwen3.6-27b-q4_k_m-20k`

- **VRAM fit** : 🔴 12%/88% CPU/GPU
- **Speed (code reading)** : 🔴 5 tk/s
- **Code — reading** : 🟢 **OK** (very good results, but slow)
- **Code — writing** : 🟢 **OK** (good results)
- **Code — CURL HA** : 🟢 **OK** (good results)

### Occasional / reference

#### `qwen3.5-9b-q8_0-64k`

- **VRAM fit** : 🟢 16G GPU
- **Speed (code reading)** : 🟢 30 tk/s
- **Code — reading** : 🟢 **OK**
- **Code — writing** : 🟢 **OK**
- **Code — CURL HA** : 🟢 **OK**

#### `gpt-oss-20b-mxfp4-48k`

- **VRAM fit** : 🟢 15G GPU
- **Speed (code reading)** : not measured
- **Code — reading** : 🟢 **OK** (good results)
- **Code — writing** : 🟠 **Medium** (good results but slow)
- **Code — CURL HA** : 🟠 **Medium** (can call HA and read data with some guidance)

#### `gemma4-26b-a4b-q4_k_m-20k`

- **VRAM fit** : 🟢 20G GPU
- **Speed (code reading)** : 🟢 20 tk/s
- **Code — reading** : 🟢 **OK** (excellent results)
- **Code — writing** : 🟢 **OK** (good and fast)
- **Code — CURL HA** : 🔴 **KO** (cannot perform the call)

### Superseded / also tested

#### `qwen3.5-27b-q4_k_m-20k` — superseded by `qwen3.6-27b`

- **VRAM fit** : 🔴 12-24%/76-88% CPU/GPU
- **Speed (code reading)** : 🔴 2 tk/s
- **Code — reading** : not tested
- **Code — writing** : not tested
- **Code — CURL HA** : 🟢 **OK**

#### `qwen3.6-35b-a3b-q4_k_m-32k`

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
