"""The solution to day 5."""
from collections import defaultdict
import re

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 5."""

    day = 5

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.pairs: list[tuple[int, int, int, int]] = []
        for line in raw.strip().splitlines():
            if match := re.match(r"(\d+),(\d+) -> (\d+),(\d+)", line):
                self.pairs.append(tuple(map(int, match.groups())))  # type: ignore

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        grid = defaultdict(int)
        for x1, y1, x2, y2 in self.pairs:
            if x1 == x2:
                for y in range(min((y1, y2)), max((y1, y2)) + 1):
                    grid[x1, y] += 1
            elif y1 == y2:
                for x in range(min((x1, x2)), max((x1, x2)) + 1):
                    grid[x, y1] += 1
        return sum(i > 1 for i in grid.values())

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        grid = [[0] * 1000 for _ in range(1000)]
        for x1, y1, x2, y2 in self.pairs:
            length = max((abs(x2 - x1), abs(y2 - y1)))
            dx = 0 if x1 == x2 else (-1 if x1 > x2 else 1)
            dy = 0 if y1 == y2 else (-1 if y1 > y2 else 1)
            for d in range(length + 1):
                grid[y1 + d * dy][x1 + d * dx] += 1
        return sum(sum(i > 1 for i in row) for row in grid)


if __name__ == "__main__":
    Day.submit()
