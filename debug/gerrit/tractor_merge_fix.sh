echo "$ echo \$PROSENTHAL_PAT"
echo $PROSENTHAL_PAT

echo "$ cd /usr/local/tomcat/scripts"
cd /usr/local/tomcat/scripts

echo "$ git clone https://prosenthalLingoport:$PROSENTHAL_PAT@github.com/Lingoport/Command-Center.git temp"
git clone https://prosenthalLingoport:$PROSENTHAL_PAT@github.com/Lingoport/Command-Center.git temp

echo "$ cp temp/gerritclone.sh ."
cp temp/gerritclone.sh .

echo "$ cp temp gerritpull.sh ."
cp temp/gerritpull.sh .

echo "$ ls -la"
ls -la
