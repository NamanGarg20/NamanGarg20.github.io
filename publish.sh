#!/usr/bin/env bash

set -e

HOST="divyanshgarg.com"
USER="divyanshgargcom"

get_pw () {
  security 2>&1 >/dev/null find-internet-password -gs "ftp.$HOST"\
  |ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}

PASSWD="$(get_pw)"

LOCAL_DIR=$(pwd)/
REMOTE_DIR="/wb_divyansh"

lftp_sets="set cmd:fail-exit yes;"
ftp_sets+=" set ftp:ssl-allow no;"
ftpurl="ftp://$USER:$PASSWD@$HOST"

lftp -u "$USER","$PASSWD" $HOST <<EOF
# the next 3 lines put you in ftpes mode. Uncomment if you are having trouble connecting.
# set ftp:ssl-force true
# set ftp:ssl-protect-data true
# set ssl:verify-certificate no
# transfer starts now...

$lftp_sets open '$ftpurl';
mirror -R  --parallel=2 $LOCAL_DIR $REMOTE_DIR -x '^\.' -x '^\node_modules/$' -X 'publish.sh' -X 'README.md' -i '.htaccess';
exit
EOF

echo "Website published!"
