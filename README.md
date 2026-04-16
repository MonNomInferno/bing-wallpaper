# bing-wallpaper
Download and apply latest Bing Wallpaper in MacOS

This script is an extension to a deprecated script by thejandroman

Tested on MacOS 26.4

# How to run?
Modify permission of this file using `chmod +x {script}.sh` in terminal opened in the directory where script is present.

Next, run `./{script}.sh -h` or `./{script}.sh -help` to get list of arguments you can use. Some are:

```Options:
  -f --force                     Force download of picture. This will overwrite
                                 the picture if the filename already exists.
  -s --ssl                       Communicate with bing.com over SSL.
  -b --boost <n>                 Use boost mode. Try to fetch latest <n> pictures.
  -q --quiet                     Do not display log messages.
  -n --filename <file name>      The name of the downloaded picture. Defaults to
                                 the upstream name.
  -p --picturedir <picture dir>  The full path to the picture download dir.
                                 Will be created if it does not exist.
                                 [default: $HOME/Pictures/bing-wallpapers/]
  -r --resolution <resolution>   The resolution of the image to retrieve.
                                 Supported resolutions: (Default: UHD)
                                 UHD 1920x1200 1920x1080 800x480 400x240
  -w --set-wallpaper             Set downloaded picture as wallpaper
  -h --help                      Show this screen.
  --version                      Show version.
```

# How to run it automatically everyday?
Create a automation in shortcuts app that runs the command `./{script}.sh - w` everyday at 0000 hours. Alternately, you can use automator to run this command.
