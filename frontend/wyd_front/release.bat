git checkout -b release
git merge main
flutter build web
git commit -m'flutter build web'
git push
git checkout -b main