import argparse
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(
        description='Measure network bandwidth using ping')
    parser.add_argument(
        'target_ip', help='IP address of target device or server')
    parser.add_argument('-n', '--num_packets', type=int, default=10,
                        help='Number of ping packets to send (default: 10)')
    parser.add_argument('-s', '--packet_size', type=int, default=56,
                        help='Size of each ping packet in bytes (default: 56)')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-l', '--bandwidth_limit', type=float, default=None,
                       help='Maximum allowed network bandwidth in Mbps (default: None)')
    group.add_argument('-p', '--bandwidth_percent', type=float, default=None,
                       help='Maximum allowed network bandwidth as percentage of maximum possible bandwidth based on packet size (default: None)')
    args = parser.parse_args()

    # Build the ping command using the specified arguments
    command = ['ping', '-n', str(args.num_packets),
               '-l', str(args.packet_size), args.target_ip]

    # Run the ping command and capture the output
    ping_output = subprocess.run(command, capture_output=True, text=True)

    # Parse the ping output to extract the total round-trip time (RTT) for all packets
    rtt_pattern = r"Minimum = \d+ms, Maximum = \d+ms, Average = (?P<avg_rtt>\d+)ms"
    rtt_match = re.search(rtt_pattern, ping_output.stdout)
    if rtt_match:
        total_rtt = int(rtt_match.group('avg_rtt')) * args.num_packets
    else:
        print("Error: Could not extract round-trip time from ping output")
        return 1

    # Calculate the network bandwidth in Mbps
    bandwidth = (args.num_packets * args.packet_size * 8) / \
        (total_rtt / 1000) / 1000000

    # Check if the measured bandwidth exceeds the specified limits (if any)
    if args.bandwidth_limit is not None and bandwidth > args.bandwidth_limit:
        print(
            f"Error: Measured bandwidth of {bandwidth:.2f} Mbps exceeds bandwidth limit of {args.bandwidth_limit:.2f} Mbps")
        return 1
    elif args.bandwidth_percent is not None:
        max_bandwidth = args.packet_size * 8 * \
            1000 / (total_rtt / args.num_packets)
        limit_bandwidth = max_bandwidth * args.bandwidth_percent / 100
        if bandwidth > limit_bandwidth:
            print(
                f"Error: Measured bandwidth of {bandwidth:.2f} Mbps exceeds percentage limit of {args.bandwidth_percent:.2f}% (limit: {limit_bandwidth:.2f} Mbps)")
            return 1

    # Print the measured bandwidth and exit with success code
    print(f"Measured bandwidth to {args.target_ip}: {bandwidth:.2f} Mbps")
    return 0


if __name__ == '__main__':
    exit_code = main()
    exit(exit_code)
