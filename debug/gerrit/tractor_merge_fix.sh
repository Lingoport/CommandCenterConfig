echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.powermanager.dev"
cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.powermanager.dev

echo ""
echo "$ ref=\$(git ls remote | grep 367689d452a90ca355666a2e20b79ea95fd84372 | awk '{print \$2}')"
ref=$(git ls-remote | grep 367689d452a90ca355666a2e20b79ea95fd84372 | awk '{print $2}')

echo "$ echo \$ref"
echo $ref

echo "$ metaref=\$(echo \$ref | awk 'BEGIN {FS=\"/\" ; OFS=\"/\"} ; {print \$1,\$2,\$3,\$4,\"meta\"}')"
metaref=$(echo $ref | awk 'BEGIN {FS="/" ; OFS="/"} ; {print $1,$2,$3,$4,"meta"}')

echo "$ echo \$metaref"
echo $metaref

echo "$ git fetch origin $metaref"
git fetch origin $metaref

echo "$ git checkout FETCH_HEAD"
git checkout FETCH_HEAD

echo "$ git log"
git log

echo "$ merged=\$(git log | grep -b -o -m 1 merged | head -1 | awk 'BEGIN {FS=\":\"} ; {print \$1}')"
merged=$(git log | grep -b -o -m 1 merged | head -1 | awk 'BEGIN {FS=":"} ; {print $1}')

echo "$ echo \$merged"
echo $merged

echo "$ ohea=\$(git log | grep -b -o -m 1 ohea | head -1 | awk 'BEGIN {FS=\":\"} ; {print \$1}')"
ohea=$(git log | grep -b -o -m 1 ohea | head -1 | awk 'BEGIN {FS=":"} ; {print $1}')

echo "$ echo \$ohea"
echo $ohea
