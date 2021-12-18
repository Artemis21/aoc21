"""The solution to day 17."""
import re
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 17."""

    day = 17

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        if m := re.match(r"target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)", raw):
            self.x0, self.x1, self.y0, self.y1 = map(int, m.groups())
        else:
            raise ValueError("Failed to parse input.")

    def _velocity_works(self, dx: int, dy: int) -> bool:
        """Check if the given coordinates are in the target area."""
        x = y = 0
        while x < self.x1 and y > self.y0:
            x += dx
            y += dy
            if dx < 0:
                dx += 1
            elif dx > 0:
                dx -= 1
            dy -= 1
            if (self.x0 <= x <= self.x1) and (self.y0 <= y <= self.y1):
                return True
        return False

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return (self.y0 ** 2 + self.y0) // 2

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        return sum(
            self._velocity_works(dx, dy)
            for dx in range(self.x1 + 1)
            for dy in range(self.y0, -self.y0)
        )


if __name__ == "__main__":
    Day.submit()
