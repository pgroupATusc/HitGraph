# Purpose of the project
HitGraph, an FPGA framework to accelerate graph processing based on the edge-centric paradigm. HitGraph takes in an edge-centric graph algorithm and hardware resource constraints, determines design parameters, and then generates a Register Transfer Level (RTL) FPGA design. This makes accelerator design for various graph analytics transparent and
user-friendly by masking internal details of the accelerator design process. HitGraph enables increased data reuse and parallelism through novel algorithmic optimizations: <br />
(1) an optimized data layout that reduces non-sequential external memory accesses <br />
(2) an efficient update merging and filtering scheme to reduce the data communication between the FPGA and external memory <br />
(3) a partition skipping scheme to reduce redundant edge traversals for non-stationary graph algorithms. <br /> <br />
Based on our design methodology, we accelerate Sparse Matrix-Vector Multiplication (SpMV), PageRank (PR), Single Source Shortest Path (SSSP), and Weakly Connected Component (WCC).
We use **Intel Stratix 10 1SX280LH3F55I3XG** to conduct our experiments. <br /> <br />
**Find the paper on https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8685122** <br /> <br />
We used "ForeGraph: Exploring Large-scale Graph Processing on Multi-FPGA Architecture (https://web.cs.ucla.edu/~chiyuze/pub/fpga17.pdf) and "GraphOps: A dataflow library for graph analytics acceleration" (https://dl.acm.org/doi/pdf/10.1145/2847263.2847337) for baseline comparisons <br />

# Hardware/Tools
1. Targeted FPGA: Intel Stratix 10 1SX280LH3F55I3XG <br />
2. Tools: Intel Quartus 20.1 <br />

# Definition of inputs and outputs
![hit](https://user-images.githubusercontent.com/58924633/85347795-8a8c9680-b4ae-11ea-9f91-51bd60abe20e.PNG)
<br /> The hitgraph core contains the implementations of graph algorithms discussed in the paper (shown in yellow).
We have assumed that partial input and output data are stored in the internal memory before loaded into algorithm core (Refer to the above figure). 

# Directory Structure
### Algorithm Processing Core: 
include 4 algorithm processing cores for Sparse Matrix-Vector Multiplication (SpMV), PageRank (PR), Weakly Connected Component (WCC), Single Source Shortest Path (SSSP). Make each module as the top module while running each algorithm. IP core template generate by Intel Quartus 20.1 for reference <br />
### test_tb:
Contains unit test benches for the core modules. <br />
test_config_1_1 folder contains complete testing flow for the configuration of 1 partition with 1 pipeline  <br />

# Configuring IP Cores:
#### Floating point adder
Find: IP catalog =>  basic function => arithmetic => floating point function <br />
Name: add <br />
Other Info: choose Generate Enable and generate HDL <br />
#### Floating point mult  
Find: IP catalog =>  basic function => arithmetic => floating point function <br />
Name: mult <br />
Other Info: In Functionality choose Generate Enable and generate HDL <br />
#### Template of these IP cores can be found in IP core template <br />

# Setting up the projects
1. Create a new project using Intel Quartus 20.1 and use Intel Stratix 10 1SX280LH3F55I3XG as the targeted device <br />
2. Include project files in algorithm_processing_core folder <br />
3. Select the top module based on which algorithm to run on hardware <br />
3. Set up IP cores as mentioned in "IP cores Configurations" <br />
4. Run synthesis <br />
5. For simulating internal modules (Unit tests), use test benches in test_tb folder <br />
