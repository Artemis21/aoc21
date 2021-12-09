"""The solution to day 6."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 6."""

    day = 6

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.raw = raw.strip()
        self.lines = self.raw.splitlines()
        self.nums = list(map(int, raw.split(",")))

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        totals = [self.nums.count(fish) for fish in range(9)]
        for _ in range(80):
            new = totals.pop(0)
            totals.append(new)
            totals[6] += new
        return sum(totals)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        totals = [self.nums.count(fish) for fish in range(9)]
        for _ in range(256):
            new = totals.pop(0)
            totals.append(new)
            totals[6] += new
        return sum(totals)


if __name__ == "__main__":
    Day.submit()
