complete -c awsp -f

complete -c awsp -n '__fish_use_subcommand' -a list -d 'List AWS profiles'
complete -c awsp -n '__fish_use_subcommand' -a current -d 'Show current profile'
complete -c awsp -n '__fish_use_subcommand' -a clear -d 'Clear AWS profile environment variables'

complete -c awsp -n '__fish_use_subcommand' -a '(begin
    if test -f ~/.aws/config
        for line in (cat ~/.aws/config)
            set line (string trim -- $line)
            if string match -rq "^\[default\]$" -- $line
                echo default
            else if string match -rq "^\[profile .+\]$" -- $line
                string replace -r "^\[profile (.+)\]$" "\$1" -- $line
            end
        end
    end

    if test -f ~/.aws/credentials
        for line in (cat ~/.aws/credentials)
            set line (string trim -- $line)
            if string match -rq "^\[[^]]+\]$" -- $line
                string replace -r "^\[(.+)\]$" "\$1" -- $line
            end
        end
    end
end | sort -u)' -d 'AWS profile'