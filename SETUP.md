# BW-Tree Quick Setup Guide

## Prerequisites

This project uses **pixi** for Mojo version management and dependency handling.

## Installation Steps

### 1. Install Pixi

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

Enable shell completion (optional but recommended):
```bash
# For bash
eval "$(pixi completion --shell bash)"

# For zsh
eval "$(pixi completion --shell zsh)"
```

### 2. Configure Default Channels

Add Modular's conda channel:
```bash
echo 'default-channels = ["https://conda.modular.com/max-nightly", "conda-forge"]' \
  >> $HOME/.pixi/config.toml
```

### 3. Initialize Project (Already Done)

This project is already configured with `pixi.toml`. You just need to install dependencies:

```bash
# From project root
pixi install
```

### 4. Verify Mojo Installation

```bash
pixi run mojo --version
# Should show: Mojo 0.25.6+ or later
```

## Running Tests

### Run All Tests

```bash
# Atomic operations tests
pixi run mojo run tests/test_atomic.mojo

# BW-Tree operations tests
pixi run mojo run tests/test_bwtree.mojo

# Epoch manager tests
pixi run mojo run tests/test_epoch.mojo

# Exponential backoff tests
pixi run mojo run tests/test_backoff.mojo

# Integrated BW-Tree tests
pixi run mojo run tests/test_integrated.mojo
```

### Run Benchmarks

```bash
pixi run mojo run benchmarks/bench_basic_ops.mojo
```

## Development Workflow

### Option 1: Using pixi run (Recommended)

```bash
# Run any Mojo file
pixi run mojo run path/to/file.mojo

# Check code
pixi run mojo --version
```

### Option 2: Activate Shell Session

```bash
# Enter pixi environment
pixi shell

# Now you can use mojo directly
mojo run tests/test_atomic.mojo
mojo --version

# Exit when done
exit
```

## Project Structure

```
bw-tree/
├── pixi.toml          # Pixi project configuration (if exists)
├── pixi.lock          # Locked dependencies (auto-generated)
├── src/               # BW-Tree implementation
├── tests/             # Test suites (38 test cases)
├── benchmarks/        # Performance benchmarks
└── ai/                # Documentation and session notes
```

## Common Commands

```bash
# Update pixi
pixi self-update

# Install/update project dependencies
pixi install

# Add a new dependency
pixi add <package>

# Run Mojo REPL
pixi run mojo

# List installed packages
pixi list
```

## Troubleshooting

### "mojo: command not found"

Make sure you're using `pixi run`:
```bash
pixi run mojo --version
```

Or activate the shell first:
```bash
pixi shell
mojo --version
```

### Pixi not found after installation

Restart your shell or source your profile:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Channel errors

Ensure default channels are configured:
```bash
cat $HOME/.pixi/config.toml
# Should show: default-channels = ["https://conda.modular.com/max-nightly", "conda-forge"]
```

## Next Steps

1. ✅ Install pixi
2. ✅ Configure channels
3. ✅ Run `pixi install`
4. ✅ Verify with `pixi run mojo --version`
5. Run tests to validate implementation
6. Run benchmarks to measure performance
7. Start developing!

## Resources

- Pixi Documentation: https://pixi.sh/latest/
- Mojo with Pixi: https://docs.modular.com/pixi/
- Mojo Manual: https://docs.modular.com/mojo/manual/
- Project Documentation: `ai/MOJO_REFERENCE.md`
