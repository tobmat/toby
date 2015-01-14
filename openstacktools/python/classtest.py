#!/usr/bin/env python
#from class1 import MyStuff
from class1 import *

thing = MyStuff()
thing.apple()
print thing.tangerine
print thing.tenant

happy_bday = Song('WHAT')

happy_bday2 = Song('SUP')

happy_bday.sing_me_a_song()

os.environ['OS_TENANT_NAME'] = "TEST_META"
happy_bday2.sing_me_a_song()
thing2 = MyStuff()
print thing2.tenant