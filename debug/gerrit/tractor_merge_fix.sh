cd /usr/local/tomcat/Lingoport_Data/CommandCenter/workspaces/a.tractor.dev
git reset --hard b5c027019
git status
git cherry-pick a990ebc33cad9e740e89fff9d9b227880ef10e29 --strategy=theirs
git status
