"""The solution to day 9."""
from typing import Iterable

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 9."""

    day = 9

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.map = [list(map(int, line)) for line in raw.splitlines()]

    def _get_surrounding(self, x: int, y: int) -> Iterable[tuple[tuple[int, int], int]]:
        """Get each coordinate and height which surrounds a given point."""
        for dx, dy in ((0, 1), (1, 0), (0, -1), (-1, 0)):
            if len(self.map) > y + dy >= 0 and len(self.map[y]) > x + dx >= 0:
                yield (x + dx, y + dy), self.map[y + dy][x + dx]

    def _get_low_points(self) -> Iterable[tuple[int, int]]:
        """Get the coordinates of each low point."""
        for y in range(len(self.map)):
            for x in range(len(self.map[y])):
                if all(self.map[y][x] < h for _, h in self._get_surrounding(x, y)):
                    yield x, y

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return sum(self.map[y][x] + 1 for x, y in self._get_low_points())

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        sizes = [0, 0, 0]
        for basin_bottom in self._get_low_points():
            to_process = {basin_bottom}
            processed = set()
            while to_process:
                new = set()
                for x, y in to_process:
                    for coords, height in self._get_surrounding(x, y):
                        if height != 9:
                            new.add(coords)
                processed.update(to_process)
                to_process = new - processed
            if (min_known := min(sizes)) < (size := len(processed)):
                sizes[sizes.index(min_known)] = size
        return sizes[0] * sizes[1] * sizes[2]


if __name__ == "__main__":
    Day.submit()
