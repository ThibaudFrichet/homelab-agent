# Ollama — Custom Models

## Naming Convention

```
{base}-{variant}-{quant}-{ctx}[-{tag}]:{Vxx.YYYY-MM-DD}
```

| Field | Description | Examples |
|---|---|---|
| `base` | Model family | `qwen3`, `gemma4`, `llama4` |
| `variant` | Size or specific variant | `8b`, `27b`, `e4b`, `30b-a3b` |
| `quant` | Exact quantization (llama.cpp format) | `q4_k_m`, `q6_k`, `q8_0` |
| `ctx` | Context window | `16k`, `32k`, `128k` |
| `tag` | **Actual use** (optional, not model capabilities) | `tools`, `code`, `think` |
| version | Ollama tag: version + creation date | `V01.2026-04-14` |

### Examples

```
qwen3-8b-q4_k_m-32k:V01.2026-04-14
qwen3-8b-q8_0-32k-tools:V01.2026-04-14
gemma4-e4b-q4_k_m-16k-tools:V01.2026-04-14
```

To update an existing model, increment `Vxx`: `V02.2026-05-01`.

## Files

Each model has its own `{model-name}.Modelfile` in the `models/` directory.  
The Modelfile contains only overrides (FROM + PARAMETER) — no template or license.

## opencode

After adding a model or changing its `num_ctx`, set the same `limit.context` in [opencode/opencode.jsonc](opencode/opencode.jsonc).

## Useful Commands

```bash
# Build a model from its Modelfile
ollama create qwen3-8b-q8_0-32k-tools:V01.2026-04-14 -f models/qwen3-8b-q8_0-32k-tools.Modelfile

# Copy / rename
ollama cp old-name:tag new-name:tag

# Delete
ollama rm name:tag

# Running models
ollama ps
```
