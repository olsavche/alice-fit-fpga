
# Links from DCS team 
[Description of FRED tester created by Franciszek]([https://codimd.web.cern.ch/s/tKVDF5qcU](https://codimd.web.cern.ch/s/tKVDF5qcU) 
# 40 Mhz Clock distribution  
##  Clock distribution scheme - CERN lab 
- ![scheme](attached%20files/40_Mhz_Clock_distribution.svg)
- ![photo](attached%20files/40_Mhz_Clock_distribution_photo.svg)
## Clock distribution scheme - AGH lab 
- ![scheme](attached%20files/Agh_clock_scheme.svg)
- ![photo](attached%20files/AGH_lab_clock.svg)
# TCM

## ![LED Indicators Updated](attached%20files/image-4.png)
## IPBUS-GMII mezzanine 
### ![Power connection ](attached%20files/image.png)
### SFP 
- ![For fiber optics](attached%20files/image-1.png)
- ![For copper](attached%20files/image-2.png)
### How to set up IP on TCM [console](attached%20files/cons.jpeg)
- Connect RJ-45 cable to the TCM [console](attached%20files/cons.jpeg) using putty, for example, select COM and a speed - 115200.
- Check the connection by entering the command - [RS](attached%20files/image-3.png)
- To set the IP, use the command - SI 192.168.88.25 (replace with your IP)
	- response - OK or Syntax error 
- After setting the IP, enter the command to save the settings -WR
	- response - OK or Syntax error
# FLP/CRU configuration 

## Configuration 
o2-roc-config --id #0 --clock=TTC --pon-upstream --dyn-offset --onu-address=1 --gbtmux=SWT --datapathmode=PACKET --gbtmode=GBT --links=11 --force --bypass 
![Configuration screen](attached%20files/image-6.png)
## roc-status --i=#0 
- Use the command roc-status --i=#0 to check if our configuration is working. -  ./o2-roc-config
 ![roc-status --i=#0 screen](attached%20files/image-5.png)
# LTU

## Configuration 
- [copied from CERN materials ](attached%20files/image-7.png)

# Converter

## REG_102
## TCM scheme 
![TCM scheme ](attached%20files/TCM.svg)
### REG_102 bit description 

| Bit | Description             | Value meaning        | Type | Access        |
| --- | ----------------------- | -------------------- | ---- | ------------- |
| B0  | link used               | (0 - IPbus, 1 - GBT) | reg  | read only     |
| B1  | translator error        | (0 - OK, 1 - Error)  | reg  | read only     |
| B2  | GBT communication error | (0 - OK, 1 - Error)  | reg  | read only     |
| B3  | switch to GBT           | —                    | cmd  | read always 0 |
| B4  | IPbus error             | (0 - OK, 1 - Error)  | reg  | read only     |
| B5  | switch to IPbus         | —                    | cmd  | read always 0 |

# RS Bag 

![](attached%20files/image-8.png)

