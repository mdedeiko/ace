#!/bin/bash

IP=$(ifconfig eth0 | grep 'inet ' | awk '{ print $2}')

HLS_LIST='hls.m3u'
ACE_PROXY_LIST='aceproxy.m3u'
ACE_LIST='ace.m3u'
HLS_LIST_FILE="/tmp/"$HLS_LIST""
ACE_PROXY_LIST_FILE="/tmp/"$ACE_PROXY_LIST""
ACE_LIST_FILE="/tmp/"$ACE_LIST""
KEY_WORD="EXTM3U"
echo "$IP"

curl -x GET http://omt56v4jxa4hurbwk44vqbbcwn3eavuynyc24c25cy7grucjh24q.b32.i2p/trash/ttv-list/ace.all.iproxy.m3u\?ip\="$IP":6878\&format\=hls --proxy 127.0.0.1:4544 > /tmp/"$HLS_LIST"

curl -x GET http://omt56v4jxa4hurbwk44vqbbcwn3eavuynyc24c25cy7grucjh24q.b32.i2p/trash/ttv-list/ace.all.iproxy.m3u\?ip\="$IP":6878\&format\=http --proxy 127.0.0.1:4544 > /tmp/"$ACE_PROXY_LIST"
curl -x GET http://omt56v4jxa4hurbwk44vqbbcwn3eavuynyc24c25cy7grucjh24q.b32.i2p/trash/ttv-list/ace.all.iproxy.m3u --proxy 127.0.0.1:4544 > /tmp/"$ACE_LIST"

if grep -q "$KEY_WORD" "$HLS_LIST_FILE"; then
cp -fr "$HLS_LIST_FILE" /apps/acestream/playlist
echo "HLS LIST Saved"
fi

if grep -q "$KEY_WORD" "$ACE_PROXY_LIST_FILE"; then
cp -fr "$ACE_PROXY_LIST_FILE" /apps/acestream/playlist
echo "Ace proxy list Saved"
fi

if grep -q "$KEY_WORD" "$ACE_LIST_FILE"; then
cp -fr "$ACE_LIST_FILE" /apps/acestream/playlist
echo "ACE List Saved"
fi

