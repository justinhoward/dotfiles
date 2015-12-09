browsers=(
  google-chrome
  google-chrome-stable
  firefox
)

for browser in "${browsers[@]}"; do
  if dcheck "$browser"; then
    export BROWSER="$browser"
    break
  fi
done

unset browsers
