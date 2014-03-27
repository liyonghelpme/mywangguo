import sys
import os
fn = sys.argv[1]
from PIL import Image
im = Image.open(fn)
red, green, blue, alpha = im.split()
print alpha

#rgb = Image.new("RGB", (im.size[0], im.size[1]))
rgb = Image.merge("RGB", (red, green, blue))
print rgb
#rgb.save('t.png')

nim = Image.new("RGB", (im.size[0], im.size[1]*2))
print nim
nim.paste(rgb, (0, 0, im.size[0], im.size[1]))


p = Image.merge('RGB', (alpha, alpha, alpha))
nim.paste(p, (0, im.size[1], im.size[0], im.size[1]*2))

nim.save(fn)
os.system('etc1tool %s --encode -o %s'%(fn, fn.replace('png', 'etc1')))
