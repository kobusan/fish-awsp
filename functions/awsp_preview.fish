function awsp_preview --argument-names profile

    if test -z "$profile"
        return
    end

    function get
        aws configure get $argv[1] --profile $profile
    end

    function alias
        aws iam list-account-aliases --profile $profile --query 'AccountAliases[0]' --output text 2>/dev/null
    end

    echo "PROFILE"
    echo "  $profile"
    echo

    echo "ACCOUNT ALIAS"
    echo "  "(alias)
    echo

    echo "REGION"
    echo "  "(get region)
    echo

    echo "ROLE"
    echo "  "(get role_arn)
    echo

    echo "SOURCE PROFILE"
    echo "  "(get source_profile)
    echo

    echo "SSO SESSION"
    echo "  "(get sso_session)

end