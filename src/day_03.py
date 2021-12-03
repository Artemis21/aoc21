"""The solution to day 3."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 3."""

    day = 3

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.bits = [list(map(int, line)) for line in raw.splitlines()]

    def _get_most_frequent(self, values: list[list[int]], position: int) -> int:
        """Get the most frequent bit value at a given position."""
        return sum(bits[position] for bits in values) >= (len(values) / 2)

    def _bit_list_to_int(self, bits: list[int]) -> int:
        """Convert a list of bits to an integer."""
        return int("".join([str(int(bit)) for bit in bits]), 2)

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        gamma_bits = [self._get_most_frequent(self.bits, n) for n in range(len(self.bits[0]))]
        gamma = self._bit_list_to_int(gamma_bits)
        epsilon = (~gamma) & ((1 << len(gamma_bits)) - 1)
        return gamma * epsilon

    def _half_part_2(self, most_frequent: bool) -> int:
        """Calculate one of the two values for part 2, depending on the parameter."""
        values = list(map(list, self.bits))
        n = 0
        while len(values) > 1:
            select = self._get_most_frequent(values, n) ^ most_frequent
            values = [bits for bits in values if bits[n] == select]
            n += 1
        return self._bit_list_to_int(values[0])

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        return self._half_part_2(True) * self._half_part_2(False)


if __name__ == "__main__":
    Day.submit()
