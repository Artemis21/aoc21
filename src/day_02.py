"""The solution to day 2."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 2."""

    day = 2

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.instructions = []
        for line in raw.splitlines():
            raw_direction, raw_value = line.split()
            value = int(raw_value)
            if raw_direction == "up":
                self.instructions.append((True, -value))
            elif raw_direction == "down":
                self.instructions.append((True, value))
            else:
                self.instructions.append((False, value))

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        horizontal = depth = 0
        for is_vertical, distance in self.instructions:
            if is_vertical:
                depth += distance
            else:
                horizontal += distance
        return horizontal * depth

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        aim = horizontal = depth = 0
        for is_vertical, distance in self.instructions:
            if is_vertical:
                aim += distance
            else:
                horizontal += distance
                depth += aim * distance
        return horizontal * depth


if __name__ == "__main__":
    Day.submit()
