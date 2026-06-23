#include <mbgl/util/async_task.hpp>

#include <emscripten.h>
#include <emscripten/eventloop.h>

#include <atomic>
#include <functional>
#include <stdexcept>

namespace mbgl {
namespace util {

class AsyncTask::Impl {
 public:
  explicit Impl(std::function<void()> fn) : task(std::move(fn)) {}

  void maySend() {
    if (scheduled.exchange(true)) {
      return;
    }

    emscripten_async_call(
      [](void* userdata) {
        auto* self = static_cast<Impl*>(userdata);
        self->scheduled = false;
        self->task();
      },
      this,
      0
    );
  }

 private:
  std::function<void()> task;
  std::atomic<bool> scheduled{false};
};

AsyncTask::AsyncTask(std::function<void()>&& fn)
    : impl(std::make_unique<Impl>(std::move(fn))) {}

AsyncTask::~AsyncTask() = default;

void AsyncTask::send() { impl->maySend(); }

}  // namespace util
}  // namespace mbgl
