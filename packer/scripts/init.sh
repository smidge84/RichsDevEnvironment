# Init script to source in various init scripts to setup the dev container

DIR=$(dirname $0)

init_scripts=($(find ${DIR}/init.d/ -type f -name "*.sh"))

for script in ${init_scripts[@]}; do
  echo "Sourcing init script: $(basename ${script})"
  source ${script}
done
