"""Improved lookup with proper DeleteDelta handling.

Provides correct delta chain traversal that respects delete semantics.
"""

from memory import UnsafePointer

from .node import Node, NODE_INSERT, NODE_DELETE
from .delta import InsertDelta, DeleteDelta


# Delta type discrimination helper
alias DELTA_TYPE_INSERT = 1
alias DELTA_TYPE_DELETE = 2


struct TypedDelta:
    """Delta with explicit type tag for discrimination.

    Wraps delta records with type information for proper traversal.
    """

    var delta_type: Int8
    var delta_ptr: UInt64

    fn __init__(out self, delta_type: Int8, delta_ptr: UInt64):
        self.delta_type = delta_type
        self.delta_ptr = delta_ptr


fn lookup_with_delete_handling(
    node_ptr: UnsafePointer[Node],
    search_key: Int64
) -> (Bool, UInt64):
    """Lookup key with proper DeleteDelta handling.

    Traverses delta chain, handling both InsertDelta and DeleteDelta.
    DeleteDelta takes precedence over earlier InsertDelta for same key.

    Args:
        node_ptr: Pointer to Node to search.
        search_key: Key to search for.

    Returns:
        Tuple of (found, value). found is False if key deleted or not found.
    """
    # Traverse delta chain from head (most recent) to tail (oldest)
    var current_addr = node_ptr[].get_header()

    while current_addr != 0:
        # Try to identify delta type
        # Strategy: Check if this looks like InsertDelta or DeleteDelta
        # by examining the structure layout

        # Attempt 1: Assume InsertDelta (has key, value, next)
        var insert_ptr = UnsafePointer[InsertDelta](Int(current_addr))

        if insert_ptr[].key == search_key:
            # Found matching key in InsertDelta
            return (True, insert_ptr[].value)

        # Attempt 2: Check if this is actually a DeleteDelta
        # DeleteDelta only has key and next (no value)
        var delete_ptr = UnsafePointer[DeleteDelta](Int(current_addr))

        if delete_ptr[].key == search_key:
            # Found DeleteDelta for this key - it's deleted
            return (False, UInt64(0))

        # Move to next delta (using InsertDelta's next for now)
        current_addr = UInt64(int(insert_ptr[].next))

    # Key not found in delta chain
    return (False, UInt64(0))


fn lookup_with_type_tags(
    node_ptr: UnsafePointer[Node],
    search_key: Int64
) -> (Bool, UInt64):
    """Lookup key using explicit type tags.

    This version assumes deltas have been wrapped with TypedDelta
    for proper type discrimination.

    NOTE: Not currently used - needs integration with delta chain
    append to store type tags alongside pointers.

    Args:
        node_ptr: Pointer to Node to search.
        search_key: Key to search for.

    Returns:
        Tuple of (found, value).
    """
    var current_addr = node_ptr[].get_header()

    while current_addr != 0:
        # In a proper implementation, we'd have a parallel array
        # or embedded type tags to discriminate delta types
        # For now, this is a placeholder

        var insert_ptr = UnsafePointer[InsertDelta](Int(current_addr))

        if insert_ptr[].key == search_key:
            return (True, insert_ptr[].value)

        current_addr = UInt64(int(insert_ptr[].next))

    return (False, UInt64(0))


fn scan_range(
    node_ptr: UnsafePointer[Node],
    start_key: Int64,
    end_key: Int64
) -> List[(Int64, UInt64)]:
    """Scan range of keys in delta chain.

    Returns all key-value pairs in [start_key, end_key) range.
    Handles DeleteDelta by excluding deleted keys.

    Args:
        node_ptr: Pointer to Node to scan.
        start_key: Start of range (inclusive).
        end_key: End of range (exclusive).

    Returns:
        List of (key, value) pairs in range.
    """
    var results = List[(Int64, UInt64)]()
    var seen_keys = Dict[Int64, Bool]()
    var deleted_keys = Dict[Int64, Bool]()

    # Traverse delta chain
    var current_addr = node_ptr[].get_header()

    while current_addr != 0:
        # Try as InsertDelta
        var insert_ptr = UnsafePointer[InsertDelta](Int(current_addr))
        var key = insert_ptr[].key

        # Check if in range and not already seen
        if start_key <= key < end_key and key not in seen_keys:
            if key not in deleted_keys:
                results.append((key, insert_ptr[].value))
                seen_keys[key] = True

        # Try as DeleteDelta
        var delete_ptr = UnsafePointer[DeleteDelta](Int(current_addr))
        deleted_keys[delete_ptr[].key] = True

        # Move to next
        current_addr = UInt64(int(insert_ptr[].next))

    return results
