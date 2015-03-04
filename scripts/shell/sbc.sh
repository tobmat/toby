#!/bin/bash
#!/bin/expect

#------------------------------------------------- #
rm /home/devops/sbc/*.xml
rm /home/devops/sbc/*.gz
bash /home/devops/sbc/sbc-inventory.sh
bash /home/devops/sbc/sbc-backup.sh

