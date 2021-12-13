"""Run the day's WASM solution."""
import pathlib

from wasmer import wat2wasm, engine, Store, Module, Instance
from wasmer_compiler_cranelift import Compiler

BASE_DIR = pathlib.Path(__file__).parent


def run_day(day: int):
    """Run the solution for a given day."""
    folder = BASE_DIR / f"day_{day:02}"
    with open(folder / "main.wat") as f:
        wasm = wat2wasm(f.read())
    store = Store(engine.JIT(Compiler))
    instance = Instance(Module(store, wasm))
    with open(folder / "input.txt", "rb") as f:
        data = f.read()
    memory = instance.exports.memory
    memory.grow(len(data))
    memory.uint8_view()[0:len(data)] = data
    part_1, *part_2 = instance.exports.main(0, len(data))
    if len(part_2) > 1:
        part_2 = "".join(map(chr, part_2))
    else:
        part_2 = part_2[0]
    print(f"Day {day:>2} part 1: {part_1}")
    print(f"Day {day:>2} part 2: {part_2}")


if __name__ == "__main__":
    for day in range(1, 26):
        run_day(day)
