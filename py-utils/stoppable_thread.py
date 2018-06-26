import threading

# StackOverflow adaptation: www.goo.gl/hgdmk8
# implements basic poison-pill
class StoppableThread(threading.Thread):

    def __init__(self, fn, *args, **kwargs):
        super(StoppableThread, self).__init__(
            target=fn,
            args=args,
            kwargs=kwargs,
        )
        self._stop_event = threading.Event()
        return

    def stop(self):
        self._stop_event.set()
        return

    def stopped(self):
        return self._stop_event.is_set()
