"""The solution to day 6."""
import functools

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
        fish = self.nums
        for _ in range(80):
            new_fish = []
            for f in fish:
                if f > 0:
                    new_fish.append(f - 1)
                else:
                    new_fish.append(8)
                    new_fish.append(6)
            fish = new_fish
        return len(fish)

    @functools.lru_cache
    def _fish_after_days(self, fish: int, days: int) -> int:
        """Work out how many fish a given fish will become after a given number of days."""
        days -= fish + 1
        if days < 0:
            return 1
        return self._fish_after_days(6, days) + self._fish_after_days(8, days)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        total = 0
        for fish in self.nums:
            total += self._fish_after_days(fish, 256)
        return total


if __name__ == "__main__":
    Day.submit()
