.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================

relu:
    # Validate input: a1 should be ≥ 1
    li t0, 1                # Load 1 into t0 for comparison
    blt a1, t0, return_error # if (a1 < 1) jump to return_error

    # Initialize constants
    li t1, 0                # t1 = 0 (used for ReLU operation)
    li t2, 0                # t2 = 0 (index counter)

loop_start:
    bge t2, a1, relu_exit   # if (t2 ≥ a1) exit loop

    # Load the current element in the array
    slli t3, t2, 2          # t3 = t2 * 4 (byte offset)
    add t4, a0, t3          # t4 = address of a0[t2]
    lw t5, 0(t4)            # load a0[t2] into t5

    # Compare the element with 0
    blt t5, t1, set_zero    # if (t5 < 0) go to set_zero

next_element:
    addi t2, t2, 1          # t2++
    j loop_start            # continue to next iteration

set_zero:
    sw t1, 0(t4)            # set a0[t2] to 0
    j next_element          # go to the next element

return_error:
    li a0, 36               # Load error code 36 into a0
    jal exit                # Call global exit function to terminate

relu_exit:
    ret                     # Return from relu function
