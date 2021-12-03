"""Run the day 1 WASM solution."""
import pathlib

from wasmer import wat2wasm, engine, Store, Module, Instance, Function, ImportObject
from wasmer_compiler_cranelift import Compiler

BASE_DIR = pathlib.Path(__file__).parent
INPUT_FILE = BASE_DIR / "input.txt"
WASM_FILE = BASE_DIR / "main.wat"


def printi(val: int):
    """Print an integer."""
    print("printi", val)


def printf(val: float):
    """Print a float."""
    print("printf", val)


def printarr2d(pointer: int, length: int, item_length: int):
    """Print a float."""
    pointer //= 4
    end = pointer + length * item_length
    if length and item_length:
        data = instance.exports.memory.uint32_view()[pointer:end]
    else:
        data = []
    print("printarr2d", [data[i:i+item_length] for i in range(0, len(data), item_length)])


def load_wasm() -> Instance:
    """Load the WASM module."""
    with open(WASM_FILE) as f:
        wasm = wat2wasm(f.read())
    store = Store(engine.JIT(Compiler))
    imp = ImportObject()
    imp.register("log", {"printi": Function(store, printi), "printf": Function(store, printf), "printarr2d": Function(store, printarr2d)})
    return Instance(Module(store, wasm), imp)


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
