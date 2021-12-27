# ART short for Artifactory
ART_SERVER=http://localhost:8081/artifactory/libs-snapshot-local
#
# Try to keep this out of this file and use it from the
# CLI dialog which is a bit more secure :)
#
ART_PASSWORD=
#
# This is the uid of the ART_SERVER
#
ART_UID=admin

#
# This is either simple or oauth (for OAuth bearer tokens)
#
AUTH_TYPE=simple
# 0 is off 1 is on
DEBUG=0

GENERATE_TOKEN_OPTS=`echo -d "instance=maven"`

ART_PATH=
RETRYS=3
RETRY_SECS=10
#
# It is NOT recommend to use this setting, as it is less secure
# than the OAUTH_TOKEN setting
#
OAUTH_PASS=
#
# This token MAY be created by this script and copied into this file
# NOTE there is NO option for a OAUTH_PASSWORD which is an intentional security feature
# use the CLI to dialog for the OAuth password
#
OAUTH_TOKEN=
OAUTH_SERVER=
#
# The User Identifier of the OAuth requests
#
OAUTH_UID=
VERSION=
export ART_SERVER ART_PASSWORD ART_UID AUTH_TYPE GENERATE_TOKEN_OPTS RETRYS RETRY_SECS OAUTH_PASS OAUTH_TOKEN OAUTH_SERVER OAUTH_UID TOKEN VERSION