#/bin/sh
#
terraform init -backend-config=../../../global/s3/backend.hcl $*
