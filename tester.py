from subprocess import check_output
import os

testingData= open("./data/t10k-images.idx3-ubyte", "rb").read(-1)
testingLabels = open("./data/t10k-labels.idx1-ubyte", "rb").read(-1)
labelCounter = 8
testingDataCounter = 16

correct = 0
testSampleSize = 200

for i in range(testSampleSize):
    answer = testingLabels[labelCounter]

    with open("./testImage.data", "wb") as buffer:
        buffer.write(testingData[testingDataCounter:testingDataCounter+784])
        size = os.path.getsize("./testImage.data")
    output = check_output(["./program", "./testImage.data"])
    
    if int(output) == answer:
        correct += 1

    labelCounter += 1
    testingDataCounter += 784

print(f"Test Complete with {correct}/{testSampleSize} passed")
