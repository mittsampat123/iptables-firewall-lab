#!/bin/bash

echo "=== Firewall Connectivity Tests ==="
echo "Testing basic connectivity and firewall rules..."
echo ""

test_ssh() {
    echo "Testing SSH connectivity..."
    if nc -z localhost 22 2>/dev/null; then
        echo "✓ SSH (port 22) is accessible"
    else
        echo "✗ SSH (port 22) is blocked"
    fi
}

test_http() {
    echo "Testing HTTP connectivity..."
    if nc -z localhost 80 2>/dev/null; then
        echo "✓ HTTP (port 80) is accessible"
    else
        echo "✗ HTTP (port 80) is blocked"
    fi
}

test_https() {
    echo "Testing HTTPS connectivity..."
    if nc -z localhost 443 2>/dev/null; then
        echo "✓ HTTPS (port 443) is accessible"
    else
        echo "✗ HTTPS (port 443) is blocked"
    fi
}

test_dns() {
    echo "Testing DNS connectivity..."
    if nc -z 8.8.8.8 53 2>/dev/null; then
        echo "✓ DNS (port 53) is accessible"
    else
        echo "✗ DNS (port 53) is blocked"
    fi
}

test_ntp() {
    echo "Testing NTP connectivity..."
    if nc -z pool.ntp.org 123 2>/dev/null; then
        echo "✓ NTP (port 123) is accessible"
    else
        echo "✗ NTP (port 123) is blocked"
    fi
}

test_blocked_ports() {
    echo "Testing commonly blocked ports..."
    
    local blocked_ports=(21 23 25 110 143 993 995 3389 5900 8080)
    
    for port in "${blocked_ports[@]}"; do
        if nc -z localhost "$port" 2>/dev/null; then
            echo "✗ Port $port is accessible (should be blocked)"
        else
            echo "✓ Port $port is properly blocked"
        fi
    done
}

test_icmp() {
    echo "Testing ICMP (ping) functionality..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✓ ICMP is working"
    else
        echo "✗ ICMP is blocked"
    fi
}

test_outbound() {
    echo "Testing outbound connectivity..."
    if curl -s --connect-timeout 5 https://www.google.com >/dev/null; then
        echo "✓ Outbound HTTPS is working"
    else
        echo "✗ Outbound HTTPS is blocked"
    fi
}

run_all_tests() {
    test_ssh
    echo ""
    test_http
    test_https
    echo ""
    test_dns
    test_ntp
    echo ""
    test_icmp
    test_outbound
    echo ""
    test_blocked_ports
}

run_all_tests

echo ""
echo "=== Test Summary ==="
echo "Tests completed. Check results above for any issues."
echo "For detailed firewall status, run: sudo ./firewall_manager.sh status"
