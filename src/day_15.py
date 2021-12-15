"""The solution to day 15."""
import heapq
from collections import defaultdict
from typing import Iterable

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 15."""

    day = 15

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.nodes = [list(map(int, line)) for line in raw.split("\n")]

    def _neighbours(
        self, x: int, y: int, width: int, height: int
    ) -> Iterable[tuple[int, int]]:
        """Iterate over the neighbours of a cell."""
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            if 0 <= x + dx < width and 0 <= y + dy < height:
                yield x + dx, y + dy

    def _find_least_cost(self, nodes: list[list[int]]) -> int:
        """Find the cost of the least cost path.

        Nodes should be a 2d list, where each element is the cost of moving to
        it from any neighbour. The path starts from (0, 0) and goes to the
        last element of the last list.
        """
        width, height = len(nodes[0]), len(nodes)
        best_paths = defaultdict(lambda: height * width * 9)
        best_paths[0, 0] = 0
        open = [(0, 0, 0)]
        while open:
            _, x, y = heapq.heappop(open)
            if x == width - 1 and y == height - 1:
                return best_paths[x, y]
            for nx, ny in self._neighbours(x, y, width, height):
                cost = best_paths[x, y] + nodes[ny][nx]
                if cost < best_paths[nx, ny]:
                    best_paths[nx, ny] = cost
                    heapq.heappush(open, (cost - nx - ny, nx, ny))
        raise ValueError("No path found.")

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return self._find_least_cost(self.nodes)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        maps = [
            [[((i + incr - 1) % 9) + 1 for i in row] for row in self.nodes]
            for incr in range(9)
        ]
        map_height = len(self.nodes)
        nodes = [[] for _ in range(map_height * 5)]
        for start_incr in range(5):
            for incr in range(start_incr, start_incr + 5):
                for y in range(map_height):
                    nodes[y + start_incr * map_height].extend(maps[incr][y])
        return self._find_least_cost(nodes)


if __name__ == "__main__":
    Day.submit()
