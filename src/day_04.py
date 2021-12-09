"""The solution to day 4."""
from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 4."""

    day = 4

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        raw_rolls, *raw_boards = raw.strip().split("\n\n")
        self.rolls = list(map(int, raw_rolls.split(",")))
        self.boards = [
            [list(map(int, line.split())) for line in raw_board.splitlines()]
            for raw_board in raw_boards
        ]

    def _get_board_scores(self) -> list[tuple[int, list[list[int]]]]:
        """Get the win turn and score for each board."""
        value_to_index = {value: n for n, value in enumerate(self.rolls)}
        scores = []
        columns = len(self.boards[0][0])
        for board in self.boards:
            lines = [*board, *([row[n] for row in board] for n in range(columns))]
            win_turn = min(max(value_to_index[n] for n in line) for line in lines)
            scores.append((win_turn, board))
        return scores

    def _get_board_score(self, win_turn: int, board: list[list[int]]) -> int:
        """Get the score for a board."""
        value_to_index = {value: n for n, value in enumerate(self.rolls)}
        value = sum(n for row in board for n in row if value_to_index[n] > win_turn)
        return self.rolls[win_turn] * value

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        return self._get_board_score(*min(self._get_board_scores()))

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        return self._get_board_score(*max(self._get_board_scores()))


if __name__ == "__main__":
    Day.submit()
