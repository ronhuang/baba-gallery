/*
 * Jakefile
 * BabaPainter
 *
 * Created by Ron Huang on March 2, 2011.
 * Copyright 2011, Ron Huang All rights reserved.
 */

var ENV = require("system").env,
    FILE = require("file"),
    JAKE = require("jake"),
    task = JAKE.task,
    FileList = JAKE.FileList,
    OS = require("os");

task ("default", ["debug"]);

task ("release", function()
{
    JAKE.subjake(FILE.join("frontend"), "flatten", ENV);

    var src = FILE.absolute(FILE.join("frontend", "Build", "Flatten", "baba"));
    var dst = FILE.absolute(FILE.join("public", "baba"));
    if (FILE.exists(dst))
        FILE.remove(dst);
    FILE.symlink(src, dst);
});

task ("debug", function()
{
    var src = FILE.absolute(FILE.join("frontend"));
    var dst = FILE.absolute(FILE.join("public", "baba"));
    if (FILE.exists(dst))
        FILE.remove(dst);
    FILE.symlink(src, dst);
});
