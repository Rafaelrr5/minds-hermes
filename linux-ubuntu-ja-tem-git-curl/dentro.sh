set -e
apt-get update -qq && apt-get install -y -qq sudo wget ca-certificates xz-utils bzip2 git curl libatomic1 >/dev/null
useradd -m -s /bin/bash aluno
if [ "yes" = yes ]; then echo "aluno ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/aluno; fi
cd /home/aluno && sudo -u aluno -H bash /t/limpo-posix.sh /out ubuntu-ja-tem-git-curl bf0576c479e6da65bf85e8c867da0b289f5f6f72 claude
