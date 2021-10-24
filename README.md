This is an adder module for the Floating point numbers in IEEE 754 Format. The adder is divided into sub-blocks which compute the result of each addition in four clock cycles. This module can thus be put into a pipelined structure, and as the logic is distributed into different clock cycles thus the overall delay of the circuit reduces. 
The module is supported with System Verilog Verification files for each of the individual modules and the overall module as well. The input is randomly generated, with the constraints on the randomness and thus a proper verification of the modules can be performed. 
The design is sysnthesized with Yosys, and the report is included here.
It can be accessed at the EDA Playground [link](https://www.edaplayground.com/x/KPML).
