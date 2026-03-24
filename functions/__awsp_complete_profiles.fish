function __awsp_complete_profiles --description "Return AWS profile names for completion"
    set -l profiles

    if test -f "$HOME/.aws/config"
        for line in (cat "$HOME/.aws/config")
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

    if test -f "$HOME/.aws/credentials"
        for line in (cat "$HOME/.aws/credentials")
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