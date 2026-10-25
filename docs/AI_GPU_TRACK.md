# Local AI and GPU infrastructure track

This is the continuation of [LEARNING_PATH.md](LEARNING_PATH.md) after DevOps, architecture and
the three-cloud comparison. It uses the independent public
[tx04v2 lab](https://github.com/maringelix/tx04v2). The hub provides sequence and acceptance;
tx04v2 owns its executable code, environment requirements and validation.

The scope is infrastructure for learning and operating AI workloads. It does not promise model
quality, production readiness or that every listed technology has an executable lesson today.
R12.2–R12.5 in [ROADMAP.md](../ROADMAP.md) track the missing delivery work.

## What exists today

| Surface | Available material | Evidence boundary |
|---|---|---|
| Basic local platform | Docker-only launchers, kind cluster and mock HTTP serving | The initial [Lab CI run](https://github.com/maringelix/tx04v2/actions/runs/40182267072) at `ff936c9c38c2652c331458b5fe1f0a6bb0ff28b3` passed toolbox build, kind startup, mock health/request/metrics and teardown |
| Static checks and observability rules | YAML/Kubernetes checks, shell/PowerShell syntax, launcher contract, secret scan, dashboard JSON/PromQL and GPU alert fixtures | Passing these checks does not demonstrate a physical GPU or every optional module at runtime |
| Simulated infrastructure modules | Fake GPU resources, Volcano, KWOK, mock serving/HPA examples, networking, dashboards and break/fix scenarios | Implementations and learning material exist; full guided exercise coverage and runtime gates remain **pending R12.3** |
| Real local CPU inference | [Optional vLLM reference](https://github.com/maringelix/tx04v2/tree/main/platform/30-serving/real-vllm) | Incomplete: the manifest uses a `latest` image and explicitly requires a suitable CPU-built image. This is not a ready or validated CPU inference lesson; **pending R12.2** |
| Physical GPU operation | [Hardware notes and sharing configuration](https://github.com/maringelix/tx04v2/tree/main/platform/10-gpu/real-hardware) | Reference material only; no validated hardware, CUDA, sharing or multi-GPU exercise is established here; **pending R12.4** |
| Integrated AI operations capstone | Acceptance defined below | Reproducible benchmark and operations exercise are **pending R12.5** |

Read tx04v2's [architecture](https://github.com/maringelix/tx04v2/blob/main/docs/architecture.md),
[bring-up guide](https://github.com/maringelix/tx04v2/blob/main/docs/bring-up.md) and
[harness](https://github.com/maringelix/tx04v2/blob/main/docs/HARNESS.md) before running its
available path. The mock returns a synthetic response: it does not load model weights or perform
model inference. KWOK nodes do not execute containers, and simulated GPU metrics are not hardware
performance measurements.

## 1. Real local inference on CPU — R12.2

**Prerequisites:** understand container resources, HTTP APIs, artifacts, monitoring and bounded
load from the cloud curriculum. Learn the distinction between a model, tokenizer, inference
runtime, weights, precision/quantization and context before interpreting performance.

The future lesson must deliver:

- A runtime and model with explicit versions/revisions, integrity checks, license information,
  supported host architectures and documented storage/RAM needs.
- A reproducible local API that generates real output, with readiness, request limits, timeout,
  resource bounds and a documented stop/cleanup procedure.
- A small synthetic request set and benchmark that records prompt/output sizes, concurrency,
  time to first token, completion latency, tokens per second and observed memory usage.
- A controlled rejected request or resource-boundary failure, with diagnosis and recovery.

**Checkpoint:** another learner can reproduce a successful generation and the bounded failure
from the recorded revisions. Compare measured runs using the same input and settings; do not
claim a universal model-quality or performance result. The current reference cannot satisfy this
checkpoint until its runtime/image selection and execution have been validated.

## 2. Simulated GPU infrastructure — R12.3

Use the available tx04v2 modules to learn the control plane without requiring a physical GPU.
The guided exercise pack should connect these topics in order:

1. **Resources and placement:** advertised GPU capacity, requests/limits, labels, taints,
   tolerations and scheduling events. Explain why a workload is pending before changing capacity.
2. **Queues and gang scheduling:** use the Volcano examples to compare a complete gang with
   insufficient resources; diagnose starvation or a blocked group and recover within the lab.
3. **Serving and capacity signals:** trace the mock request/metric path, then demonstrate the
   configured HPA/adapter behavior under bounded load. Separate pod scaling from node capacity.
4. **Fleet scale:** use KWOK to inspect scheduling at scale while recording that its nodes do not
   run workloads or establish data-plane throughput.
5. **Telemetry and incidents:** follow the GPU dashboard/rules and the image/disk, memory and
   DNS/conntrack scenarios. Record the signal, hypothesis, failure, recovery and teardown.

**Checkpoint:** a reproducible exercise report identifies the real Kubernetes behavior and the
simulated surface separately. Runtime gates must exercise the claimed module, not infer its
success from YAML validity or the basic mock smoke. Review moving upstream references and
resource limits before promoting optional modules into a reproducible guided path.

## 3. Physical GPUs and advanced infrastructure — R12.4

This is an optional hardware track. No purchase, cloud GPU allocation or change to a learner's
host is implied by this roadmap. Select an isolated supported environment only when the hardware
exercise is ready and its resource/cost window is approved.

The future pack must start with a compatibility inventory: host OS/architecture, GPU and memory,
driver, container runtime/toolkit, device plugin/operator, inference runtime and model. Pin the
tested combination and link the relevant vendor support documentation when implementing it.

Then teach and validate:

- The path from hardware and driver through the container runtime to Kubernetes allocation.
- GPU memory versus host memory, model/context/batch resource demands and controlled diagnosis of
  an inference allocation failure without exhausting the host.
- Sharing and isolation choices, including time-slicing, MPS and MIG where supported; record
  what was actually tested and what remains a design comparison.
- Real telemetry, utilization/saturation/error signals, storage/model loading, cold starts and
  the distinction between throughput and request latency.
- Multi-GPU placement, collective/network considerations and training versus inference
  requirements. Distributed execution needs a separate reproducible exercise and hardware evidence.

**Checkpoint:** provide the compatibility record, actual allocation and inference evidence,
bounded before/after measurements, diagnosis/recovery and cleanup. Do not substitute fake metrics,
configuration files or successful scheduling for proof of CUDA execution or hardware isolation.

## 4. AI infrastructure capstone and operations — R12.5

Design one bounded system in which a client workload calls an inference service, requests and
resource use are observable, and a known artifact can be restored after a failed rollout.
Keep the three cloud applications' parity contract intact; any new application integration needs
its own reviewed implementation and evidence.

The capstone should produce:

| Deliverable | Acceptance |
|---|---|
| Architecture and ADRs | Request/data paths, identity boundaries, artifact/model ownership, capacity assumptions and local-versus-cloud tradeoffs are explicit |
| Reproducible release | Runtime/config/model revisions and integrity checks are recorded; health checks reject an unavailable service |
| Bounded benchmark | Fixed synthetic inputs, concurrency and duration; latency/TTFT/throughput and resource measurements; repeated runs and limitations reported |
| Capacity and cost reasoning | Identify the observed bottleneck, stop conditions, resource maxima and any account spending window; distinguish estimates from measured costs |
| Incident and recovery | Inject one scoped failure, diagnose it from signals, restore a known artifact and verify requests recover |
| Cleanup and handoff | Teardown/leftovers, intentionally retained artifacts, runbook and evidence sufficient for another learner to repeat the exercise |

A mock-only rehearsal can validate the delivery and observation path, but it does not close the
real-inference checkpoint. Hardware claims require the optional hardware evidence; the baseline
capstone should remain accessible through a validated CPU inference path when R12.2 is delivered.

## Learning record and resource boundaries

Use the checkpoint template in [LEARNING_PATH.md](LEARNING_PATH.md). For every run record the
repository revision, environment/profile, exact commands, observations, failure/recovery,
resource or cost bounds and cleanup. Use synthetic prompts and data.

Start with the documented basic environment and add one bounded module at a time. A shared
Docker daemon, separate container or worktree does not reserve host RAM, disk or GPU capacity.
Use disposable environments for resource-heavy exercises and follow the executable repository's
own harness. This track does not authorize cloud provisioning, device-driver installation or
changes to an existing service.
