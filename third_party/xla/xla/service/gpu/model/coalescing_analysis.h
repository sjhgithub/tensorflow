/* Copyright 2023 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#ifndef XLA_SERVICE_GPU_MODEL_COALESCING_ANALYSIS_H_
#define XLA_SERVICE_GPU_MODEL_COALESCING_ANALYSIS_H_

#include "xla/hlo/ir/hlo_instruction.h"
#include "xla/service/gpu/hlo_fusion_analysis.h"

namespace xla {
namespace gpu {

// Returns true if all input reads are coalesced. If consumer is not nullptr,
// producer and consumer are considered as one fusion, otherwise it's only the
// producer.
//
// This is a crude heuristic until we get proper tile analysis.
bool IsReadCoalesced(const std::optional<HloFusionAnalysis>& fusion_analysis,
                     const HloInstruction* producer,
                     const HloInstruction* consumer = nullptr);

}  // namespace gpu
}  // namespace xla

#endif  // XLA_SERVICE_GPU_MODEL_COALESCING_ANALYSIS_H_