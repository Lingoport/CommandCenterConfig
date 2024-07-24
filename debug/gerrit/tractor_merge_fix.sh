echo "$ cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.tractor.dev"
cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.tractor.dev

echo ""
echo "$ git reset --hard b5c027019"
git reset --hard b5c027019

echo ""
echo "$ git status"
git status

echo ""
echo "$ git cherry-pick a990ebc33cad9e740e89fff9d9b227880ef10e29 --strategy=theirs"
git cherry-pick a990ebc33cad9e740e89fff9d9b227880ef10e29 --strategy=theirs

echo ""
echo "$ git cherry-pick --continue"
git cherry-pick --continue

echo ""
echo "$ git cherry-pick --continue"
git cherry-pick --continue --allow-empty

echo ""
echo "$ git status"
git status
