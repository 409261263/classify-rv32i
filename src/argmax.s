.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Check for invalid array length
    li t6, 1                     # Minimum valid length is 1
    blt a1, t6, handle_error     # If a1 < 1, handle error

    # Initialize maximum value and index
    lw t0, 0(a0)                 # Load the first element of the array into t0 (current max)
    li t1, 0                     # Initialize t1 as the index of the max value
    li t2, 1                     # t2 = current index counter (starting from 1)

loop_start:
    bge t2, a1, loop_end         # If t2 >= a1, exit the loop

    slli t3, t2, 2               # t3 = t2 * 4 (byte offset for array access)
    add t4, a0, t3               # t4 = a0 + t3 (address of a0[t2])
    lw t5, 0(t4)                 # Load a0[t2] into t5

    # Compare the current value with the maximum
    bgt t5, t0, update_max       # If t5 > t0, update the maximum value
    j continue_loop              # Otherwise, continue to the next element

update_max:
    mv t0, t5                    # Update t0 (current max) with t5
    mv t1, t2                    # Update t1 (index of the max value)

continue_loop:
    addi t2, t2, 1               # Increment t2 (index counter)
    j loop_start                 # Continue the loop

loop_end:
    mv a0, t1                    # Move the index of the maximum value to a0
    ret                          # Return to the caller

handle_error:
    li a0, 36                    # Load error code 36 into a0
    jal exit                     # Call global exit to terminate the program
