"""The solution to day 18."""
from .aoc_helper import Solution

Number = list[tuple[int, int]]


class Day(Solution):
    """The solution to day 18."""

    day = 18

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.numbers: list[Number] = []
        for line in raw.splitlines():
            number = []
            depth = 0
            for char in line:
                match char:
                    case "[": depth += 1
                    case "]": depth -= 1
                    case ",": pass
                    case _: number.append((int(char), depth))
            self.numbers.append(number)

    def try_explode(self, number: Number) -> bool:
        """Explode the first possible pair in a number, if any."""
        last_depth = None
        for idx, (after_add, depth) in enumerate(number):
            if last_depth == depth > 4:
                number[idx] = (0, depth - 1)
                before_add, _ = number.pop(idx - 1)
                if idx > 1:
                    before_val, before_depth = number[idx - 2]
                    number[idx - 2] = (before_val + before_add, before_depth)
                if idx < len(number):
                    after_val, after_depth = number[idx]
                    number[idx] = (after_val + after_add, after_depth)
                return True
            last_depth = depth
        return False

    def try_split(self, number: Number) -> bool:
        """Split the first possible leaf value in a number, if any."""
        for idx, (value, depth) in enumerate(number):
            if value > 9:
                before_val = value // 2
                number[idx] = (before_val, depth + 1)
                number.insert(idx + 1, (value - before_val, depth + 1))
                return True
        return False

    def add_two(self, a: Number, b: Number) -> Number:
        """Add two numbers together."""
        number = [
            *[(value, depth + 1) for value, depth in a],
            *[(value, depth + 1) for value, depth in b]
        ]
        while self.try_explode(number) or self.try_split(number):
            pass
        return number

    def try_combine(self, number: Number) -> bool:
        """Combine the first possible pair of numbers, if any."""
        last_depth = None
        for idx, (second_value, depth) in enumerate(number):
            if depth == last_depth:
                first_value, _ = number.pop(idx - 1)
                number[idx - 1] = (3 * first_value + 2 * second_value, depth - 1)
                return True
            last_depth = depth
        return False

    def get_magnitude(self, number: Number) -> int:
        """Recursively calculate the magnitude of a number."""
        while self.try_combine(number):
            pass
        return number[0][0]

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        number = self.numbers[0]
        for value in self.numbers[1:]:
            number = self.add_two(number, value)
        return self.get_magnitude(number)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        max_val = 0
        for num_a in self.numbers:
            for num_b in self.numbers:
                if num_a != num_b:
                    val = self.get_magnitude(self.add_two(num_a, num_b))
                    if val > max_val:
                        max_val = val
        return max_val


if __name__ == "__main__":
    Day.submit()
