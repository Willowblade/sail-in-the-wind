from subprocess import Popen
import os


export_folder = "..\\releases\\sail-in-the-wind"
version = "0.1.0"
version_folder = "{}/{}".format(export_folder, version)
if not os.path.exists(version_folder):
    os.mkdir(version_folder)

windows_folder, linux_folder, html_folder = ["{}/{}".format(version_folder, directory) for directory in ["windows", "linux", "html"]]
for folder in [windows_folder, linux_folder, html_folder]:
    if not os.path.exists(folder):
        os.mkdir(folder)

print(windows_folder, linux_folder, html_folder)

godot_path = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Godot Engine\\godot.windows.opt.tools.64"
windows_build = Popen([
    godot_path, "--export", "Windows Desktop", windows_folder + "/ASailInTheWind{}.exe".format(version)])


linux_build = Popen([
    godot_path, "--export", "Linux/X11", linux_folder + "/ASailInTheWind{}.x86_64".format(version)])



html_build = Popen([
    godot_path, "--export", "HTML5", html_folder + "/index.html"])

windows_build.communicate()
linux_build.communicate()
html_build.communicate()

# Popen(["chmod", "+x", linux_folder + "/ASailInTheWind{}.x86_64".format(version)])

windows_upload = Popen(["butler", "push", windows_folder, "willowblade/a-sail-in-the-wind:win", "--userversion", version])
windows_upload.communicate()

linux_upload = Popen(["butler", "push", linux_folder, "willowblade/a-sail-in-the-wind:linux", "--userversion", version])
linux_upload.communicate()

html_upload = Popen(["butler", "push", html_folder, "willowblade/a-sail-in-the-wind:html", "--userversion", version])
html_upload.communicate()