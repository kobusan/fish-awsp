complete -c awsp -f

complete -c awsp -n '__fish_use_subcommand' -a list -d 'List AWS profiles'
complete -c awsp -n '__fish_use_subcommand' -a current -d 'Show current profile'
complete -c awsp -n '__fish_use_subcommand' -a clear -d 'Clear AWS profile environment variables'

complete -c awsp -n '__fish_use_subcommand' -a '(__awsp_complete_profiles)' -d 'AWS profile'