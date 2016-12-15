##Digital Filters and Audio Effects on the DE2-115 FPGA

###Description

###Background Information
---
Audio is often transmitted as an **analog signal**. The DE2-115 board is equipped with several **3.5mm audio connectors** that can be utilized to input and output analog audio from the board. These are the same kind connectors running the same kinds of **analog audio signals** you'd find on a laptop or phone. The first step to applying effects to audio is getting the audio to the FPGA. When a source of audio is connected to the **Line-in audio jack**, it's sending an analog signal. Now, the FPGA can only work with **digital signals**. This means the signal is represented as a stream of binary numbers. Each of these numbers is called a **sample**. This is where the **Wolfson WM8731** IC (integrated circuit) comes into play. This IC has the ability to convert an analog signal to the stream of digital samples the FPGA can use. These samples don't stay on the FPGA for long. As soon as the FPGA modifies them, using something called a **digital filter**,  they're sent back to the **Wolfson** IC. The IC then converts these digital samples back to an analog signal and sends the signal to the **Line-out audio jack**. From there, any standard audio output device such as headphones or speakers can be connected to hear the modified sound.



###The Design
---
When the Wolfson IC is powered on, it's not ready to send and receive digital audio samples. It has to be **initialized** by the FPGA. So, the first step in implementing the project was understanding how to make the FPGA talk to the **Wolfson** IC. In general, are many different **protocols** that IC's use to talk to each other. These are equivalent to the different spoken lanuages that exist throughout the world. The Wolfson IC only understands a protocol called **I<sup>2</sup>C**, which stands for **inter-integrated circuit**. In order for the FPGA to talk to the Wolfson, it had to be taught how to speak I<sup>2</sup>C.

####I<sup>2</sup>C

Here is a brief overview on how I<sup>2</sup>C works. The protocol requires two connections between the FPGA and the Wolfson IC: a **data line (SDIN)** and a **serial clock line (SCLK)**. The Wolfson is specified as a **slave only device**, meaning it just listens to what it's told to do. This means the FPGA will do most all the talking. The FPGA will write 
![A diagram of the protocol](http://i.imgur.com/2imuBRP.png)
######A diagram of the I<sup>2</sup>C protocol taken from the Wolfson's datasheet
