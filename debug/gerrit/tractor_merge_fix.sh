echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.powermanager.dev"
cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.powermanager.dev

echo ""
echo "$ ref=\$(git ls remote | grep 367689d452a90ca355666a2e20b79ea95fd84372 | awk '{print \$2}')"
ref=$(git ls-remote | grep 367689d452a90ca355666a2e20b79ea95fd84372 | awk '{print $2}')

echo "$ echo \$ref"
echo $ref
