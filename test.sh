set -e
bad=0
for d in addons/*; do
  [ -d "$d/.git" ] || continue
  b="$(git -C "$d" rev-parse --abbrev-ref HEAD)"
  if [ "$b" != "19.0" ]; then
    echo "FAIL: $d -> $b"
    bad=1
  else
    echo "OK:   $d -> $b"
  fi
done
exit $bad
