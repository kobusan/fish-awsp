function awsp_preview --description "Preview selected AWS profile" --argument-names profile
    if test -z "$profile"
        return 1
    end

    function __awsp_preview_cache_dir
        echo ~/.cache/awsp-fish
    end

    function __awsp_preview_alias_cache_key --argument-names p
        echo (__awsp_preview_cache_dir)/alias-$p.txt
    end

    function __awsp_preview_get --argument-names key
        if test "$profile" = "default"
            set -l value (aws configure get $key 2>/dev/null)
        else
            set -l value (aws configure get $key --profile $profile 2>/dev/null)
        end

        if test -z "$value"
            echo "-"
        else
            echo $value
        end
    end

    function __awsp_preview_alias
        set -l cache_dir (__awsp_preview_cache_dir)
        set -l cache_key (__awsp_preview_alias_cache_key $profile)

        mkdir -p $cache_dir 2>/dev/null

        # 6時間キャッシュ
        if test -f $cache_key
            set -l now (date +%s)
            set -l mtime (stat -f %m $cache_key 2>/dev/null)

            if test -n "$mtime"
                set -l age (math $now - $mtime)
                if test $age -lt 21600
                    cat $cache_key
                    return 0
                end
            end
        end

        if test "$profile" = "default"
            set -l value (aws iam list-account-aliases --query 'AccountAliases[0]' --output text 2>/dev/null)
        else
            set -l value (aws iam list-account-aliases --profile $profile --query 'AccountAliases[0]' --output text 2>/dev/null)
        end

        if test -z "$value" -o "$value" = "None" -o "$value" = "null"
            set value "-"
        end

        printf "%s\n" $value > $cache_key
        echo $value
    end

    echo "PROFILE"
    echo "  $profile"
    echo

    echo "ACCOUNT ALIAS"
    echo "  "(__awsp_preview_alias)
    echo

    echo "REGION"
    echo "  "(__awsp_preview_get region)
    echo

    echo "ROLE ARN"
    echo "  "(__awsp_preview_get role_arn)
    echo

    echo "SOURCE PROFILE"
    echo "  "(__awsp_preview_get source_profile)
    echo

    echo "SSO SESSION"
    echo "  "(__awsp_preview_get sso_session)
    echo

    echo "SSO START URL"
    echo "  "(__awsp_preview_get sso_start_url)
end