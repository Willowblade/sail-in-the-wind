from subprocess import Popen
import os


export_folder = "../releases/shadowtest"
version = "0.0.2"
version_folder = "{}/{}".format(export_folder, version)
if not os.path.exists(version_folder):
    os.mkdir(version_folder)

windows_folder, linux_folder, html_folder = ["{}/{}".format(version_folder, directory) for directory in ["windows", "linux", "html"]]
for folder in [windows_folder, linux_folder, html_folder]:
    if not os.path.exists(folder):
        os.mkdir(folder)

print(windows_folder, linux_folder, html_folder)

windows_build = Popen([
    "/home/laurent/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64",
    "--export", "Windows Desktop", windows_folder + "/ShadowCorev{}.exe".format(version)])


linux_build = Popen([
    "/home/laurent/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64",
    "--export", "Linux/X11", linux_folder + "/ShadowCorev{}.x86_64".format(version)])



html_build = Popen([
    "/home/laurent/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64",
    "--export", "HTML5", html_folder + "/index.html"])

windows_build.communicate()
linux_build.communicate()
html_build.communicate()

Popen(["chmod", "+x", linux_folder + "/ShadowCorev{}.x86_64".format(version)])


windows_upload = Popen(["butler", "push", windows_folder, "d4yz/shadow-core:win", "--userversion", version])
windows_upload.communicate()

linux_upload = Popen(["butler", "push", linux_folder, "d4yz/shadow-core:linux", "--userversion", version])
linux_upload.communicate()

html_upload = Popen(["butler", "push", html_folder, "d4yz/shadow-core:html", "--userversion", version])
html_upload.communicate()