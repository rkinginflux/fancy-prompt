# fancy-prompt
My bash config for the lab

Add the following to your ~/.bashrc

if [ -f /$HOME/.config/greeter.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /$HOME/.config/greeter.sh
fi

if [ -f /$HOME/.config/prompt.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /$HOME/.config/prompt.sh
fi
