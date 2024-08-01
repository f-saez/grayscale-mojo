from pathlib import Path
from ppm import Image
from math import cbrt, sqrt
from helpers import set_extension
from algorithm import parallelize

@value
struct Filter:
	var value : Int

	@staticmethod
	fn none() -> Self:
		return Self(0)

	@staticmethod
	fn red() -> Self:
		return Self(1)

	@staticmethod
	fn red_yellow() -> Self:
		return Self(2)

	@staticmethod
	fn yellow() -> Self:
		return Self(3)

	@staticmethod
	fn green_yellow() -> Self:
		return Self(4)

	@staticmethod
	fn green() -> Self:
		return Self(5)

	@staticmethod
	fn blue_green() -> Self:
		return Self(6)

	@staticmethod
	fn blue() -> Self:
		return Self(7)

	@staticmethod
	fn purple() -> Self:
		return Self(8)

struct Grayscale:
	var _num_threads : Int

	fn __init__(inout self):
		self._num_threads = 8
	
	@always_inline
	fn set_num_threads(inout self, num_threads : Int):
		if num_threads>0 and num_threads<1024:
			self._num_threads = num_threads

	@always_inline
	fn get_num_threads(self) -> Int:
		return self._num_threads
	
	fn rec709(self, img : Image) -> Image:
		var coef = SIMD[DType.int32,4](218, 732, 74, 0)
		return self.process_4xu8_(img, coef)

	fn panchromatic(self,img : Image, filter : Filter) -> Image:
		var coef = SIMD[DType.int32,4](341, 341, 342, 0)
		if filter.value==Filter.red().value:
			coef = SIMD[DType.int32,4](1008, 17, -1, 0)
		elif filter.value==Filter.red_yellow().value:
			coef = SIMD[DType.int32,4](783, 259, -18, 0)
		elif filter.value==Filter.yellow().value:
			coef = SIMD[DType.int32,4](585, 432, 7, 0)		
		elif filter.value==Filter.green_yellow().value:
			coef = SIMD[DType.int32,4](402, 511, 111, 0)
		elif filter.value==Filter.green().value:
			coef = SIMD[DType.int32,4](178, 727, 119, 0)
		elif filter.value==Filter.blue_green().value:
			coef = SIMD[DType.int32,4](30, 575, 419, 0)
		elif filter.value==Filter.blue().value:
			coef = SIMD[DType.int32,4](0, 54, 970, 0)
		elif filter.value==Filter.purple().value:
			coef = SIMD[DType.int32,4](585, 22, 417, 0)	
		return self.process_4xu8_(img, coef)
	
	fn hyper_panchromatic(self, img : Image, filter : Filter) -> Image:
		var coef = SIMD[DType.int32,4](420, 256, 348, 0)
		if filter.value==Filter.red().value:
			coef = SIMD[DType.int32,4](1012, 13, -1, 0)
		elif filter.value==Filter.red_yellow().value:
			coef = SIMD[DType.int32,4](867, 177, -20, 0)
		elif filter.value==Filter.yellow().value:
			coef = SIMD[DType.int32,4](714, 305, 5, 0)	
		elif filter.value==Filter.green_yellow().value:
			coef = SIMD[DType.int32,4](532, 370, 122, 0)
		elif filter.value==Filter.green().value:
			coef = SIMD[DType.int32,4](275, 588, 161, 0)
		elif filter.value==Filter.blue_green().value:
			coef = SIMD[DType.int32,4](42, 494, 488, 0)
		elif filter.value==Filter.blue().value:
			coef = SIMD[DType.int32,4](0, 39, 985, 0)
		elif filter.value==Filter.purple().value:
			coef = SIMD[DType.int32,4](623, 15, 386, 0)	
		return self.process_4xu8_(img, coef)

	fn orthochromatic(self, img : Image, filter : Filter) -> Image:
		var coef = SIMD[DType.int32,4](0, 430, 594, 0)
		if filter.value==Filter.red().value:
			coef = SIMD[DType.int32,4](0, 1024, 0, 0)
		elif filter.value==Filter.red_yellow().value:
			coef = SIMD[DType.int32,4](0, 1024, 0, 0)
		elif filter.value==Filter.yellow().value:
			coef = SIMD[DType.int32,4](0, 997, 27, 0)
		elif filter.value==Filter.green_yellow().value:
			coef = SIMD[DType.int32,4](0, 838, 186, 0)
		elif filter.value==Filter.green().value:
			coef = SIMD[DType.int32,4](0, 846, 178, 0)
		elif filter.value==Filter.blue_green().value:
			coef = SIMD[DType.int32,4](0, 454, 570, 0)
		elif filter.value==Filter.blue().value:
			coef = SIMD[DType.int32,4](0, 37, 987, 0)
		elif filter.value==Filter.purple().value:
			coef = SIMD[DType.int32,4](0, 37, 987, 0)	
		return self.process_4xu8_(img, coef)

	fn pseudo_infrared(self, img : Image) -> Image:
		var coef = SIMD[DType.int32,4](-287, 1433, -122)	
		return self.process_4xu8_(img, coef)
	
	fn luminance(self, img : Image, filter : Filter) -> Image:
		var coef = SIMD[DType.int32,4](307, 604, 113, 0)
		if filter.value==Filter.red().value:
			coef = SIMD[DType.int32,4](992, 32, 0, 0)
		elif filter.value==Filter.red_yellow().value:
			coef = SIMD[DType.int32,4](571, 479, -26, 0)
		elif filter.value==Filter.yellow().value:
			coef = SIMD[DType.int32,4](371, 678, -25, 0)			
		elif filter.value==Filter.green_yellow().value:
			coef = SIMD[DType.int32,4](257, 765, 2, 0)
		elif filter.value==Filter.green().value:
			coef = SIMD[DType.int32,4](99, 914, 11, 0)
		elif filter.value==Filter.blue_green().value:
			coef = SIMD[DType.int32,4](24, 897, 103, 0)
		elif filter.value==Filter.blue().value:
			coef = SIMD[DType.int32,4](0, 422, 602, 0)
		elif filter.value==Filter.purple().value:
			coef = SIMD[DType.int32,4](848, 38, 138, 0)
		return self.process_4xu8_(img, coef)

	fn process_4xu8_(self,  img : Image, coef : SIMD[DType.int32,4]) -> Image:
		var stride = img.get_stride()
		var height = img.get_height()
		var width = img.get_width()
		var result = Image.new(width, height, img.get_bpp())
		@parameter
		fn process_line(y : Int):	
			var idx = y*stride			
			for _ in range(width):
				var rgb_src = img.pixels.load[width=4](idx)
				var rgb = rgb_src.cast[DType.int32]()
				rgb *= coef
				var gray = rgb.reduce_add[size_out=1]()
				gray = gray >> 10
				var g = gray.clamp(0,255).cast[DType.uint8]()
				var dst = SIMD[DType.uint8,4](g[0], g[0], g[0], rgb_src[3])
				result.pixels.store[width=4](idx, dst)
				idx += 4
			
		parallelize[process_line](height, self.get_num_threads() )

		return result