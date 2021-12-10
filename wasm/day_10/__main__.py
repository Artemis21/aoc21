"""Run the day's WASM solution."""
import pathlib

from wasmer import wat2wasm, engine, Store, Module, Instance
from wasmer_compiler_cranelift import Compiler

BASE_DIR = pathlib.Path(__file__).parent
INPUT_FILE = BASE_DIR / "input.txt"
WASM_FILE = BASE_DIR / "main.wat"


def load_wasm() -> Instance:
    """Load the WASM module."""
    with open(WASM_FILE) as f:
        wasm = wat2wasm(f.read())
    store = Store(engine.JIT(Compiler))
    return Instance(Module(store, wasm))


def give_input(instance: Instance) -> tuple[int, int]:
    """Put the puzzle input in to the WASM memory."""
    with open(INPUT_FILE, "rb") as f:
        data = f.read()
    memory = instance.exports.memory
    memory.grow(len(data))
    memory.uint8_view()[0:len(data)] = data
    return 0, len(data)


if __name__ == "__main__":
    instance = load_wasm()
    part_1, part_2 = instance.exports.main(*give_input(instance))
    print(f"Part 1: {part_1}")
    print(f"Part 2: {part_2}")
