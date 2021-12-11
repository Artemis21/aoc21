"""The solution to day 11."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 11."""

    day = 11

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.nums = [list(map(int, line)) for line in raw.splitlines()]

    def update_cell(self, idx: int, cells: list[int]) -> int:
        """Update a cell of the grid and any cells it affects."""
        if cells[idx] < 10:
            return 0
        cells[idx] = 0
        count = 1
        for d in (-11, -10, -9, -1, 1, 9, 10, 11):
            if 0 <= idx + d < 100 and -1 <= idx % 10 - (idx + d) % 10 <= 1:
                if cells[idx + d]:
                    cells[idx + d] += 1
                    count += self.update_cell(idx + d, cells)
        return count

    def update_grid(self, cells: list[int]) -> int:
        """Do one update of the grid, and return the number of cells exploded."""
        for idx in range(100):
            cells[idx] += 1
        return sum(self.update_cell(idx, cells) for idx in range(100))

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        cells = [num for line in self.nums for num in line]
        return sum(self.update_grid(cells) for _ in range(100))

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        n = 0
        cells = [num for line in self.nums for num in line]
        while True:
            n += 1
            if self.update_grid(cells) == 100:
                return n


if __name__ == "__main__":
    Day.submit()
