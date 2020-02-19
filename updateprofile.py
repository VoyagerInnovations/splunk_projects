import subprocess
import sys

subprocess.call(['/apps/splunk/etc/apps/csg/bin/scripts/updateprofile.sh',sys.argv[1]], shell=False)


