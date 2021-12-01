"""Run the day 1 WASM solution."""
import pathlib

from wasmer import wat2wasm, engine, Store, Module, Instance, Function, ImportObject
from wasmer_compiler_cranelift import Compiler

BASE_DIR = pathlib.Path(__file__).parent
INPUT_FILE = BASE_DIR / "input.txt"
WASM_FILE = BASE_DIR / "main.wat"


class Inputs:
    """Store the input for the day."""

    def __init__(self) -> None:
        """Load the input."""
        with open(INPUT_FILE, "r") as f:
            self.data = list(map(int, f))

    def get_count(self) -> int:
        """Get the number of elements in the input."""
        return len(self.data)

    def get_next(self) -> int:
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
    imports.register(
        "aoc",
        {
            "getInputCount": Function(store, inputs.get_count),
            "getInputValue": Function(store, inputs.get_next),
            "giveSolution": Function(store, output),
        }
    )
    return Instance(module, imports)


inst = prepare_instance()
inst.exports.main()
