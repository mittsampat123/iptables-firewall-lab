#!/bin/bash

FIREWALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES_DIR="$FIREWALL_DIR/rules"
BACKUP_DIR="$FIREWALL_DIR/backups"
LOG_DIR="$FIREWALL_DIR/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/firewall.log"
}

backup_rules() {
    log_message "Creating backup of current iptables rules..."
    iptables-save > "$BACKUP_DIR/iptables_backup_$(date +%Y%m%d_%H%M%S).rules"
    ip6tables-save > "$BACKUP_DIR/ip6tables_backup_$(date +%Y%m%d_%H%M%S).rules"
    log_message "Backup completed successfully"
}

restore_rules() {
    local backup_file="$1"
    if [[ -z "$backup_file" ]]; then
        echo "Usage: $0 restore <backup_file>"
        echo "Available backups:"
        ls -la "$BACKUP_DIR"/*.rules 2>/dev/null || echo "No backups found"
        exit 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        log_message "ERROR: Backup file $backup_file not found"
        exit 1
    fi
    
    log_message "Restoring iptables rules from $backup_file..."
    iptables-restore < "$backup_file"
    log_message "Rules restored successfully"
}

deploy_rules() {
    local rule_set="$1"
    
    log_message "Deploying firewall rules: $rule_set"
    backup_rules
    
    case "$rule_set" in
        "base")
            bash "$RULES_DIR/base_rules.sh"
            ;;
        "web")
            bash "$RULES_DIR/base_rules.sh"
            bash "$RULES_DIR/web_server_rules.sh"
            ;;
        "full")
            bash "$RULES_DIR/base_rules.sh"
            bash "$RULES_DIR/web_server_rules.sh"
            bash "$RULES_DIR/database_rules.sh"
            bash "$RULES_DIR/vpn_rules.sh"
            ;;
        *)
            echo "Usage: $0 deploy <base|web|full>"
            exit 1
            ;;
    esac
    
    log_message "Firewall rules deployed successfully"
}

show_status() {
    echo "=== iptables Status ==="
    echo "INPUT Chain:"
    iptables -L INPUT -n --line-numbers
    echo ""
    echo "FORWARD Chain:"
    iptables -L FORWARD -n --line-numbers
    echo ""
    echo "OUTPUT Chain:"
    iptables -L OUTPUT -n --line-numbers
    echo ""
    echo "Custom Chains:"
    iptables -L WEB_SERVER -n --line-numbers 2>/dev/null || echo "WEB_SERVER chain not found"
}

block_ip() {
    local ip="$1"
    local reason="${2:-Manual block}"
    
    if [[ -z "$ip" ]]; then
        echo "Usage: $0 block <ip_address> [reason]"
        exit 1
    fi
    
    log_message "Blocking IP: $ip (Reason: $reason)"
    iptables -A INPUT -s "$ip" -j DROP
    iptables -A OUTPUT -d "$ip" -j DROP
    echo "$ip - $(date) - $reason" >> "$LOG_DIR/blocked_ips.log"
    log_message "IP $ip blocked successfully"
}

unblock_ip() {
    local ip="$1"
    
    if [[ -z "$ip" ]]; then
        echo "Usage: $0 unblock <ip_address>"
        exit 1
    fi
    
    log_message "Unblocking IP: $ip"
    iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
    iptables -D OUTPUT -d "$ip" -j DROP 2>/dev/null
    log_message "IP $ip unblocked successfully"
}

case "$1" in
    "deploy")
        deploy_rules "$2"
        ;;
    "restore")
        restore_rules "$2"
        ;;
    "status")
        show_status
        ;;
    "block")
        block_ip "$2" "$3"
        ;;
    "unblock")
        unblock_ip "$2"
        ;;
    "backup")
        backup_rules
        ;;
    *)
        echo "Usage: $0 {deploy|restore|status|block|unblock|backup}"
        echo ""
        echo "Commands:"
        echo "  deploy <base|web|full>  - Deploy firewall rules"
        echo "  restore <backup_file>   - Restore from backup"
        echo "  status                  - Show current rules"
        echo "  block <ip> [reason]     - Block an IP address"
        echo "  unblock <ip>            - Unblock an IP address"
        echo "  backup                  - Create backup of current rules"
        exit 1
        ;;
esac
