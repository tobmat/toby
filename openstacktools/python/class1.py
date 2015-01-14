import os
class MyStuff(object):

    def __init__(self):
        self.tangerine = "And now a thousand years between"
        self.tenant = os.environ['OS_TENANT_NAME']

    def apple(self):
        print "I AM CLASSY APPLES!"

class Song(object):

    def __init__(self, lyrics):
        self.lyrics = lyrics

    def sing_me_a_song(self):
        print self.lyrics
        print os.environ['OS_TENANT_NAME']
        #for line in self.lyrics:
        #    print line