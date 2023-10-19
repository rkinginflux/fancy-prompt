# fancy-prompt
My bash config for the lab

Add the following to the bottom of your ~/.bashrc file

if [ -f "$HOME/.config/greeter.sh" ] && [ -n "$( echo $- | grep i )" ]; then
    source "$HOME/.config/greeter.sh"
fi


if [ -f "$HOME/.config/prompt.sh" ] && [ -n "$( echo $- | grep i )" ]; then
    source "$HOME/.config/prompt.sh"
fi
