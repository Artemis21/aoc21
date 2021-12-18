"""The solution to day 8."""
from .aoc_helper import Solution

POPCNT = bytes(bin(x).count("1") for x in range(128))
A = 1
B = 2
C = 4
D = 8
E = 16
F = 32
G = 64


class Day(Solution):
    """The solution to day 8."""

    day = 8

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.data: list[tuple[list[int], list[int]]] = []
        for line in raw.splitlines():
            inputs, output = line.split(" | ")
            self.data.append((self._parse_digits(inputs), self._parse_digits(output)))

    def _parse_digits(self, raw_digits: str) -> list[int]:
        """Parse digit displays to bitmaps."""
        digits = []
        for digit in raw_digits.split():
            value = 0
            for char in digit:
                match char:
                    case "a": value |= A
                    case "b": value |= B
                    case "c": value |= C
                    case "d": value |= D
                    case "e": value |= E
                    case "f": value |= F
                    case "g": value |= G
            digits.append(value)
        return digits

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        total = 0
        for _, output in self.data:
            for digit in output:
                if POPCNT[digit] in (2, 3, 7, 4):
                    total += 1
        return total

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        total = 0
        for inputs, output in self.data:
            one = four = None
            for inp in inputs:
                if POPCNT[inp] == 2:
                    one = inp
                if POPCNT[inp] == 4:
                    four = inp
            if not (one and four):
                raise ValueError("Could not find outputs for one and four.")
            value_map = {}
            for inp in inputs:
                match POPCNT[one & inp], POPCNT[four & inp], POPCNT[inp]:
                    case 2, 3, 6: value = 0
                    case 2, 2, 2: value = 1
                    case 1, 2, 5: value = 2
                    case 2, 3, 5: value = 3
                    case 2, 4, 4: value = 4
                    case 1, 3, 5: value = 5
                    case 1, 3, 6: value = 6
                    case 2, 2, 3: value = 7
                    case 2, 4, 7: value = 8
                    case 2, 4, 6: value = 9
                    case _: raise ValueError("Unmatched input.")
                value_map[inp] = value
            for place, digit in enumerate(output):
                total += value_map[digit] * (10 ** (3 - place))
        return total


if __name__ == "__main__":
    Day.submit()
