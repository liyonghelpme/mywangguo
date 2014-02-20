import os.path, time
print "last modified: %s" % time.ctime(os.path.getmtime("../Resources"))

#copy all Image and lua script files

os.system('echo hah > a.test')
os.system('rm a.test')
f = os.listdir('.')
for i in f:
    if os.path.isdir(i):
        print "%s old last modified: %s" % (i, time.ctime(os.path.getmtime(i)))
        os.chdir(i)
        os.system('echo hah > a.test')
        os.system('rm a.test')
        os.chdir('..')

        print "%s new last modified: %s" % (i, time.ctime(os.path.getmtime(i)))

