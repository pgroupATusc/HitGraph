# What is this repository for?
HitGraph, an FPGA framework to accelerate graph processing based on the edge-centric paradigm. HitGraph takes in an edge-centric graph algorithm and hardware resource constraints, determines design parameters and then generates a Register Transfer Level (RTL) FPGA design. This makes accelerator design for various graph analytics transparent and
user-friendly by masking internal details of the accelerator design process. HitGraph enables increased data reuse and parallelism through novel algorithmic optimizations: <br />
(1) an optimized data layout that reduces non-sequential external memory accesses <br />
(2) an efficient update merging and filtering scheme to reduce the data communication between the FPGA and external memory <br />
(3) a partition skipping scheme to reduce redundant edge traversals for non-stationary graph algorithms. <br /> <br />
Based on our design methodology, we accelerate Sparse Matrix Vector Multiplication (SpMV), PageRank (PR), Single Source Shortest Path (SSSP), and Weakly Connected Component (WCC).
We have used Intel Stratix 10 1SX280LH3F55I3XG to conduct our experiments. <br /> <br />
Find the paper on https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8685122 <br />
FPGA baseline is "ForeGraph: Exploring Large-scale Graph Processing on Multi-FPGA Architecture (https://web.cs.ucla.edu/~chiyuze/pub/fpga17.pdf) and "GraphOps: A dataflow library for graph analytics acceleration" (https://dl.acm.org/doi/pdf/10.1145/2847263.2847337) <br />
# Definition of inputs and outputs
![hit](https://user-images.githubusercontent.com/58924633/85347795-8a8c9680-b4ae-11ea-9f91-51bd60abe20e.PNG)
The hitgraph_2018_processing core contains algorithm implementations which is shown in the yellow part above.
An assumption here is that input and output data are stored in the internal memory before being loaded into algorithm core. 
# Directory Structure
  Algorithm Processing Core: include 4 algorithm processing cores for Sparse Matrix-Vector Multiplication (SpMV), PageRank (PR), Weakly Connected Component (WCC), Single Source Shortest Path (SSSP). Make each module as the top module while running each algorithm.
IP core template generate by Intel Quartus 20.1 for reference
# IP core setting:
  IP catalog => basic function => floating point function => named this function add => in Functionality choose Generate Enable and generate HDL;
  
  IP catalog =>  basic function => choose arithmetic => floating point function=> named this function mult => in Functionality choose Generate Enable and generate HDL
