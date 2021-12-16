"""The solution to day 16."""
import collections
import functools
import math
from typing import Deque, Iterable

from .aoc_helper import Solution


class Day(Solution):
    """The solution to day 16."""

    day = 16

    def __init__(self, raw: str):
        """Parse and store the raw data."""
        self.data = list(map(functools.partial(int, base=16), raw))
        self.data.reverse()
        self.position = 0
        self.stream: list[int] = []
        self.buffer: Deque[int] = collections.deque()

    def _reset(self):
        """Reset the stream to the start."""
        self.position = 0
        self.stream = list(self.data)
        self.buffer = collections.deque()

    def _read_int(self, length: int) -> int:
        """Read an int of a given bit length from the stream."""
        while len(self.buffer) < length:
            nibble = self.stream.pop()
            for n in range(3, -1, -1):
                self.buffer.append(nibble >> n & 1)
        value = 0
        for n in range(length - 1, -1, -1):
            value |= self.buffer.popleft() << n
        self.position += length
        return value

    def _read_literal(self) -> int:
        """Read a chunked literal (type code 4) from the stream."""
        value = 0
        while True:
            chunk = self._read_int(5)
            value <<= 4
            value |= chunk & 0b1111
            if not chunk >> 4:
                return value

    def _read_nested_packets(self, version_sum: bool) -> Iterable[int]:
        """Read a packet length descriptor, and then its subpackets."""
        length_type = self._read_int(1)
        if length_type:
            packets = self._read_int(11)
            for _ in range(packets):
                yield self._read_packet(version_sum)
        else:
            bits = self._read_int(15)
            end = self.position + bits
            while self.position < end:
                yield self._read_packet(version_sum)

    def _calculate_packet(self, packet_type: int, values: Iterable[int]) -> int:
        """Aggregate the sub-values of a packet according to its type."""
        v_iter = iter(values)
        match packet_type:
            case 0: return sum(values)
            case 1: return math.prod(values)
            case 2: return min(values)
            case 3: return max(values)
            case 5: return next(v_iter) > next(v_iter)
            case 6: return next(v_iter) < next(v_iter)
            case 7: return next(v_iter) == next(v_iter)
        raise ValueError("Unkown packet type.")

    def _read_packet(self, version_sum: bool) -> int:
        """Read a packet from the stream.

        If version_sum is True, return the sum of the packet's version and the
        version of all sub-packets (including nested ones). Otherwise, return
        the value of the packet.
        """
        version = self._read_int(3)
        packet_type = self._read_int(3)
        if packet_type == 4:
            value = self._read_literal()
            return version if version_sum else value
        else:
            values = self._read_nested_packets(version_sum)
            if version_sum:
                return version + sum(values)
            return self._calculate_packet(packet_type, values)

    def part_1(self) -> str | int | None:
        """Calculate the answer for part 1."""
        self._reset()
        return self._read_packet(True)

    def part_2(self) -> str | int | None:
        """Calculate the answer for part 2."""
        self._reset()
        return self._read_packet(False)


if __name__ == "__main__":
    Day.submit()
