"""Run the day 1 WASM solution."""
import pathlib

from wasmer import (
    wat2wasm,
    engine,
    Store,
    Module,
    Instance,
    Function,
    ImportObject,
    FunctionType,
    Type,
)
from wasmer_compiler_cranelift import Compiler

BASE_DIR = pathlib.Path(__file__).parent
INPUT_FILE = BASE_DIR / "input.txt"
WASM_FILE = BASE_DIR / "main.wat"


class Inputs:
    """Store the input for the day."""

    def __init__(self) -> None:
        """Load the input."""
        with open(INPUT_FILE, "r") as f:
            self.data: list[tuple[int, int]] = []
            for line in f:
                direction, value = line.strip().split()
                if direction == "forward":
                    self.data.append((1, int(value)))
                elif direction == "up":
                    self.data.append((2, int(value)))
                elif direction == "down":
                    self.data.append((3, int(value)))

    def get_count(self) -> int:
        """Get the number of elements in the input."""
        return len(self.data)

    def get_next(self) -> tuple[int, int]:
        """Get the next element in the input."""
        return self.data.pop(0)


def output(part: int, value: int):
    """Output the result."""
    print(f"Part {part}: {value}")


def load_wasm() -> tuple[Module, Store]:
    """Load the WASM module."""
    with open(WASM_FILE) as f:
        wasm = wat2wasm(f.read())
    store = Store(engine.JIT(Compiler))
    return Module(store, wasm), store


def prepare_instance() -> Instance:
    """Prepare the WASM instance."""
    module, store = load_wasm()
    inputs = Inputs()
    imports = ImportObject()
    value_func = Function(store, inputs.get_next, FunctionType([], [Type.I32, Type.I32]))
    imports.register(
        "aoc",
        {
            "getInputCount": Function(store, inputs.get_count),
            "getInputValue": value_func,
            "giveSolution": Function(store, output),
        }
    )
    return Instance(module, imports)


inst = prepare_instance()
inst.exports.main()
