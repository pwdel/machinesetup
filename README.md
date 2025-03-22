# My Machine Setup

### Initial, Installation Tools

* Brew, then add to path.

```
    echo >> /Users/patrick/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/patrick/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
```

* Ensure pip installed

```
python -m ensurepip --upgrade
```

* Pip tools

```
pip3 install pip-tools
```

* If using user, pip-tools will be added to the wrong directory, e.g. the home directory.
* So add the home directory to your path.

```
echo 'export PATH="$HOME/Library/Python/3.9/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify with:

```
pip-compile --version
```

* tree

```
brew install tree
```

### Aliasing

* pip

```
echo 'alias pip=pip3' >> ~/.zshrc
source ~/.zshrc
```

* python

```
echo 'alias python=python3' >> ~/.zshrc
source ~/.zshrc
```

### New Python Version

Presuming you have pyenv installed:

```
pyenv install 3.12.2
```

Then a python environment can be activated with:

```
pyenv shell 3.12.2 && \
python --version \
which python
```

### Additional Tools

* Dasel

```
brew install dasel
```

* pyenv

```
brew install pyenv
```

* pyenv virtualenv

```
brew install pyenv-virtualenv
```

Then hook to shell by adding to the bottom of ~/.zshrc:

```

```
* direnv

```
brew install direnv && \
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && \
source ~/.zshrc
```

...may need to hardwire to get direnv working, need to read documentation.
