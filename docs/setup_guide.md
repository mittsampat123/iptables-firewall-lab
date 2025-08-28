# iptables Firewall Setup Guide

This guide will walk you through setting up a comprehensive Linux firewall using iptables for network security.

## Prerequisites

- Linux system (Ubuntu 20.04+ / CentOS 8+)
- Root access or sudo privileges
- Basic networking knowledge
- Terminal access

## Step 1: Install Required Packages

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install iptables iptables-persistent ipset netcat curl
```

### CentOS/RHEL
```bash
sudo yum install iptables iptables-services ipset nc curl
```

## Step 2: Backup Existing Rules

Before making any changes, backup your current firewall rules:

```bash
sudo iptables-save > /etc/iptables/rules.v4.backup
sudo ip6tables-save > /etc/iptables/rules.v6.backup
```

## Step 3: Deploy Firewall Rules

### Option 1: Deploy Base Rules Only
```bash
sudo bash rules/base_rules.sh
```

### Option 2: Deploy Web Server Rules
```bash
sudo bash rules/base_rules.sh
sudo bash rules/web_server_rules.sh
```

### Option 3: Use Firewall Manager (Recommended)
```bash
sudo chmod +x scripts/firewall_manager.sh
sudo ./scripts/firewall_manager.sh deploy base
```

## Step 4: Test Connectivity

Run the connectivity tests to verify everything is working:

```bash
chmod +x tests/connectivity_tests.sh
./tests/connectivity_tests.sh
```

## Step 5: Verify Firewall Status

Check the current firewall rules:

```bash
sudo ./scripts/firewall_manager.sh status
```

## Step 6: Make Rules Persistent

### Ubuntu/Debian
```bash
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
```

### CentOS/RHEL
```bash
sudo service iptables save
sudo systemctl enable iptables
```

## Firewall Manager Usage

The firewall manager script provides easy management of your firewall:

```bash
# Deploy different rule sets
sudo ./scripts/firewall_manager.sh deploy base
sudo ./scripts/firewall_manager.sh deploy web
sudo ./scripts/firewall_manager.sh deploy full

# Check status
sudo ./scripts/firewall_manager.sh status

# Block/unblock IPs
sudo ./scripts/firewall_manager.sh block 192.168.1.100 "Suspicious activity"
sudo ./scripts/firewall_manager.sh unblock 192.168.1.100

# Backup and restore
sudo ./scripts/firewall_manager.sh backup
sudo ./scripts/firewall_manager.sh restore backups/iptables_backup_20231201_120000.rules
```

## Rule Explanations

### Base Rules
- **Default Policies**: DROP for INPUT/FORWARD, ACCEPT for OUTPUT
- **Loopback**: Allow all localhost traffic
- **Established Connections**: Allow existing connections
- **ICMP**: Rate-limited ping responses
- **SSH**: Rate-limited SSH access (2/minute)
- **Web Traffic**: Rate-limited HTTP/HTTPS (25/minute)
- **DNS/NTP**: Allow essential services
- **Logging**: Log all dropped packets

### Web Server Rules
- **Custom Chain**: WEB_SERVER for specialized web traffic handling
- **TCP Flags**: Block invalid TCP flag combinations
- **Rate Limiting**: 30 connections/minute for web traffic
- **Attack Detection**: Log potential web attacks

## Monitoring and Logs

### View Firewall Logs
```bash
# Real-time log monitoring
sudo tail -f /var/log/kern.log | grep IPTABLES

# View blocked IPs
cat logs/blocked_ips.log

# View firewall activity
cat logs/firewall.log
```

### Analyze Attack Patterns
```bash
# Count blocked connections
sudo iptables -L INPUT -v -n | grep DROP

# View recent attacks
sudo grep "IPTABLES-DROPPED" /var/log/kern.log | tail -20
```

## Troubleshooting

### Common Issues

1. **Locked Out of SSH**
   ```bash
   # If you get locked out, connect via console and restore backup
   sudo iptables-restore < /etc/iptables/rules.v4.backup
   ```

2. **Web Services Not Accessible**
   ```bash
   # Check if web ports are open
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :443
   ```

3. **DNS Resolution Issues**
   ```bash
   # Test DNS connectivity
   nslookup google.com 8.8.8.8
   ```

### Performance Optimization

1. **Rule Ordering**: Most common rules first
2. **Connection Tracking**: Use state module for established connections
3. **Rate Limiting**: Prevent DoS attacks
4. **Logging**: Limit log verbosity to prevent performance impact

## Security Best Practices

1. **Principle of Least Privilege**: Only allow necessary traffic
2. **Defense in Depth**: Multiple layers of protection
3. **Regular Updates**: Keep rules updated with new threats
4. **Monitoring**: Continuous monitoring of firewall logs
5. **Backup**: Regular backups of firewall configurations

## Compliance

This firewall implementation supports various compliance frameworks:

- **NIST Cybersecurity Framework**
- **ISO 27001**
- **PCI DSS**
- **SOX Compliance**

## Next Steps

1. **Customize Rules**: Modify rules for your specific environment
2. **Add Monitoring**: Set up automated monitoring and alerting
3. **Documentation**: Document your specific configuration
4. **Training**: Train team members on firewall management
5. **Regular Reviews**: Schedule regular security reviews

## Support

For issues or questions:
- Check the troubleshooting section
- Review firewall logs
- Test connectivity step by step
- Restore from backup if needed
