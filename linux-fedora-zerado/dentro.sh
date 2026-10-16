set -e
dnf install -y -q sudo wget xz bzip2 >/dev/null
useradd -m -s /bin/bash aluno
if [ "yes" = yes ]; then echo "aluno ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/aluno; fi
cd /home/aluno && sudo -u aluno -H bash /t/limpo-posix.sh /out fedora-zerado bf0576c479e6da65bf85e8c867da0b289f5f6f72 gemini
