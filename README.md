# aws-profile

Utility tool to manage profiles in aws-cli.

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
    - current profile follows caracter `*`, like:
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
