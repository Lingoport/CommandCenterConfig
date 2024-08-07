echo "$ echo \$PROSENTHAL_PAT"
echo $PROSENTHAL_PAT

echo "$ cd /usr/local/tomcat/scripts"
cd /usr/local/tomcat/scripts

echo "$ git clone https://prosenthalLingoport:$PROSENTHAL_PAT@github.com/Lingoport/Command-Center.git temp"
git clone https://prosenthalLingoport:$PROSENTHAL_PAT@github.com/Lingoport/Command-Center.git temp

echo "$ cd temp"
cd temp

echo "$ git checkout freshdesk-4054-fix"
git checkout freshdesk-4054-fix

echo "$ git status"
git status

echo "$ cp gerritclone.sh .."
cp gerritclone.sh ..

echo "$ cp gerritpull.sh .."
cp gerritpull.sh ..

echo "$ cd .."
cd ..

echo "$ ls -la"
ls -la

echo "$ rm -rf temp"
rm -rf temp

echo "$ cat gerritclone.sh"
cat gerritclone.sh
