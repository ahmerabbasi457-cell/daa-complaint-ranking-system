import heapq
import itertools

class TopKHeap:

    def __init__(self, k):
        self.k = k
        self.heap = []
        self.counter = itertools.count()  # unique tie-breaker

    def add(self, complaint):

        score = complaint["score"]
        count = next(self.counter)

        # If heap not full → push directly
        if len(self.heap) < self.k:
            heapq.heappush(self.heap, (score, count, complaint))
        else:
            # Compare only score (heap[0][0])
            if score > self.heap[0][0]:
                heapq.heappushpop(self.heap, (score, count, complaint))

    def get_topk(self):
        return [item[2] for item in sorted(self.heap, reverse=True)]