# Image Equalization Circuit
## Overview
The program is a `VHDL` implementation of a <b>circuit</b> for the simplified <b>equalization of the histogram of an image</b>, meaning the enhancement of the contrast between its pixels so that the whole 256-bit intensity range is used.

The circuit code was developed for the `Vivado Design Suite` software.

## Project Specifications
The circuit executes a simplified version of the standard image histogram equalization algorithm, as described in the `project_specifications.pdf` document (which also contains an example of the algorithm's execution).

It reads the image from a memory in which it is stored sequentially one pixel (byte) at a time. The maximum size for the image is 128x128 pixels.

The equalized image is then written to memory contiguously after the original image.

## File System Structure
* `benchmarks`: files used in testing the generated circuit's performance in various use cases.
* `old_src`: alternative implementations of the circuit, later discarded but preserved for historical purposes.
* `report`: the report handed in at the end of the project, detailing the structure of the circuit and its performance (in Italian).
* `specifications`: documents detailing the specifications of the project (in Italian).
* `src`: final code implementation of the circuit.