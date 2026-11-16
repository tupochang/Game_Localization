"""Prepare an isolated ASAR with a temporary Electron screenshot hook."""
from pathlib import Path

from asar_io import get, pack, read


root = Path(__file__).resolve().parents[1]
active = root / 'resources' / 'app.asar'
stage = Path(__file__).resolve().parent / 'smoke_stage_688ff5bf5e184fe390031ad125464368'
data, tree, base = read(active)
source = get(data, tree, base, 'src/index.js').decode('utf-8-sig')
needle = "mainWindow.webContents.on('did-finish-load', function() {"
if source.count(needle) != 1:
    raise ValueError('Could not locate Electron load hook')
hook = r'''
        if (process.env.SEXENA_CAPTURE_SCENE === 'opening') {
            setTimeout(function() {
                mainWindow.webContents.executeJavaScript(
                    "var link=document.querySelector('#choices p.choice a'); if(link){link.click(); 'clicked'}else{'missing choice'}"
                );
            }, 3000);
        }
        setTimeout(function() {
            const fs = require('fs');
            const capturePath = process.env.SEXENA_CAPTURE;
            if (!capturePath) return;
            const query = "JSON.stringify({images:Array.prototype.map.call(document.querySelectorAll('img'),function(e){var r=e.getBoundingClientRect(),c=getComputedStyle(e);return {src:e.getAttribute('src'),clip:c.clipPath,display:c.display,visibility:c.visibility,opacity:c.opacity,rect:[r.x,r.y,r.width,r.height],outer:e.outerHTML.slice(0,250)}}).filter(function(e){return e.src&&e.src.indexOf('title')>=0}),styles:Array.prototype.map.call(document.styleSheets,function(e){return e.href})})";
            const details = mainWindow.webContents.executeJavaScript(query);
            if (details && typeof details.then === 'function') details.then(function(value) {
                fs.writeFileSync(capturePath + '.dom.json', value);
            });
            const report = function(image) {
                try { fs.writeFileSync(capturePath, image.toPNG()); }
                catch (err) { fs.writeFileSync(capturePath + '.error.txt', String(err)); }
            };
            try {
                const result = mainWindow.webContents.capturePage();
                if (result && typeof result.then === 'function') result.then(report).catch(function(err) {
                    fs.writeFileSync(capturePath + '.error.txt', String(err));
                });
                else mainWindow.webContents.capturePage(report);
            } catch (err) {
                fs.writeFileSync(capturePath + '.error.txt', String(err));
            }
        }, process.env.SEXENA_CAPTURE_SCENE === 'opening' ? 9000 : 5000);
'''
modified = source.replace(needle, needle + hook)
pack(active, stage / 'resources' / 'app.asar', {'src/index.js': modified.encode('utf-8')})
print('Prepared isolated capture ASAR')
