"""The solution to day 12."""
from collections import defaultdict
from functools import cache

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 12."""

    day = 12

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.raw = raw
        self.graph = defaultdict(list)
        for line in raw.splitlines():
            a, b = line.split("-")
            self.graph[a].append(b)
            self.graph[b].append(a)

    @cache
    def traverse(self, cave: str, smalls: tuple[str, ...], revisit_smalls: bool = False) -> int:
        """Recursively find paths from a given cave."""
        if cave == "end":
            return 1
        if cave.islower():
            smalls = (*smalls, cave)
        count = 0
        for node in self.graph[cave]:
            if node not in smalls:
                count += self.traverse(node, smalls, revisit_smalls)
            elif revisit_smalls and node != "start":
                count += self.traverse(node, smalls, False)
        return count

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return self.traverse("start", ())

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        return self.traverse("start", (), True)


if __name__ == "__main__":
    Day.submit()
