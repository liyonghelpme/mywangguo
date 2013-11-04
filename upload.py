#coding:utf8
import os
import zipfile
import hashlib
def genAndMove():
    os.chdir('Resources')
    os.system('python genZipAndMd5.py')
    os.chdir('..')
    zipFile = zipfile.ZipFile('upload/test.zip', 'a') 
    im = os.listdir('newImg')
    for i in im:
        if i.find('~') == -1:
            print("insert image %s"%(i))
            os.system('cp newImg/%s %s' % (i, i))
            zipFile.write(i)
    zipFile.close()


    m = hashlib.md5()
    f = open('upload/test.zip').read()
    m.update(f)
    nf = open('upload/version', 'w')
    nf.write(m.hexdigest())
    nf.close()

genAndMove()

#manual move zip and version
os.system('scp upload/test.zip root@112.124.41.186:/var/www/code/test1.zip')
os.system('scp upload/version root@112.124.41.186:/var/www/code/version1')

