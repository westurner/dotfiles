#!/bin/sh

_THIS=$(basename "$0")
setup_auditd_rules_usage() {
    echo "${_THIS} [-h]"
    echo "  -i/--install/install  cp rules files to /etc/audit/rules.d && chcon"
    echo "  -s/--status/status    ls -alZ /etc/audit/rules.d; auditctl -l"
    echo "  -h/--help/help        print help"
    echo ""
}

setup_auditd_rules_install() {
    rule_files_to_install=(
        "20-kernelmods.rules"
        "30-allcmds.rules"
    )
    for rules in "${rule_files_to_install[@]}"; do
        cp -v "${rules}" /etc/audit/rules.d/ && \
            chcon -u system_u -r object_r -t auditd_etc_t "${rules}"
        ls -alZ "/etc/audit/rules.d/"
    done
}

_setup_auditd_rules_status() {
    ls -alZ /etc/audit/rules.d
    auditctl -l
    #cat /etc/audit/rules.d/audit.rules
    find /etc/audit/rules.d -type f -name '*.rules' -print0 | 
        while IFS= read -r -d '' line; do 
            (set +x; echo "##    $line")
            cat "$line"
        done
    systemctl status auditd.service
    systemctl status audit-rules.service
}

setup_auditd_rules_status() {
    (set -x; _setup_auditd_rules_status "${@}")
}


setup_auditd_main() {
    if [ -z "${*}" ]; then
        setup_auditd_rules_usage
        exit 0
    fi
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help)
                setup_auditd_rules_usage;
                exit 0;
                ;;
        esac
    done
    commands_run=
    for arg in "${@}"; do
        case "${arg}" in
            -s|--status|status)
                shift
                (set -x; setup_auditd_rules_status)
                commands_run="${commands_run:+"${commands_run} "}status"
                ;;
            -i|--install|install)
                shift
                (set -x; setup_auditd_rules_install)
                commands_run="${commands_run:+"${commands_run} "}install"
                ;;
            --start|start)
                shift
                (set -x; systemctl start auditd)
                commands_run="${commands_run:+"${commands_run} "}start"
                ;;
            --stop|stop)
                shift
                (set -x; systemctl stop auditd)
                commands_run="${commands_run:+"${commands_run} "}stop"
                ;;
            --restart|restart)
                shift
                (set -x; systemctl restart audit-rules)
                (set -x; systemctl restart auditd)
                commands_run="${commands_run:+"${commands_run} "}restart"
                ;;
            sleep)
                shift
                sleep 10;
                commands_run="${commands_run:+"${commands_run} "}sleep"
                ;;
            --log|--logs|log|logs)
                shift
                (set -x; journalctl -u auditd "${@}")       # -s today
                (set -x; journalctl -u auditd-rules "${@}") # -s today
                commands_run="${commands_run:+"${commands_run} "}log"
                ;;
            --tail|tail)
                shift
                (set -x; tail "${@}" /var/log/audit/audit.log)
                commands_run="${commands_run:+"${commands_run} "}tail"
                ;;
        esac
    done
    if [ -z "${commands_run}" ]; then
        echo "ERROR: No commands were run."
        echo ""
        setup_auditd_rules_usage
        exit 2
    fi
}

setup_auditd_main "${@}"
