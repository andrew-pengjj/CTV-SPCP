## The CTV-\sqrt{PCP} and CTV-SPCP code

## structure of our code
    - ctv-spcp: the code of our paper
    - data: sample data 
    - Simulation: the simulation and result of Section 4.1
    - utils: some support codes of our paper
    - Demo_of_MSI_denoising.m: the demo of multispectral image denoising
    - Demo_of_Video_Extraction: the demo of Video_Extraction
 
## The result of run "Demo_of_MSI_denoising.m"
    The denoising result (PSNR/SSIM) is:
        Data_size    noise type    \sqrt{PCP}    CTV-\sqrt{PCP}    Time
        100*100*160  g=0.2,s=0.2   26.88/0.9207  24.75/0.9103      20s
    The visual restoration images are obtained by running code.

## The result of run "Demo_of_Video_Extraction.m"
    The foreground extraction result(AUC) is:
        Data_size   noise type \sqrt{PCP} CTV-SPCP CTV-\sqrt{PCP} Time
        144*176*20  g=0.2      0.8064     0.8556   0.8557         5.65s
    The visual restoration images are obtained by running code. 

## The simulation result is placed in Simulation folder.


