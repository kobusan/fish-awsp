function awsp --description "AWS profile switcher for Fish shell with fzf UI"

    function __awsp_profiles
        set -l profiles

        if test -f ~/.aws/config
            for line in (cat ~/.aws/config)
                set line (string trim -- $line)

                if string match -rq '^\[default\]$' -- $line
                    if not contains -- default $profiles
                        set profiles $profiles default
                    end
                else if string match -rq '^\[profile .+\]$' -- $line
                    set -l p (string replace -r '^\[profile (.+)\]$' '$1' -- $line)
                    if test -n "$p"
                        if not contains -- $p $profiles
                            set profiles $profiles $p
                        end
                    end
                end
            end
        end

        if test -f ~/.aws/credentials
            for line in (cat ~/.aws/credentials)
                set line (string trim -- $line)

                if string match -rq '^\[[^]]+\]$' -- $line
                    set -l p (string replace -r '^\[(.+)\]$' '$1' -- $line)
                    if test -n "$p"
                        if not contains -- $p $profiles
                            set profiles $profiles $p
                        end
                    end
                end
            end
        end

        printf "%s\n" $profiles | sort -u
    end

    function __awsp_current
        if set -q AWS_PROFILE
            echo $AWS_PROFILE
        else if set -q AWS_DEFAULT_PROFILE
            echo $AWS_DEFAULT_PROFILE
        else
            echo default
        end
    end

    function __awsp_apply --argument-names profile
        if test "$profile" = "default"
            set -e AWS_PROFILE
            set -e AWS_DEFAULT_PROFILE
        else
            set -gx AWS_PROFILE $profile
            set -gx AWS_DEFAULT_PROFILE $profile
        end
    end

    function __awsp_alias_cache_dir
        echo ~/.cache/fish-awsp
    end

    function __awsp_alias_cache_key --argument-names profile
        set -l key $profile
        if test "$profile" = "default"
            set key default
        end
        echo (__awsp_alias_cache_dir)/alias-$key.txt
    end

    function __awsp_alias --argument-names profile
        set -l cache_dir (__awsp_alias_cache_dir)
        set -l cache_file (__awsp_alias_cache_key $profile)

        mkdir -p $cache_dir 2>/dev/null

        # 6時間キャッシュ
        if test -f $cache_file
            set -l now (date +%s)
            set -l mtime (stat -f %m $cache_file 2>/dev/null)

            if test -n "$mtime"
                set -l age (math $now - $mtime)
                if test $age -lt 21600
                    cat $cache_file
                    return 0
                end
            end
        end

        if test "$profile" = "default"
            set -l alias_value (aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null)
        else
            set -l alias_value (aws iam list-account-aliases --profile $profile --query 'AccountAliases[0]' --output text 2>/dev/null)
        end

        if test -z "$alias_value" -o "$alias_value" = "None" -o "$alias_value" = "null"
            set alias_value "-"
        end

        printf "%s\n" $alias_value > $cache_file
        echo $alias_value
    end

    function __awsp_list
        set_color brwhite
        printf "%-2s %-24s %-20s\n" "C" "PROFILE" "ALIAS"
        set_color normal

        for p in (__awsp_profiles)
            set -l alias_value (__awsp_alias $p)

            if test "$p" = (__awsp_current)
                set_color green
                printf "%-2s " "*"
                set_color normal
                printf "%-24s %-20s\n" $p $alias_value
            else
                printf "%-2s %-24s %-20s\n" " " $p $alias_value
            end
        end
    end

    function __awsp_fzf
        if not command -sq fzf
            echo "fzf is required. Install it first." >&2
            return 1
        end

        set -l selected (
            __awsp_profiles | fzf \
                --prompt="AWS Profile > " \
                --height=70% \
                --reverse \
                --border \
                --preview='awsp_preview {}' \
                --preview-window=right:60%:wrap
        )

        echo $selected
    end

    function __awsp_current_info
        set -l p (__awsp_current)

        echo "Profile : $p"
        echo "Alias   : "(__awsp_alias $p)

        if test "$p" = "default"
            set -l region (aws configure get region 2>/dev/null)
        else
            set -l region (aws configure get region --profile $p 2>/dev/null)
        end

        if test -z "$region"
            set region "-"
        end

        echo "Region  : $region"
    end

    switch "$argv[1]"
        case ""
            set -l selected (__awsp_fzf)
            if test -n "$selected"
                __awsp_apply $selected
                echo "Switched to $selected"
            end

        case list
            __awsp_list

        case current
            __awsp_current_info

        case clear
            set -e AWS_PROFILE
            set -e AWS_DEFAULT_PROFILE
            echo "AWS profile cleared"

        case '*'
            __awsp_apply $argv[1]
            echo "Switched to $argv[1]"
    end
end