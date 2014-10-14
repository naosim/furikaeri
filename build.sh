mkdir -p dist/img dist/css dist/js
cp src/*.html dist/
cp src/img/*.* dist/img
coffee -cbo dist/js/ src/coffee/*.coffee
