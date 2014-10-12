/*
  実行例
    node gitci.js -i 10 deploy.sh
  引数
    -i: interval[分] デフォルト5分
    最終引数 アップデートがあった場合に実行するコマンド
*/
var shFile = process.argv[process.argv.length - 1];
var interval = 5;
for(var i = 0; i < process.argv.length - 1; i++) {
  if(process.argv[i] == '-i') {
    i++
    interval = parseInt(process.argv[i], 10);
  }
}

var exec = require('child_process').exec;
var checkUpdate = function(updateAction) {
  exec('bash isupdate.sh', function(err, stdout, stderr) {
    if (!err) {
      console.log(new Date() + ' update');
      updateAction()
    } else {
      console.log(new Date() + ' none');
    }
  })
};

var runScript = function() {
  console.log('bash ' + shFile)
  exec('bash ' + shFile, function(err, stdout, stderr) {
    if (!err) {
      console.log(new Date() + ' ' + stdout);
      console.log(new Date() + ' script success');
    } else {
      console.log(new Date() + ' script error');
    }
  })
};

var run = function() {
  checkUpdate(runScript);
};

setInterval(run, interval * 60 * 1000);
run();