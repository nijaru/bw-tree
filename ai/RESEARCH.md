# Research Findings Index

Index of research findings for BW-Tree implementation. Detailed research stored in `ai/research/` subdirectory.

## Active Research

| Topic | Status | Location | Key Findings |
|-------|--------|----------|--------------|
| Mojo v0.25.6+ semantics | Complete | `MOJO_REFERENCE.md` | Copyability model changed, SIMD comparison updated |
| Atomic operations API | Complete | `MOJO_REFERENCE.md` | CAS, fetch_add, memory orderings available |

## Research Needed

| Topic | Priority | Rationale |
|-------|----------|-----------|
| Epoch-based reclamation in Mojo | High | Memory safety for delta chain traversal |
| SIMD binary search benchmarks | Medium | Validate 2-4x performance claims |
| Mojo version management | Low | Ensure reproducible builds |
| ABA problem mitigation | High | CAS correctness in pointer recycling |

## Key Papers/References

| Title | Relevance | Notes |
|-------|-----------|-------|
| "The Bw-Tree: A B-tree for New Hardware Platforms" | Core design | Levandoski et al., 2013 - original paper |
| "Building a Bw-Tree Takes More Than Just Buzz Words" | Implementation pitfalls | Wang et al., 2018 - practical insights |

## External Documentation

| Source | Purpose | URL |
|--------|---------|-----|
| Mojo stdlib | Atomic operations reference | `modular/modular/mojo/stdlib/` |
| Mojo changelog | Track breaking changes | `modular/modular/mojo/docs/changelog-released.md` |
| Mojo Manual | Language semantics | https://docs.modular.com/mojo/manual/ |

## Implementation Patterns

### From Other Languages

**Rust crossbeam-epoch:**
- Pattern: Thread-local epoch counters, deferred garbage collection
- Applicability: Can translate to Mojo with atomic primitives

**C++ folly AtomicHashMap:**
- Pattern: Lock-free hash table with CAS-based updates
- Applicability: Similar CAS patterns applicable to BW-Tree

## Findings Log

### 2025-01-15: Mojo v0.25.6 Breaking Changes

**Finding:** Types no longer implicitly copyable by default.

**Impact:** Our `Node` and `PageTable` structs should NOT implement `ImplicitlyCopyable` to prevent accidental copies (which would break atomic semantics).

**Action:** Use `borrowed` and `mut` argument conventions explicitly.

### 2025-01-15: SIMD Comparison Semantics

**Finding:** SIMD now supports both aggregate (`==`) and element-wise (`eq()`) comparisons.

**Impact:** Use element-wise `le()`, `lt()` for vectorized binary search in nodes.

**Action:** Implement SIMD binary search with element-wise comparisons.

### 2025-01-15: Memory Ordering in Mojo Atomics

**Finding:** Mojo supports explicit memory ordering: ACQUIRE, RELEASE, ACQUIRE_RELEASE, SEQUENTIAL.

**Impact:** Must use ACQUIRE for reading delta chains, RELEASE for publishing new deltas.

**Action:** Document memory ordering patterns in code.
