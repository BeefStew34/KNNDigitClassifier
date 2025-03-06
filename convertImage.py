from PIL import Image
import sys

im = Image.open(sys.argv[1]).convert('L')

assert(im.size == (28,28))

grey = list(im.getdata())
binStr = ""

outputFile = open("./"+sys.argv[2], "wb")
for idx,i in enumerate(grey):
    outputFile.write((255-i).to_bytes())

