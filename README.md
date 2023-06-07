# COSE321_CSD_PROJECT
This project is the result of the 2023 spring semester computer system design course.

## Video explanation of DEMO & implementation
**A description of the result can be found at the link below.**

https://www.youtube.com/watch?v=1kRinNZsq4o&list=PLkUdclR-c5pBmDb7PSEWSIAuHACW2VTvE&index=7

## Slide
![Project_1](https://github.com/SonHyegang/COSE321_CSD_PROJECT/assets/53131824/99a01a01-e2f2-439c-b4dd-1618eb2c72c8)
![Project_2](https://github.com/SonHyegang/COSE321_CSD_PROJECT/assets/53131824/ad8ef288-9cdc-455a-9254-5ffda93160e8)
![Project_3](https://github.com/SonHyegang/COSE321_CSD_PROJECT/assets/53131824/0623a527-7ef4-4cff-ada5-2ef4049abfcb)
![Project_4](https://github.com/SonHyegang/COSE321_CSD_PROJECT/assets/53131824/0bd0c7fc-140b-4552-8493-1ae6e4e71e85)
![Project_5](https://github.com/SonHyegang/COSE321_CSD_PROJECT/assets/53131824/4ba85ceb-5a47-4811-9fa1-2c5089e888d7)

## Environment
- Zedboard (http://www.zedboard.org/ ) as a hardware platform where the Xilinx Zynq-7000 device is mounted
  - The Zynq-7000 contains 2 big components: PS (Processing System) and PL (Programmable Logic, which is FPGA fabric). The PS has dual-core Cortex-A9s and many peripheral components. In the PL FPGA fabric, you can design and download your own hardware components. So, the Zynq-7000 is essentially a complete computer system with additional capability (custom hardware design). 
  - PS was utilized in this project along with ARM assembly and C code.
- We used two CAD tools: Vivado (v21.1) and Vitis (v21.1). Vivado Hardware systems can be built very quickly thanks to the GUI environment. For software development, High-level details of the designed hardware system, such as the base addresses of peripherals Vitis, an Eclipse-based environment. Therefore, Vitis is mainly used for hardware downloads and Connect our software to the Zynq-7000 and memory and debug the software programs you write.
