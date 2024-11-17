# Assignment 2: Classify

## `abs`


The purpose of this code is to take a number stored in memory, accessed via a pointer, and convert it to its absolute value. Basically, it loads the number into a register, checks if it's negative, and if so, subtracts it from 0 to make it positive. Finally, it writes the result back to the original memory location. 

## `argmax`

This code is designed to find the index of the first occurrence of the maximum value in an integer array (0-based index). It scans through the array, keeping track of the current maximum value and its index. If a larger value is encountered, it updates both the maximum value and its index. If the same maximum value appears again, it retains the smaller index since this is the "first occurrence."

The program begins by checking if the array length is less than 1. If this condition is met, it jumps to handle_error, terminates execution with an error code of 36, and ensures that the array contains at least one element.

Next, during initialization, the first element of the array is treated as the "current maximum value," with its index set to 0. The program then starts scanning from the second element. During the scan, it compares the current value to the maximum value. If a larger value is found, it updates both the "maximum value" and the "index of the maximum value." Once the loop completes, the index of the maximum value is stored in a0, and the function returns this result.


## `classify`

This code is a neural network classifier implemented in RISC-V assembly. Its purpose is to read pretrained weight matrices and input data, perform matrix operations for forward propagation, and output a classification result (the index of the maximum value in the output matrix).

At the beginning, the program checks the number of input arguments. If the number is less than 5, it directly jumps to error_args and terminates execution. This ensures that subsequent operations will not fail due to insufficient arguments, enhancing the program's stability.

During initialization, the program saves the state of all registers and allocates additional space on the stack to store matrix data (row and column information and pointers). This design guarantees context consistency during computations, even with nested function calls, ensuring that the original data remains intact.

Next, the program starts reading the pretrained matrices m0 and m1, along with the input matrix input. For each read operation, it first allocates memory to store the row and column sizes of the matrix, then calls the read_matrix function to load the actual data into memory. These matrices are the core data for forward propagation computations. After reading, the matrices are stored in specific registers (e.g., s0 holds the contents of m0, and s1 holds m1).

The hidden layer computation begins with matrix multiplication. The program computes h=m0×input
,simulating the first layer of weight operations in a neural network. The result is stored in memory pointed to by s9. Next, the ReLU function is applied to the hidden layer result h. ReLU is a commonly used activation function in neural networks that sets negative values in the matrix to 0 while keeping non-negative values unchanged. This step ensures the non-linear properties of the hidden layer output.

The output layer computation is similar to the hidden layer. The program calculates 
o =m1×h, simulating the second layer's computation, with the final result stored in s10. After all matrix operations are complete, the program uses the argmax function to find the index of the maximum value in the output matrix, which represents the classification result.

If the user has not enabled silent mode (i.e., a2 != 0), the program prints the classification result. Otherwise, it directly stores the result in the return register a0 for the caller to use.



## `dot`

This code implements a strided dot product calculator that computes the dot product of two integer arrays, allowing the user to specify the stride (step size) for accessing elements in each array. It includes input validation, error handling, and an embedded subroutine for signed integer multiplication.

The program starts by validating the input arguments. It first ensures that the number of elements to process is at least 1 and that the strides for both arrays are greater than or equal to 1. If any of these conditions are not met, the program jumps to the corresponding error-handling routine and terminates execution.

If the inputs are valid, the program initializes variables: it sets the dot product accumulator to 0 and initializes pointers to the starting positions of the two arrays. The program calculates the byte offsets for the specified strides (since each integer occupies 4 bytes) to correctly skip the desired elements.

In the main loop, the program iteratively reads values from the current positions in the two arrays and calls an embedded multiplication subroutine to compute the product of the two values. The result of the multiplication is added to the dot product accumulator. The program then updates the array pointers using the calculated stride offsets to move to the next positions and decrements the loop counter until all specified elements have been processed.

When the loop completes, the final dot product is stored in the accumulator, which is then moved to the return register a0 for the caller. Before exiting, the program restores the states of all saved registers and releases the stack space used during execution.

The embedded multiplication subroutine performs signed integer multiplication. It begins by checking the signs of the operands and ensures that only positive values are processed during the computation. If an operand is negative, its sign is flipped, and a flag is used to record the expected sign of the final result. The multiplication itself is performed using an iterative addition approach, where the multiplicand is repeatedly added to the result based on the multiplier's value. Once the multiplication is complete, the subroutine adjusts the sign of the result based on the recorded flag and returns the final value.

For error handling, the program assigns distinct error codes for different types of issues. For example, it returns error code 36 if the number of elements is invalid and error code 37 if either stride is invalid, immediately terminating execution in these cases.


## `matmul`


This code implements matrix multiplication in RISC-V assembly, calculating D = M0 x M1 , where \( M0 \) is a matrix of size rows0 x cols0, \( M1 \) is a matrix of size rows1 x cols1, and \( D \) is the result matrix of size rows0 x cols1 . The program includes input validation, matrix multiplication logic, and subroutines for element-wise multiplication and dot product computation.

The program begins with input validation, ensuring that the dimensions of the matrices are valid. It checks that the number of rows and columns for \( M0 \) and \( M1 \) are greater than zero and that the number of columns in \( M0 \) matches the number of rows in \( M1 \). If any of these conditions are not satisfied, the program jumps to an error handling routine and terminates with error code 38.

