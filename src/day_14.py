"""The solution to day 14."""
import collections

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 14."""

    day = 14

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.init, raw_rules = raw.split("\n\n")
        self.rules = {}
        for line in raw_rules.splitlines():
            pair, insert = line.split(" -> ")
            self.rules[pair] = (pair[0] + insert, insert + pair[1])

    def _count_range_after_iters(self, iters: int) -> int:
        """Get the range of character counts after a given number of iterations."""
        counts = collections.Counter([self.init[i:i+2] for i in range(len(self.init) - 1)])
        for _ in range(iters):
            new = collections.Counter()
            for pair, count in counts.items():
                before, after = self.rules[pair]
                new[before] += count
                new[after] += count
            counts = new
        char_counts = collections.Counter()
        for (first, last), count in counts.items():
            char_counts[first] += count
            char_counts[last] += count
        counts = list(char_counts.values())
        return max(counts) - min(counts)

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return self._count_range_after_iters(10)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        return self._count_range_after_iters(40)


if __name__ == "__main__":
    Day.submit()
