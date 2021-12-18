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

To run a given day, use `python3.9 -m wasm.day_XX`, eg. `python3.9 -m wasm.day_01`. Or just use
`python3.9 -m wasm` to run all days.

## My Scores :)

```
      -------Part 1--------   -------Part 2--------
Day       Time  Rank  Score       Time  Rank  Score
 18   00:40:17   113      0   00:50:09   190      0
 17   00:15:40   547      0   02:08:05  5327      0
 16   00:23:12   138      0   00:31:05   158      0
 15   00:26:52  1678      0   00:48:03  1432      0
 14   00:06:58   308      0   00:21:10   433      0
 13   00:41:01  4627      0   00:44:49  3738      0
 12   00:07:43   170      0   00:11:20    71     30
 11   00:19:03  1147      0   00:21:02  1024      0
 10   00:04:20   142      0   00:06:34    40     61
  9   00:02:37    24     77   00:11:18   122      0
  8   00:05:38   392      0   00:33:12   549      0
  7   00:05:33  1818      0   00:07:18   894      0
  6   00:02:52    63     38   00:43:12  5206      0
  5   00:57:06  7117      0   01:12:29  6075      0
  4   00:47:39  4772      0   01:04:55  4793      0
  3   00:12:05  3929      0   00:42:34  4364      0
  2   00:02:58   955      0   00:04:52   793      0
  1   00:00:51    46     55   00:05:27   747      0
```
