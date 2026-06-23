#include <mbgl/actor/scheduler.hpp>
#include <mbgl/util/async_task.hpp>
#include <mbgl/util/run_loop.hpp>

#include <cassert>
#include <functional>
#include <stdexcept>

namespace mbgl {
namespace util {

class RunLoop::Impl {
 public:
  RunLoop::Type type = RunLoop::Type::Default;
  std::unique_ptr<AsyncTask> async;
  bool running = false;
};

RunLoop* RunLoop::Get() {
  assert(static_cast<RunLoop*>(Scheduler::GetCurrent()));
  return static_cast<RunLoop*>(Scheduler::GetCurrent());
}

RunLoop::RunLoop(Type type) : impl(std::make_unique<Impl>()) {
  impl->type = type;
  Scheduler::SetCurrent(this);
  impl->async = std::make_unique<AsyncTask>(std::bind(&RunLoop::process, this));
}

RunLoop::~RunLoop() { Scheduler::SetCurrent(nullptr); }

LOOP_HANDLE RunLoop::getLoopHandle() { return nullptr; }

void RunLoop::wake() {
  if (impl->async) {
    impl->async->send();
  }
}

void RunLoop::run() {
  MBGL_VERIFY_THREAD(tid);
  impl->running = true;
  while (impl->running) {
    runOnce();
  }
}

void RunLoop::runOnce() {
  MBGL_VERIFY_THREAD(tid);
  process();
}

void RunLoop::stop() {
  invoke([&] { impl->running = false; });
}

void RunLoop::updateTime() {}

void RunLoop::waitForEmpty([[maybe_unused]] const mbgl::util::SimpleIdentity tag) {
  while (true) {
    std::size_t remaining;
    {
      std::scoped_lock lock(mutex);
      remaining = defaultQueue.size() + highPriorityQueue.size();
    }

    if (remaining == 0) {
      return;
    }

    runOnce();
  }
}

void RunLoop::addWatch(int, Event, std::function<void(int, Event)>&&) {
  throw std::runtime_error("RunLoop::addWatch is not supported on Emscripten");
}

void RunLoop::removeWatch(int) {}

}  // namespace util
}  // namespace mbgl
