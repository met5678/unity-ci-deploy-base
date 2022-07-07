echo "#!/bin/sh\n\n" > setup-unity-project.sh;

for function_script in ./scripts/functions/*.sh;
do
  cat $function_script >> setup-unity-project.sh
  echo "\n\n" >> setup-unity-project.sh
done

cat scripts/setup-unity-project.sh >> setup-unity-project.sh
chmod +x setup-unity-project.sh