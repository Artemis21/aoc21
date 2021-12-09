"""An automatic solution runner for the Advent of Code.

Usage: {name} [day | part | all | --help] [--time]

  day         A day to run the solutions of, eg. d4 or d16.
  part        A specific part to run the solution of, eg. d2p1 or d20p2.
  all         Run all solutions of all days ("all").
  -h --help   Display this help message.
  -t --time   Print time taken to run instead of submitting.

By default, with no arguments, runs the current day.
"""
import datetime
import importlib
import re
import sys
import timeit
from typing import Any

import rich


def time_day(day: int, part: int | None, solver: Any):
    """Run the solutions of a day and print the time taken."""
    if part == 1 or not part:
        time = min(timeit.repeat(solver.part_1, number=10)) * 100
        rich.print(
            f"[bold]Time for [red]day {day}[/red] [grey70]part 1[/grey70]: "
            f"[green]{time:.4f}ms[/green][/bold]"
        )
    if part == 2 or not part:
        time = min(timeit.repeat(solver.part_2, number=10)) * 100
        rich.print(
            f"[bold]Time for [red]day {day}[/red] [yellow]part 2[/yellow]: "
            f"[green]{time:.4f}ms[/green][/bold]"
        )


def run_day(day: int, part: int | None, time_it: bool):
    """Run the solutions of a day."""
    mod = importlib.import_module(f".day_{day:>02}", "src")
    if not hasattr(mod, "Day"):
        raise ValueError(f"Day {day} does not have a class called Day defined.")
    solver = mod.Day.get_instance()  # type: ignore
    if time_it:
        time_day(day, part, solver)
        return
    if part == 1:
        solver.submit_1()
    elif part == 2:
        solver.submit_2()
    else:
        solver.submit()


def bad_usage():
    """Print the usage message and exit with an error code."""
    rich.print(Rf"[bold red]Usage: {sys.argv[0]} \[day | part | --help] [--time][/bold red]")
    sys.exit(1)


if __name__ == "__main__":
    time_it = False
    days = part = None
    for arg in sys.argv[1:]:
        if arg.lower() in ("-h", "--help"):
            print((__doc__ or "").format(name=sys.argv[0]))
            sys.exit(0)
        elif arg.lower() in ("-t", "--time"):
            time_it = True
        elif arg.startswith("-"):
            bad_usage()
        elif arg.lower() == "all":
            days = range(1, 26)
            part = None
        else:
            if not (match := re.match(r"d(\d+)(?:p(\d+))?", arg.lower())):
                bad_usage()
            days = [int(match.group(1))]
            part = int(match.group(2)) if match.group(2) else None
    if not days:
        days = [datetime.datetime.now().day]
    for day in days:
        run_day(day, part, time_it)
