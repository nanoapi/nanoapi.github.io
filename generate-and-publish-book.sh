gitbook build src
cp -R src/_book/* .
git add protobuf
git add doxygen
git add src
git add gitbook
git add *.html
git commit --amend -m "Publish"
git push origin master --force
