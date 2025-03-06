# Digit Classifier
A K-Nearest Neighbours hand written digit classifer written in 32-bit x86 NASM assembly.
Utilizes the MNIST hand written digit dataset and euclidean distance to determine its 10 nearest neighbours. 

See Releases for compiled versions.

_Current accuracy 80% on testing data (Custom inputs will vary)_

> [!IMPORTANT]
> ***Usage***
> ```./program ./path_to_data_file```\
>Expects a 784 byte file with 28x28 unsigned grey scale pixels \
>See _Utility Scripts_ to convert an image into expected format

## Prerequisites
* 32 Bit Compatible System
* Python 3.0+ for utility scripts
* gcc (version 14.2.1 Recommended)
* NASM (version 2.16.03 Recommended)
* Any Image Editor

## Utility Scripts
### convertImage.py
Converts any 28x28 image (PNG, JPG) into a grey scale unsigned byte array and writes it to the output file\
  ``` python convertImage.py ./input.png ./output.data```

  
### tester.py
Calculates accuracy based on the first 200 images in the testing file\
``` python tester.py  ```


## Build Instructions
### Method 1 : Compile with Script
Use the build script.\
Make the script executable with
  ```chmod +x build.sh```\
Run the script with
  ```./build.sh```
### Method 2 : Manual Compilation
Compile manually with nasm and gcc \
Compile the assembly\
 ```nasm -f elf main.asm```\
 Link with gcc to create the executable\
 ```gcc -m32 -o program main.o```

