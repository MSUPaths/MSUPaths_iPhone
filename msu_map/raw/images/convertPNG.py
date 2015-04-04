from PIL import Image
from glob import glob


for imgFile in glob("./*.png"):
    try:
        img = Image.open(imgFile)
        img.save(imgFile,"PNG")
    except IOError, msg:
        print "Fail at: ", imgFile, " :", msg
