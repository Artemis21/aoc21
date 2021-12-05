# aoc21

Advent of code solutions 2021.

The automation in `src/aoc_helper` is based on the work of **@salt-die**,
[here](https://github.com/salt-die/Advent-of-Code).

## Installation

Python solutions require Python 3.10 or later. They are fully automated - they will fetch
the input data and submit a solution automatically.

Install dependencies from `requirements.txt`, eg. `python3.10 -m pip install -r requirements.txt`.
Get the session token cookie from the advent of code website (using whatever tools your browser
provides to inspect cookies). Place that in `src/aoc_helper/.token`.

Once installed, you can use `python3.10 -m src --help` to see the available options.

## Running WASM Solutions

WASM solutions require Python 3.9 (Wasmer does not support Python 3.10). They are not automated -
they get the input from a text file, and give a solution on stdout.

Install dependencies from `requirements-wasm.txt`, eg.
`python3.9 -m pip install -r requirements-wasm.txt`.

To run a given day, use `python3.9 -m wasm.day_XX`, eg. `python3.9 -m wasm.day_01`.

## My Scores :)

```
      -------Part 1--------   -------Part 2--------
Day       Time  Rank  Score       Time  Rank  Score
  5   00:57:06  7117      0   01:12:29  6075      0
  4   00:47:39  4772      0   01:04:55  4793      0
  3   00:12:05  3929      0   00:42:34  4364      0
  2   00:02:58   955      0   00:04:52   793      0
  1   00:00:51    46     55   00:05:27   747      0
```
