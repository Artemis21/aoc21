"""The solution to day 13."""
from typing import Iterable

from .aoc_helper import Solution

ALPHABET = {
    0b0110_1001_1001_1111_1001_1001: "A",
    0b1110_1001_1110_1001_1001_1110: "B",
    0b0110_1001_1000_1000_1001_0110: "C",
    # D
    0b1111_1000_1110_1000_1000_1111: "E",
    0b1111_1000_1110_1000_1000_1000: "F",
    0b0110_1001_1000_1011_1001_0111: "G",
    0b1001_1001_1111_1001_1001_1001: "H",
    0b0111_0010_0010_0010_0010_0111: "I",
    0b0011_0001_0001_0001_1001_0110: "J",
    0b1001_1010_1100_1010_1010_1001: "K",
    0b1000_1000_1000_1000_1000_1111: "L",
    # M
    # N
    0b0110_1001_1001_1001_1001_0110: "O",
    0b1110_1001_1001_1110_1000_1000: "P",
    # Q
    0b1110_1001_1001_1110_1010_1001: "R",
    0b0111_1000_1000_0110_0001_1110: "S",
    # T
    0b1001_1001_1001_1001_1001_0110: "U",
    # V
    # W
    # X
    0b1000_1000_0101_0010_0010_0010: "Y",
    0b1111_0001_0010_0100_1000_1111: "Z",
}


class Day(Solution):
    """The solution to day 13."""

    day = 13

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        raw_coords, raw_instructions = raw.split("\n\n")
        self.coords = []
        for line in raw_coords.splitlines():
            x, y = line.split(",")
            self.coords.append((int(x), int(y)))
        self.instructions = []
        for line in raw_instructions.splitlines():
            axis, n = line.removeprefix("fold along ").split("=")
            self.instructions.append((axis, int(n)))

    def _fold_coords(
        self,
        coords: Iterable[tuple[int, int]],
        axis: str,
        n: int,
    ) -> set[tuple[int, int]]:
        """Fold the coordinates along a given line in a given axis."""
        return {
            (
                ((x, y) if x < n else (2 * n - x, y))
                if axis == "x" else
                ((x, y) if y < n else (x, 2 * n - y))
            ) for x, y in coords
        }

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return len(self._fold_coords(self.coords, *self.instructions[0]))

    def _get_letters(self, coords: Iterable[tuple[int, int]]) -> str:
        """Run some OCR to get letters from ASCII art."""
        letters = ""
        for x_start in range(0, max(x for x, _ in coords), 5):
            value = 0
            for y in range(6):
                for x in range(x_start, x_start + 4):
                    value <<= 1
                    value |= (x, y) in coords
            letters += ALPHABET[value]
        return letters

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        coords = self.coords
        for axis, n in self.instructions:
            coords = self._fold_coords(coords, axis, n)
        return self._get_letters(coords)


if __name__ == "__main__":
    Day.submit()
