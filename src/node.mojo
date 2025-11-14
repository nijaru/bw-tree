"""BW-Tree node structures with delta chains.

Core data structures for latch-free BW-Tree nodes using atomic operations.
"""

from os.atomic import Atomic, Consistency
from memory import UnsafePointer

# Node types for delta chain
alias NODE_BASE = 0
alias NODE_INSERT = 1
alias NODE_DELETE = 2
alias NODE_SPLIT = 3
alias NODE_MERGE = 4


struct NodeHeader:
    """Header for BW-Tree nodes and delta records.

    Not ImplicitlyCopyable to prevent accidental copies that could
    break delta chain pointer semantics.
    """

    var node_type: Int8
    var key_count: Int32
    var next: UnsafePointer[NodeHeader]  # Next delta or base node

    fn __init__(out self, node_type: Int8):
        self.node_type = node_type
        self.key_count = 0
        self.next = UnsafePointer[NodeHeader]()


struct Node:
    """Base BW-Tree node with sorted keys.

    Uses atomic pointer for latch-free delta chain updates.
    Not ImplicitlyCopyable to prevent accidental copies.
    """

    var header_ptr: Atomic[DType.uint64]  # Atomic pointer to NodeHeader

    fn __init__(out self):
        self.header_ptr = Atomic[DType.uint64](0)

    fn get_header(borrowed self) -> UInt64:
        """Read current header pointer with ACQUIRE ordering.

        ACQUIRE ensures we see all writes that happened-before the store
        that published this pointer value.
        """
        return self.header_ptr.load[ordering=Consistency.ACQUIRE]()

    fn compare_and_swap(
        mut self,
        expected: UInt64,
        desired: UInt64
    ) -> Bool:
        """Atomic CAS operation for delta chain updates.

        Uses default ACQUIRE_RELEASE ordering for CAS:
        - ACQUIRE on success: see all writes before the successful store
        - RELEASE on success: make our writes visible to readers
        """
        var expected_val = expected
        return self.header_ptr.compare_exchange(expected_val, desired)
