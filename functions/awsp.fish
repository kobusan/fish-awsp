function awsp --description "AWS profile switcher for Fish shell with fzf UI"

    function __awsp_profiles
        set -l profiles

        if test -f ~/.aws/config
            for line in (cat ~/.aws/config)
                set line (string trim $line)

                if string match -rq '^\[default\]$' $line
                    set profiles $profiles default
                else if string match -rq '^\[profile ' $line
                    set profiles $profiles (string replace -r '^\[profile (.+)\]$' '$1' $line)
                end
            end
        end

        if test -f ~/.aws/credentials
            for line in (cat ~/.aws/credentials)
                set line (string trim $line)

                if string match -rq '^\[[^]]+\]$' $line
                    set profiles $profiles (string replace -r '^\[(.+)\]$' '$1' $line)
                end
            end
        end

        printf "%s\n" $profiles | sort -u
    end

    function __awsp_current
        if set -q AWS_PROFILE
            echo $AWS_PROFILE
        else
            echo default
        end
    end

    function __awsp_apply --argument-names profile
        if test "$profile" = default
            set -e AWS_PROFILE
            set -e AWS_DEFAULT_PROFILE
        else
            set -gx AWS_PROFILE $profile
            set -gx AWS_DEFAULT_PROFILE $profile
        end
    end

    function __awsp_list
        set_color brwhite
        printf "%-2s %-20s\n" C PROFILE
        set_color normal

        for p in (__awsp_profiles)
            if test "$p" = (__awsp_current)
                set_color green
                printf "*  %s\n" $p
                set_color normal
            else
                printf "   %s\n" $p
            end
        end
    end

    function __awsp_fzf
        set selected ( __awsp_profiles | fzf \
            --prompt="AWS Profile > " \
            --height=70% \
            --reverse \
            --border \
            --preview="awsp_preview {}"
            --preview-window=right:60%:wrap )

        echo $selected
    end

    function __awsp_alias --argument-names profile
        if test "$profile" = default
            aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null
        else
            aws iam list-account-aliases --profile $profile --query 'AccountAliases[0]' --output text 2>/dev/null
        end
    end

    function __awsp_current_info
        set p (__awsp_current)

        echo "Profile : $p"
        echo "Alias   : "(__awsp_alias $p)
        echo "Region  : "(aws configure get region --profile $p)
    end

    switch $argv[1]

        case ""
            set selected (__awsp_fzf)
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

        case "*"
            __awsp_apply $argv[1]
            echo "Switched to $argv[1]"
    end

end