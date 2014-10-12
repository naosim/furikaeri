var fs = require('fs');
var exec = require('child_process').exec;

var cache = {};
cache.isUpdate = function(filepath) {
    var c = cache[filepath];
    return !c || c.date != new Date(fs.statSync(filepath).mtime).getTime();
};

cache.put = function(filepath, content) {
    cache[filepath] = {
        content: content,
        date: new Date(fs.statSync(filepath).mtime).getTime()
    };
};

cache.getContent = function(filepath) {
    return cache[filepath].content;
}

function replaceAll(expression, org, dest){
    return expression.split(org).join(dest);
};

function escapedString(org) {
    var result = replaceAll(org, '\'', '\\\'');
    result = replaceAll(result, '\n', '\\n');
    return result;
}

function coffee2js(filepath, callback) {
    var command = 'coffee -bcp ' + filepath;
    var child = exec(command, function(err, stdout, stderr) {
        if (!err) {
            callback('// command: ' + command + '\n' + stdout);
        } else {
            console.error('----');
            console.error(filepath);
            console.error(err);
            var e = escapedString(new String(err));
            var result = '';
            // result += 'alert(\'' + e + '\');';
            result += 'console.error(\'' + e + '\');';
            callback(result);
        }
    })
}

function sendAfterCoffee2js(filepath, res) {
    if(!cache.isUpdate(filepath)) {
        console.log(" -> cache");
        res.setHeader('Content-Type', 'text/javascript');
        res.send(cache.getContent(filepath));
        return;
    }

    coffee2js(filepath, function(result) {
        cache.put(filepath, result);
        res.setHeader('Content-Type', 'text/javascript');
        res.send(result);
    });
}

function getCoffeeFilePathAtSameDir(jsFilePath) {
    return jsFilePath.substring(0, jsFilePath.lastIndexOf('.')) + '.coffee';
}

function getCoffeeFilePathAtCoffeeDir(jsFilePath) {
    return replaceAll(getCoffeeFilePathAtSameDir(jsFilePath), '/js/', '/coffee/');
}

module.exports = {
    sendAfterCompile: sendAfterCoffee2js,
    getCoffeeFilePathAtSameDir: getCoffeeFilePathAtSameDir,
    getCoffeeFilePathAtCoffeeDir: getCoffeeFilePathAtCoffeeDir
};
