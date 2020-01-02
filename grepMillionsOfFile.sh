#-H is mac only if i remember well.
find . | xargs -n16 -P8 grep -H "string"
