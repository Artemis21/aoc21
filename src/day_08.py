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
CHARS = (A, B, C, D, E, F, G)


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

    def _to_int(self, digits: list[int], position_map: dict[int, int]) -> int:
        """Parse each digit of the output and return the value displayed."""
        value = ""
        for digit in digits:
            mapped = 0
            for from_, to in position_map.items():
                mapped |= digit & from_ and to
            value += {
                (A | B | C | E | F | G): "0",
                (C | F): "1",
                (A | C | D | E | G): "2",
                (A | C | D | F | G): "3",
                (B | C | D | F): "4",
                (A | B | D | F | G): "5",
                (A | B | D | E | F | G): "6",
                (A | C | F): "7",
                (A | B | C | D | E | F | G): "8",
                (A | B | C | D | F | G): "9",
            }[mapped]
        return int(value)

    def _get_f_and_c(self, inputs: list[int]) -> tuple[int, int]:
        """Get the input bits that should be mapped to f and c."""
        by_length = {
            length: [inp for inp in inputs if POPCNT[inp] == length]
            for length in range(2, 8)
        }
        f = [
            char for char in CHARS
            if char & by_length[2][0] and all(char & inp_6 for inp_6 in by_length[6])
        ][0]
        c = [char for char in CHARS if char & by_length[2][0] and char != f][0]
        return f, c

    def _collapse_possibles(self, possibles: dict[int, int]):
        """Pick a single value for each set of possibilities, once enough is known."""
        for k, v in possibles.items():
            if POPCNT[v] > 1:
                for other_k, other_v in possibles.items():
                    if other_k != k:
                        possibles[k] &= ~other_v

    def _reduce_possibles(self, inputs: list[int], possibles: dict[int, int]):
        """Reduce the possibilities for each character in the input."""
        for input in inputs:
            matching = [i for i in CHARS if i & input]
            complement = [i for i in CHARS if not i & input]
            this_possible = ()
            match POPCNT[input]:
                case 2: this_possible = (matching, C | F), (complement, A | B | D | E | G)
                case 3: this_possible = (matching, A | C | F), (complement, B | D | E | G)
                case 4: this_possible = (matching, B | C | D | F), (complement, A | D | E | G)
                case 6: this_possible = ((complement, E | C | D),)
                case 5: this_possible = ((complement, B | C | E | F),)
            for in_masks, out_mask in this_possible:
                for in_mask in in_masks:
                    possibles[in_mask] &= out_mask

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        total = 0
        for inputs, output in self.data:
            possibles = {i: 127 for i in CHARS}
            f, c = self._get_f_and_c(inputs)
            possibles[f] = F
            possibles[c] = C
            self._reduce_possibles(inputs, possibles)
            self._collapse_possibles(possibles)
            total += self._to_int(output, possibles)
        return total


if __name__ == "__main__":
    Day.submit()
