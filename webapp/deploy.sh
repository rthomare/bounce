# ask if a new version should be deployed
RESULT=$(echo $REPLY | tr '[:upper:]' '[:lower:]')
version=$(node -p -e "require('./package.json').version")

# run tests and build before deploying and exit if tests or build fail
bun run vitest --dom --run
if [ $? -ne 0 ]; then
  echo "Tests failed, aborting deploy"
  exit 1
fi

echo "Deploying version $version"
bun run build
if [ $? -ne 0 ]; then
  echo "Build failed, aborting deploy"
  exit 1
fi
bun add-domain

if [ $REPLY ==  "y" ]; then
  # commit changes
  git add -A
  git commit -m "build: bump to version $version"
  git push
fi

# deploy to gh-pages
echo "Deploying to gh-pages for version $version"
bun run gh-pages -d dist