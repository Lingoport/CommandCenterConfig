echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.tractor.dev"
cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.tractor.dev

echo ""
echo "$ git reset --hard b5c027019"
git reset --hard b5c027019

echo ""
echo "$ git status"
git status

echo ""
echo "$ git cherry-pick a990ebc33cad9e740e89fff9d9b227880ef10e29 --strategy-option=theirs"
git cherry-pick a990ebc33cad9e740e89fff9d9b227880ef10e29 --strategy-option=theirs

echo ""
echo "$ git status"
git status

echo ""
echo "$ cat tractorapp/src/main/res/values-xx/strings.xml"
cat tractorapp/src/main/res/values-xx/strings.xml
