#!/bin/bash

scp $1/$2  cms_user@10.133.227.181:/home/cms_user/scripts/CHECK_CMS_STATUS/.
ssh cms_user@10.133.227.181 /bin/bash -x /home/cms_user/scripts/.check_cms_status.sh $2
