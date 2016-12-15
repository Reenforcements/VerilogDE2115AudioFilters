

##Digital Filters and Audio Effects on the DE2-115 FPGA

###Description

###Background Information
---
Audio is often transmitted as an **analog signal**. The DE2-115 board is equipped with several **3.5mm audio connectors** that can be utilized to input and output analog audio from the board. These are the same kind connectors running the same kinds of **analog audio signals** you'd find on a laptop or phone. The first step to applying effects to audio is getting the audio to the FPGA. When a source of audio is connected to the **Line-in audio jack**, it's sending an analog signal. Now, the FPGA can only work with **digital signals**. This means the signal is represented as a stream of binary numbers. Each of these numbers is called a **sample**. This is where the **Wolfson WM8731** IC (integrated circuit) comes into play. This IC has the ability to convert an analog signal to the stream of digital samples the FPGA can use. These samples don't stay on the FPGA for long. As soon as the FPGA modifies them, using something called a **digital filter**,  they're sent back to the **Wolfson** IC. The IC then converts these digital samples back to an analog signal and sends the signal to the **Line-out audio jack**. From there, any standard audio output device such as headphones or speakers can be connected to hear the modified sound.



###The Design
---
When the Wolfson IC is powered on, it's not ready to send and receive digital audio samples. It has to be **initialized** by the FPGA. So, the first step in implementing the project was understanding how to make the FPGA talk to the **Wolfson** IC. In general, are many different **protocols** that IC's use to talk to each other. These are equivalent to the different spoken lanuages that exist throughout the world. The Wolfson IC only understands a protocol called **I<sup>2</sup>C**, which stands for **inter-integrated circuit**. In order for the FPGA to talk to the Wolfson, it had to be taught how to speak I<sup>2</sup>C.

####I<sup>2</sup>C

Here is a brief overview on how I<sup>2</sup>C works: The protocol requires two connections between the FPGA and the Wolfson IC: a **data line (SDIN)** and a **serial clock line (SCLK)**. The Wolfson is specified as a **slave only device**, meaning it just listens to what it's told to do. This means the FPGA will do most all the talking. In I<sup>2</sup>C, the data line is shared. One chip will send **8 bits of data**, and then will listen for a **1 bit** reply from the other chip. This single bit reply is called the **ACK bit (acknowledge bit)** and tells the sender that the data was received. The purpose of the clock line is to tell the listening chip exactly when to listen. The listening chip will only read a bit of data when the clock line goes from **low to high**.

![A diagram of the protocol](http://i.imgur.com/2imuBRP.png)
######A diagram of the I<sup>2</sup>C protocol taken from the Wolfson's data sheet

Once a module was created to allow the FPGA to speak I<sup>2</sup>C, the Wolfson IC could then be initialized. The FPGA uses I<sup>2</sup>C to write to the **registers** of the Wolfson IC. These registers are akin to very simple "preferences". The FPGA has to write to these registers to control and initialize things on the Wolfson IC such as digital audio format, which parts of the chip to power up,  when to start listening and converting analog audio to digital, ect.

####Sending and receving audio between the FPGA and the Wolfson

Once the Wolfson IC is initialized, it needs a clock signal so it can start sending and receiving digital audio to and from the FPGA. According to the data sheet, the Wolfson IC can generate its own clock. It was found, however, that the audio chip only seemed to work when a 12.288Mhz clock was generated by the FPGA and sent to the Wolfson on its **AUD_XCK** pin. This clock was generated by the **Audio Clock for DE-series Boards** IP module in Quartus. 

Once the Wolfson IC had a clock, it was able to send and receive digital audio over the appropriate lines. For receiving digital audio samples from the Wolfson's **ADC (analog to digital converter)**, the **AUD_ADCDAT** and **AUD_ADCLRCK** pins were used. For sending digital audio samples to the **DAC (digital to analog converter)**, the **AUD_DACDAT** and **AUD_DACLRCK** pins were used. The Wolfson IC was initialized to used **16 bit audio samples**. This means that in each pair of left and right samples, a total of **32 bits were used**. As shown in the diagram below, the bits are read in one at a time starting with the **most significant bit** and moving towards the **least significant bit**. This is done for the left and right channels in sequence until all the bits are read in.

![Sending and receving audio from the Wolfson IC](http://i.imgur.com/MicVc7Y.png)
######A diagram of sending/receiving digital audio samples from the Wolfson IC, taken from the Wolfson's data sheet
