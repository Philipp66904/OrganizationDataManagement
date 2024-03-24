echo "Create output folder if it doesn't exist yet"
mkdir -p ../src/lang/build

echo "Compile German translations:"
lrelease ../src/lang/de_DE.ts -qm ../src/lang/build/de_DE.qm
