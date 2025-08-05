dnf install flatpak
flatpak --version
podman login registry.redhat.io

#To make the Auth permanent (Auth is normally just for this session)
mkdir -p ~/.config/flatpak
cp $XDG_RUNTIME_DIR/containers/auth.json ~/.config/flatpak/oci-auth.json

flatpak remotes
flatpak remotes -d
flatpak remote-ls --app
flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
flatpak remotes 
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remotes 
flatpak remote-ls fedora --app
flatpak install Wireshark
flatpak remote-ls fedora --app
flatpak install Krita
