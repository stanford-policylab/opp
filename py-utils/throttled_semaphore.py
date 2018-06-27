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
        self.cv = threading.Condition(threading.Lock())
        self.thread = StoppableThread(self.reset)
        return

    def acquire(self):
        """Acquire a semaphore, decrementing internal counter by one.

        If no semaphores are available, block until one is. The return value
        is a boolean indicating whether a semaphore was acquired. Acquiring
        can fail if the `stop` method is called while acquire is blocking.
        """
        got_one = False
        with self.cv:
            while not self.semaphore:
                self.cv.wait()
                if self.thread.stopped():
                    break
            else:
                self.semaphore -= 1
                got_one = True
        return got_one

    __enter__ = acquire

    def release(self):
        # NOTE: no-op to be consistent with python API
        return

    def __exit__(self, t, v, tb):
        self.release()
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
            time.sleep(self.per_n_seconds)
            with self.cv:
                self.semaphore = self.n
                self.cv.notify(self.n)
        # NOTE: wake every thread so they all exit
        with self.cv:
            self.cv.notify_all()
        return
