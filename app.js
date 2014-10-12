var express = require('express');
var app = express();
var fs = require('fs');
var coffee2js = require('./coffee2js.js');

var STATIC_PATH = 'src';
var PORT = 3000;

/**
 coffeeファイルへの参照を
 jsに変換して返す
*/
app.get('*.coffee', function (req, res) {
    var filepath = STATIC_PATH + req.url;
    coffee2js.sendAfterCompile(filepath, res);
});

/**
 jsファイルへの参照
 jsがある場合はそのまま返す
 無い場合は同名のcoffeeファイルを探して
 あればそれをjsに変換して変えす
*/
app.get('*.js', function(req, res, next) {
    var filepath = STATIC_PATH + req.url;
    var coffeeFilePath = coffee2js.getCoffeeFilePathAtSameDir(filepath);
    var coffeeFilePathAtCoffeeDir = coffee2js.getCoffeeFilePathAtCoffeeDir(filepath);
    if(fs.existsSync(coffeeFilePath)) {
        console.log(filepath + ' -> ' + coffeeFilePath);
        coffee2js.sendAfterCompile(coffeeFilePath, res);
    } else if(fs.existsSync(coffeeFilePathAtCoffeeDir)) {
        console.log(filepath + ' -> ' + coffeeFilePathAtCoffeeDir);
        coffee2js.sendAfterCompile(coffeeFilePathAtCoffeeDir, res);
    } else {
        next();
    }
});
app.use(express.static(STATIC_PATH, {hidden: true}));
app.listen(PORT);
console.log('server start: http://localhost:' + PORT);
