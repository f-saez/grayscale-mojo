
from ppm import Image
from pathlib import Path
from testing import assert_true, assert_equal

from grayscale import Grayscale, Filter

fn almost_equal(a : Image, b : Image) -> Bool:
    """
        Comparing two images, one reference and one created by the same library
        but on a different architecture or a different version or with a different codec could result in
        small and invisible differences
        So to prevent a bunch of troubles, I choose to allow a small percentage of differences.
        something like 2% of the pixels could have a 2% difference.
    """
    var result = False
    var w = a.get_width()
    var h = a.get_height()
    var num_pixels = w*h
    var num_diff = 0
    if w==b.get_width() and h==b.get_height() and a.get_stride()==b.get_stride():
        # a dumb way to do that, but who cares ?
        for y in range(h):
            var idx = y*a.get_stride()
            for x in range(w):
                var delta = abs(a.pixels[idx].cast[DType.int32]() - b.pixels[idx].cast[DType.int32]())
                if delta>=5:
                    num_diff += 1
                else:
                    delta = abs(a.pixels[idx+1].cast[DType.int32]() - b.pixels[idx+1].cast[DType.int32]())
                    if delta>5:
                        num_diff += 1
                    else:                                    
                        delta = abs(a.pixels[idx+2].cast[DType.int32]() - b.pixels[idx+2].cast[DType.int32]())                            
                        if delta>5:
                            num_diff += 1
                        else:                                    
                            delta = abs(a.pixels[idx+3].cast[DType.int32]() - b.pixels[idx+3].cast[DType.int32]())                                
                            if delta>5:
                                num_diff += 1                                                                            
        result = Float32(num_diff) / Float32(num_pixels) <= 0.02
    return result


fn validation() raises :
    var img = Image.from_ppm(Path("validation/woman.ppm")) 

    var grayscale = Grayscale()

    var x = grayscale.rec709(img)
    var y = Image.from_ppm(Path("validation/rec709.ppm")) 
    assert_true( almost_equal(x,y) )

    x = grayscale.panchromatic(img, Filter.yellow())
    y = Image.from_ppm(Path("validation/panchromatic.ppm")) 
    assert_true( almost_equal(x,y) )

    x = grayscale.hyper_panchromatic(img, Filter.blue())
    y = Image.from_ppm(Path("validation/hyper_panchromatic"))    
    assert_true( almost_equal(x,y) )

    x = grayscale.orthochromatic(img, Filter.green_yellow())
    y = Image.from_ppm(Path("validation/orthochromatic"))        
    assert_true( almost_equal(x,y) )

    x = grayscale.pseudo_infrared(img)
    y = Image.from_ppm(Path("validation/pseudo_infrared")) 
    assert_true( almost_equal(x,y) )

    x = grayscale.luminance(img, Filter.red_yellow())
    y = Image.from_ppm(Path("validation/luminance"))    
    assert_true( almost_equal(x,y) )

def main():
    validation()