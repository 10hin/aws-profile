# aws-profile

Make easy to switch profile of aws-cli.

aws-cli supports 2-way for specifying profile:

- Command parameter `aws --profile "${profile}"`
- Environment variable `export AWS_PROFILE="${profile}"` or `export AWS_DEFAULT_PROFILE`.

But no support for configurable persistent default.

> Here, "persistent" means that the value is shared by different shell sessions on the same machine, by the same user, and is not lost upon machine restart.
> We can configure the default by adding `export AWS_PROFILE=...` to user profile (`~/.profile`, `~/.bashrc`, etc.), but this solution need text editor to reconfigure and much pane to user with grep-by-eyes.

## How to install

1. Put "aws-profile.bash" file to local directory. (`~/.bashrc.d/` may be good, but any other place can be)
1. Load the script at initial time of your shell.
    - load from `~/.profile` or `~/.bashrc` or any other initializing script.
    - load like:
        ```
        # ...
        
        source /path/to/aws-profile.bash
        
        # ...
        ```


## Usage

- `aws-profile`
    - print current profile name.
- `aws-profile ls`
    - print all list of profile.
    - current profile follows character `*`, like:
        ```
          default
          non-active-profile
        * active-profile
          other-profile
        ```
- `aws-profile <profile>`
    - set `<profile>` active.
    - `<profile>` must be configured by `aws configure --profile <profile>` before set.
- `aws-profile (-h|--help)`
    - print help.

## Dependency

- Bash
- sed
  - author uses "GNU sed".
- awk
  - author uses gawk.
