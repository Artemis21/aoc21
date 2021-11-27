"""An automatic solution runner for the Advent of Code.

Usage: {name} [day | part | --help]

  day         A day to run the solutions of, eg. d4 or d16.
  part        A specific part to run the solution of, eg. d2p1 or d20p2.
  -h --help   Display this help message.
"""
import importlib
import re
import sys

import rich


def run_day(day: int, part: int = None):
    """Run the solutions of a day."""
    mod = importlib.import_module(f".day_{day:>02}", "src")
    if not hasattr(mod, "Day"):
        raise ValueError(f"Day {day} does not have a class called Day defined.")
    solver = mod.Day.get_instance()  # type: ignore
    solver.submit()


def bad_usage():
    """Print the usage message and exit with an error code."""
    rich.print(Rf"[bold red]Usage: {sys.argv[0]} \[day | part | --help][/bold red]")
    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) > 2:
        bad_usage()
    if len(sys.argv) == 2 and sys.argv[1].lower() in ("-h", "--help"):
        print((__doc__ or "").format(name=sys.argv[0]))
        sys.exit(0)
    if len(sys.argv) == 1:
        for day in range(1, 26):
            run_day(day)
    else:
        raw = sys.argv[1].lower()
        if not (match := re.match(r"d(\d+)(?:p(\d+))?", raw)):
            bad_usage()
        day = int(match.group(1))
        part = int(match.group(2)) if match.group(2) else None
        run_day(day, part)
