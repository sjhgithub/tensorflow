/* Copyright 2024 The OpenXLA Authors.

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

#ifndef XLA_SERVICE_CPU_RUNTIME_INFEED_THUNK_H_
#define XLA_SERVICE_CPU_RUNTIME_INFEED_THUNK_H_

#include <memory>
#include <vector>

#include "absl/status/statusor.h"
#include "absl/types/span.h"
#include "xla/service/buffer_assignment.h"
#include "xla/service/cpu/runtime/thunk.h"
#include "xla/shape.h"
#include "xla/tsl/concurrency/async_value_ref.h"

namespace xla::cpu {

// Infeeds data from the runtime-managed infeed queue into the given slices.
class InfeedThunk final : public Thunk {
 public:
  struct InfeedBuffer {
    BufferAllocation::Slice slice;
    Shape shape;
  };

  static absl::StatusOr<std::unique_ptr<InfeedThunk>> Create(
      Info info, absl::Span<const InfeedBuffer> infeed_buffers);

  tsl::AsyncValueRef<ExecuteEvent> Execute(const ExecuteParams& params) final;

  BufferUses buffer_uses() const final;

 private:
  InfeedThunk(Info info, absl::Span<const InfeedBuffer> infeed_buffers);

  std::vector<InfeedBuffer> infeed_buffers_;
};

}  // namespace xla::cpu

#endif  // XLA_SERVICE_CPU_RUNTIME_INFEED_THUNK_H_
