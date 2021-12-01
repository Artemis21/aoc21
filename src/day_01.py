"""The solution to day 1."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 1."""

    day = 1

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.nums = list(map(int, raw.splitlines()))

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return sum(self.nums[i + 1] > self.nums[i] for i in range(len(self.nums) - 1))

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        sums = [sum(self.nums[i:i + 3]) for i in range(len(self.nums) - 2)]
        return sum(sums[i + 1] > sums[i] for i in range(len(sums) - 1))


if __name__ == "__main__":
    Day.submit()
