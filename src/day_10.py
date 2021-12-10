"""The solution to day 10."""
from statistics import median_low

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 10."""

    day = 10

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.lines = raw.splitlines()

    def _parse_to_stack(self, line: str) -> tuple[list[str], str | None]:
        """Parse a line as a stack of brackets that remain to be closed.

        The second return value is the first erroneous character, if any.
        """
        stack = []
        for char in line:
            match char:
                case "(": stack.append(")")
                case "[": stack.append("]")
                case "{": stack.append("}")
                case "<": stack.append(">")
                case _:
                    if stack.pop() != char:
                        return stack, char
        return stack, None

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        total = 0
        for line in self.lines:
            _, invalid = self._parse_to_stack(line)
            match invalid:
                case ")": total += 3
                case "]": total += 57
                case "}": total += 1197
                case ">": total += 25137
        return total

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        scores = []
        for line in self.lines:
            stack, invalid = self._parse_to_stack(line)
            if invalid:
                continue
            score = 0
            while stack:
                score *= 5
                match stack.pop():
                    case ")": score += 1
                    case "]": score += 2
                    case "}": score += 3
                    case ">": score += 4
            scores.append(score)
        return median_low(scores)


if __name__ == "__main__":
    Day.submit()
