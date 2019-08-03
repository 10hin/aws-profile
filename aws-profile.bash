
export __AWS_PROFILE__CREDENTIALS=~/.aws/credentials
export __AWS_PROFILE__CONFIG=~/.aws/config
export __AWS_PROFILE__CONF_DIR=~/.aws-profile
export __AWS_PROFILE__PROFILE_PERSISTENT_FILE="${__AWS_PROFILE__CONF_DIR}/current-profile"
if ! ls "${__AWS_PROFILE__CONF_DIR}" &> /dev/null; then
  mkdir -p "${__AWS_PROFILE__CONF_DIR}"
fi
if ! [[ -f "${__AWS_PROFILE__PROFILE_PERSISTENT_FILE}" ]]; then
  if [[ -d "${__AWS_PROFILE__CONF_DIR}" ]]; then
    printf "default" > ${__AWS_PROFILE__PROFILE_PERSISTENT_FILE} 2> /dev/null
  else
    echo "aws-profile.bash: configuration directory name ${__AWS_PROFILE__CONF_DIR} exists, but not directory! cannot store configuration." 1>&2
  fi
fi

function __aws_profile__list_profiles() {
  __aws_profile__check_and_reset_current_profile
  grep -E '^\[[^][]*\]\s*$' "${__AWS_PROFILE__CREDENTIALS}" | sed -r -e 's/\[([^][]*)\]\s*$/\1/' |\
  while read profile; do
    if [[ "${profile}" == "$(cat ${__AWS_PROFILE__PROFILE_PERSISTENT_FILE})" ]]; then
      prefix="\x1b[33m* "
      suffix="\x1b[0m"
    else
      prefix="\x1b[0m  "
      suffix="\x1b[0m"
    fi
    printf "${prefix}${profile}${suffix}\n"
  done
}

function __aws_profile__current_profile() {
  __aws_profile__check_and_reset_current_profile
  echo "${AWS_PROFILE}"
}

function __aws_profile__show_help() {
  cat << __EOT__ 1>&2

  Show, set or list profile for aws-cli (\`\`aws'' command).

  Usage:
         aws-profile
             show current profile.

         aws-profile <profile>
             set profile as <profile>
             <profile> must appear in profile credentials file.
             (${__AWS_PROFILE__CREDENTIALS})

         aws-profile ls
             list profile in cretentials file.
             (${__AWS_PROFILE__CREDENTIALS})

         aws-profile (-h|--help)
             show this help.

__EOT__
}

function __aws_profile__check_and_reset_current_profile() {
  if ! cat "${__AWS_PROFILE__CREDENTIALS}" | grep -E "^\[$(cat ${__AWS_PROFILE__PROFILE_PERSISTENT_FILE})\]\s*$" &> /dev/null; then
    if cat "${__AWS_PROFILE__CREDENTIALS}" | grep -E "^\[default\]\s*$" &> /dev/null; then
      __aws_profile__set_profile default
    else
      first_profile=$(grep -E '^\[[^][]*\]\s*$' | head -1 | sed -r -e 's/\[([^][]*)\]\s*$/\1/')
      if ! [[ -z "${first_profile}" ]]; then
        __aws_profile__set_profile "${first_profile}"
      else
        # only environment variable set.
        # there are no value to set in persistent file.
        export AWS_PROFILE="default"
      fi
    fi
  fi
}

function __aws_profile__extract_config_section() {
  local profile="$1"
  local awk_script='
    BEGIN {
      found = 0
    }
    /^\[.*\]\r?$/ {
      if (found) {
        exit 0
      } {
        if (match($0, "^\\[(profile )?'"${profile}"'\\]\r?$")) {
          found = 1
        }
      }
    }
    {
      if (found) {
        print $0
      }
    }
  '
  awk "${awk_script}" "${__AWS_PROFILE__CONFIG}"
}

function __aws_profile__set_profile() {
  if (( $# < 1 )); then
    echo "aws-profile: __aws_profile__set_profile: less argument." 1>&2
    __aws_profile__show_help
    return 1
  fi
  if ! cat ${__AWS_PROFILE__CREDENTIALS} | grep -E "^\[$1\]" &> /dev/null; then
    echo "aws-profile: __aws_profile__set_profile: specified profile ($1) not exist in credentials file." 1>&2
    __aws_profile__show_help
    return 1
  fi
  local active_section="$(__aws_profile__extract_config_section "$1")"
  local default_region="$(echo "${active_section}" | grep -E '^region *=' | sed -r -e 's/^region *= *(.*)$/\1/')"
  local default_output="$(echo "${active_section}" | grep -E '^output *=' | sed -r -e 's/^output *= *(.*)$/\1/')"
  printf "$1" > "${__AWS_PROFILE__PROFILE_PERSISTENT_FILE}" 2> /dev/null
  export AWS_PROFILE="$1"
  if (( "${#default_region}" > 0 )); then
    export AWS_DEFAULT_REGION="${default_region}"
  fi
  if (( "${#default_output}" > 0 )); then
    export AWS_DEFAULT_OUTPUT="${default_output}"
  fi
}

function aws-profile() {
  case "$#" in
    0 )
      __aws_profile__current_profile
      ;;
    1 )
      case "$1" in
        "-h" | "--help" )
          __aws_profile__show_help
          ;;
        "ls" )
          __aws_profile__list_profiles
          ;;
        *    )
          __aws_profile__set_profile "$1"
        ;;
      esac
      ;;
  esac
}

aws-profile "$(cat "${__AWS_PROFILE__PROFILE_PERSISTENT_FILE}")"
