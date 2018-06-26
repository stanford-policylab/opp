import threading
import time

from stoppable_thread import StoppableThread


class ThrottledSemaphore:

    def __init__(self, n, per_n_seconds=1):
        assert n > 0, 'n must be greater than 0!'
        assert per_n_seconds > 0, 'per_n_seconds must be greater than 0!'
        self.n = n
        self.per_n_seconds = per_n_seconds
        self.semaphore = n
        self.lock = threading.Lock()
        self.thread = StoppableThread(self.reset)
        return

    def acquire(self):
        with self.lock:
            # NOTE: spin since context switch is more expensive
            # for short durations, which are common here
            while not self.semaphore:
                continue
            self.semaphore -= 1
        return

    def release(self):
        # NOTE: no-op to be consistent with python API
        return

    def start(self):
        self.thread.start()
        return

    def stop(self):
        # NOTE: on return, thread dies as per python API
        self.thread.stop()
        return

    def reset(self):
        while not self.thread.stopped():
            # NOTE: no need to lock on reset
            self.semaphore = self.n
            time.sleep(self.per_n_seconds)
        return
