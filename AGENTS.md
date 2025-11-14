# BW-Tree Storage Engine - Project Overview

## Vision

Research-grade latch-free BW-Tree storage engine exploring modern concurrency primitives and SIMD optimization in Mojo.

## Objectives

| Goal | Approach |
|------|----------|
| Latch-free concurrency | Atomic CAS operations on delta chains |
| High performance | SIMD optimization (2-4x gains for key ops) |
| MVCC semantics | Snapshot isolation with version chains |
| Write efficiency | Value separation (WiscKey-style vLog) |
| Durability | WAL with group commit |

## Non-Goals

| What | Why |
|------|-----|
| Production use (immediate) | Experimental/research focus |
| SQL layer | Key-value interface only |
| Vector database workloads | seerdb optimized for that |

## Architecture

**Core:** BW-Tree with delta chains, page table, MVCC
**Storage:** Value log (vLog) for large values, inline for small
**Durability:** WAL with group commit
**Background:** Consolidation, GC, checkpointing

See [ai/design/architecture.md](ai/design/architecture.md) for details.

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Language | Mojo 0.25.6+ | First-class SIMD, atomic primitives |
| Atomics | `stdlib/os/atomic.mojo` | CAS, memory ordering (acquire/release) |
| SIMD | `SIMD[DType, width]` | Vectorized key comparison, checksums |
| Testing | `mojo run tests/` | Unit and concurrency tests |
| Benchmarking | Custom harness | Performance validation |
| Version Manager | `mise` | Mojo version management |

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `src/` | Core BW-Tree implementation |
| `tests/` | Unit and integration tests |
| `benchmarks/` | Performance benchmarks |
| `ai/` | **AI session context** - Agent workspace for state across sessions |
| `docs/` | User documentation (future) |

### AI Context Organization

**Purpose:** AI agents use `ai/` to maintain continuity between sessions.

**Session files** (ai/ root - read every session):

| File | Purpose | Guidelines |
|------|---------|------------|
| `STATUS.md` | Current state, blockers | Read FIRST. Current/active only, no history |
| `TODO.md` | Active tasks | No "Done" sections, current work only |
| `DECISIONS.md` | Active architectural decisions | Superseded → ai/decisions/ |
| `RESEARCH.md` | Research findings index | Details → ai/research/ |

**Reference files** (subdirectories - loaded only when needed):

| Directory | Purpose |
|-----------|---------|
| `ai/research/` | Detailed research findings |
| `ai/design/` | Design specifications |
| `ai/decisions/` | Superseded/split decisions |

**Principle:** Session files kept current/active only for token efficiency. Detailed content in subdirectories loaded on demand. Historical content pruned (git preserves all history).

## Development Workflow

| Activity | Practice |
|----------|----------|
| Testing | TDD for complex concurrency logic |
| Commits | Frequent commits, regular pushes |
| State tracking | ai/ files (STATUS, TODO, DECISIONS) |
| Documentation | Update ai/STATUS.md every session with learnings |

## Performance Targets

**Initial (Phase 0-1):**
- Establish baseline concurrent insert/lookup throughput
- Validate SIMD gains (2-4x for key comparison)

**Later phases:**
- Compare vs RocksDB, seerdb on point operations
- Measure write amplification vs traditional B-tree

## Commands

### Build and Test

```bash
# Run all tests
mojo run tests/test_atomic.mojo

# Run specific test
mojo run tests/test_node.mojo

# Run benchmarks (future)
mojo run benchmarks/basic_ops.mojo
```

### Development

```bash
# Check Mojo version
mojo --version  # Requires 0.25.6+

# Install/update Mojo
mise install mojo

# Format code (future - when mojo fmt available)
# mojo fmt src/
```

## Code Standards

### Mojo-Specific

| Standard | Rule | Example |
|----------|------|---------|
| **Atomics** | Use explicit memory ordering | `atom.load[ordering=Consistency.ACQUIRE]()` |
| **SIMD** | Explicit width for clarity | `SIMD[DType.int64, 4]` not magic numbers |
| **Pointers** | Prefer `UnsafePointer[T]` | Type-safe over raw addresses |
| **Ownership** | Use `owned`, `borrowed` | Explicit lifetime semantics |
| **Inlining** | `@always_inline` for hot paths | Key comparison, CAS loops |

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Structs | PascalCase | `PageTable`, `NodeHeader` |
| Functions | snake_case | `compare_and_swap()` |
| Constants | UPPER_SNAKE | `NODE_BASE`, `MAX_CHAIN_LENGTH` |
| Type aliases | PascalCase | `alias NodeType = Int8` |

### Comments

- Only WHY, never WHAT
- No change tracking, no TODOs
- Document non-obvious concurrency decisions

```mojo
# Good: Explains rationale
# Use RELEASE ordering to ensure delta chain visible before CAS
atom.store[ordering=Consistency.RELEASE](new_ptr)

# Bad: Narrates code
# Store new pointer to atom
atom.store(new_ptr)
```

## Current Status

**Phase:** Foundation (0.0.1)

See [ai/STATUS.md](ai/STATUS.md) for current state, blockers, and recent learnings.

## References

- "The Bw-Tree: A B-tree for New Hardware Platforms" (Levandoski et al., 2013)
- "Building a Bw-Tree Takes More Than Just Buzz Words" (Wang et al., 2018)
- Mojo atomic stdlib: `modular/mojo/stdlib/stdlib/os/atomic.mojo`

## License

Elastic License 2.0 - Source-available, free to use/modify, cannot resell as managed service.