After validation, the program initializes variables, stores the state of registers on the stack, and sets up pointers to the input matrices and the result matrix. These pointers and dimensions are used throughout the computation.

The matrix multiplication itself is performed using two nested loops. The outer loop iterates through the rows of \( M0 \), and for each row, the inner loop iterates through the columns of \( M1 \). For each combination of a row from \( M0 \) and a column from \( M1 \), the program calculates the dot product using the `dot` subroutine. The result of the dot product is stored in the corresponding position of the result matrix \( D \), and the result pointer is incremented to the next position.

The `dot` function is called to compute the sum of element-wise products between the current row of \( M0 \) and the current column of \( M1 \). This function uses the `multiply_unsigned` subroutine to perform element-wise multiplication of integers. The `multiply_unsigned` subroutine implements multiplication using bitwise operations and iterative addition.

Once all rows and columns are processed, the result matrix \( D \) is complete. The program restores all saved registers, releases stack space, and safely returns control to the caller. Throughout execution, robust error handling ensures that invalid inputs or mismatched dimensions are detected and reported early, maintaining the program's reliability.

This implementation is highly efficient and well-suited for environments such as embedded systems, where low-level control and optimal performance are crucial. Its modular structure, with reusable subroutines for common operations, makes it a flexible and robust solution for matrix multiplication.



## `read_matrix`

This program implements a binary matrix file reader that loads the contents of a binary file storing a matrix into dynamically allocated memory. The function returns a pointer to the allocated memory containing the matrix while also storing the matrix's row and column counts in specified memory addresses.

The program starts by initializing the stack and saving all necessary registers. The addresses for storing the row and column counts are saved in registers s3 and s4, respectively. It then calls the fopen function to open the specified file. If the file cannot be opened, it exits with error code 27.

Once the file is successfully opened, the program uses fread to read the first 8 bytes of the file, which contain the matrix's row and column counts. After a successful read, these values are stored in a stack buffer and then moved to the specified output addresses for rows and columns.

Next, the program calculates the total number of elements in the matrix, which is the product of the row and column counts. Since multiplication instructions are not used in this program, it simulates multiplication by repeatedly adding the column count for each row. After calculating the total number of elements, it multiplies this value by 4 (since each integer occupies 4 bytes) to determine the required memory size for the matrix.

The program then calls malloc to allocate the required memory for the matrix. If memory allocation fails, it exits with error code 26. Once the memory is successfully allocated, it uses fread to load the matrix data from the file into the allocated memory. If any issues occur during this process, it exits with error code 29.

After reading the matrix data, the program calls fclose to close the file. If the file cannot be closed properly, it exits with error code 28. Finally, the pointer to the allocated memory containing the matrix is stored in the return register a0 for the caller to use. Before returning, the program restores the saved registers and releases the stack space.


## `relu`

This program implements the ReLU (Rectified Linear Unit) operation on an integer array, applying the activation function x=max(0,x) to each element in the input array. ReLU is commonly used in neural networks to set all negative values to 0 while keeping positive values unchanged. The operation modifies the input array directly in place.

The program begins by validating the input to ensure that the length of the array (
𝑎
1
a1) is at least 1. If the array length is less than 1, the program jumps to the error-handling section, loads the error code 36 into the return register a0, and calls the exit function to terminate execution. This validation step ensures that subsequent operations are safe and won’t encounter issues due to invalid input.

After initialization, the program enters a loop to process each element of the array. For each iteration, the program calculates the memory address of the current element based on its index, then loads the value into the register t5 for processing. The program checks whether the value is less than 0. If it is, the program sets the value at that address to 0; otherwise, it skips this step and moves on to the next element.

The loop logic includes calculating the memory address of each element, loading its value, and performing the comparison. Once all elements in the array are processed, the program exits the loop and returns control to the caller.

## `write_matrix`

This program implements a function to write a matrix to a binary file, including its dimensions (number of rows and columns) and data. It is implemented in RISC-V Assembly and avoids using direct multiplication instructions, instead simulating the calculation of total elements through addition.

The function begins by initializing the stack, saving the required registers, and allocating sufficient stack space to store intermediate results and states. It then saves the matrix's base address, row count, and column count into registers for use in subsequent operations.

The program opens the specified file using fopen in write mode. If the file cannot be opened, it jumps to the error-handling section and exits with error code 27. Once the file is successfully opened, the program prepares the header information, including the matrix's row and column counts. These values are stored in a buffer and written to the file using fwrite. If the write operation fails, the program jumps to the error-handling section and exits with error code 30.

Next, the program calculates the total number of elements in the matrix. Since multiplication instructions are not used, the program simulates the multiplication of rows and columns by adding the column count repeatedly for each row. This calculates the total number of elements in the matrix.

After calculating the total elements, the program writes the matrix's data to the file using fwrite. It writes data corresponding to the total number of elements. If any errors occur during the write operation, the program jumps to the error-handling section and exits with error code 30. Once the data is successfully written, the program closes the file using fclose. If the file cannot be closed properly, the program jumps to the error-handling section and exits with error code 28.

At the end of the function, the program restores all saved registers, deallocates the stack space, and returns control to the caller. If any errors occur during the process, the program triggers the appropriate error-handling logic, ensuring stability and reliability.


