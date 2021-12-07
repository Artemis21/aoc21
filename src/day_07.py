"""The solution to day 7."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 7."""

    day = 7

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.nums = sorted(list(map(int, raw.split(","))))

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        position = self.nums[len(self.nums) // 2]
        total = 0
        for num in self.nums:
            total += abs(position - num)
        return total

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        position = sum(self.nums) // len(self.nums)
        total = 0
        for num in self.nums:
            dist = abs(position - num)
            total += round((dist + 1) * (dist / 2))
        return total


if __name__ == "__main__":
    Day.submit()
