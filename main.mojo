
from pathlib import Path
from grayscale import Grayscale, Filter
from ppm import Image
from time import now
from testing import assert_equal

def main():

    img = Image.from_ppm(Path("validation/woman.ppm")) 

    grayscale = Grayscale()

    x = grayscale.rec709(img)
    _ = x.to_ppm(Path("1-rec709"))

    x = grayscale.panchromatic(img, Filter.yellow())
    _ = x.to_ppm(Path("2-panchromatic"))

    x = grayscale.hyper_panchromatic(img, Filter.blue())
    _ = x.to_ppm(Path("3-hyper_panchromatic"))    

    x = grayscale.orthochromatic(img, Filter.green_yellow())
    _ = x.to_ppm(Path("4-orthochromatic"))        

    x = grayscale.pseudo_infrared(img)
    _ = x.to_ppm(Path("5-pseudo_infrared")) 

    x = grayscale.luminance(img, Filter.red_yellow())
    _ = x.to_ppm(Path("6-luminance"))         