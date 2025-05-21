#!/bin/bash
pres_dir=../presentaciones
tex_salida=""
for entry in "$pres_dir"/*
do
  titulo=$(grep -m 1 '^# ' $entry/index.md | sed 's/^# //')
  echo "$titulo"

  #carpeta=$(echo "$entry" | sed -r "s/.+\/(.+)\..+/\1/")
  nombre=$(basename "$entry")
  echo "$entry"
  #echo "$carpeta"
  echo "$nombre"

  tex_salida="$tex_salida- [$titulo](https://formacioncloud.github.io/IaC/$nombre)\n"

  mkdir ../out
  cp -R "$entry" ../out/
  cp ./index.html "../out/$nombre/"
  sed -i "s|<title>.*</title>|<title>${titulo}</title>|" "../out/$nombre/index.html"
done

echo $tex_salida
echo "pedro"

awk -v nuevo="$tex_salida" '
/^# Presentaciones$/ { 
  skip = 1 
  next 
}
/^# / && skip { 
  skip = 0 
}
!skip
END {
  print "# Presentaciones"
  print nuevo
}' ../README.md > "README.tmp" && mv "README.tmp" "../README.md"

git config --global user.name 'GitHub Actions'
git config --global user.email 'actions@users.noreply.github.com'
git add ../README.md
git commit -m "Actions: Actualizar presentaciones"
git push

