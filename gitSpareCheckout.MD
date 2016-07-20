mkdir {Repo}
cd {Repo}
git init
git remote add -f origin {Url}

git config core.sparseCheckout true

echo "app/dir/" >> .git/info/sparse-checkout
echo "app/dir/subDir" >> .git/info/sparse-checkout

#Copy just the first level
git pull --depth=1 origin master
