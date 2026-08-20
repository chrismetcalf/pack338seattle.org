#!/usr/bin/env bash
#
# Start the Jekyll development server.
#
#   ./serve.sh                 # localhost only (default)
#   ./serve.sh --tailscale     # also reachable from your tailnet
#   ./serve.sh --lan           # reachable from anything on the local network
#   PORT=4001 ./serve.sh       # different port
#
# Any extra arguments are passed straight through to `jekyll serve`.

set -euo pipefail

cd "$(dirname "$0")"

PORT="${PORT:-4000}"
LIVERELOAD_PORT="${LIVERELOAD_PORT:-35729}"
mode="local"
passthrough=()

for arg in "$@"; do
    case "$arg" in
        --tailscale|-t) mode="tailscale" ;;
        --lan)          mode="lan" ;;
        -h|--help)
            sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) passthrough+=("$arg") ;;
    esac
done

if [[ ! -f "_config.yml" ]]; then
    echo "❌ No _config.yml here — run this from the project directory."
    exit 1
fi

if ! command -v bundle &> /dev/null; then
    echo "❌ Bundler not found. Run ./setup-ruby.sh first, or install Ruby + bundler."
    exit 1
fi

if [[ ! -f "Gemfile.lock" ]] || [[ ! -d "vendor/bundle" && ! -d ".bundle" ]]; then
    echo "📦 Installing dependencies..."
    bundle install
    echo ""
fi

host="127.0.0.1"
extra_urls=()

case "$mode" in
    tailscale)
        if ! command -v tailscale &> /dev/null; then
            echo "❌ tailscale not found on PATH. Install it from https://tailscale.com/download"
            exit 1
        fi

        backend_state="$(tailscale status --json 2>/dev/null \
            | grep -o '"BackendState": *"[^"]*"' | head -1 \
            | sed 's/.*"\([^"]*\)"$/\1/' || true)"
        if [[ "$backend_state" != "Running" ]]; then
            echo "❌ Tailscale is not connected (state: ${backend_state:-unknown}). Run: tailscale up"
            exit 1
        fi

        ts_ip="$(tailscale ip -4 2>/dev/null | head -1)"
        if [[ -z "$ts_ip" ]]; then
            echo "❌ Could not determine this machine's Tailscale IPv4 address."
            exit 1
        fi

        # MagicDNS name, e.g. my-box.your-tailnet.ts.net
        ts_name="$(tailscale status --json 2>/dev/null \
            | tr ',' '\n' | grep -m1 '"DNSName"' \
            | sed 's/.*"DNSName": *"\([^"]*\)".*/\1/' | sed 's/\.$//' || true)"

        # Bind to all interfaces so both localhost and the tailnet address work.
        # Tailscale itself gates who can reach the tailnet IP.
        host="0.0.0.0"
        [[ -n "$ts_name" ]] && extra_urls+=("http://${ts_name}:${PORT}/")
        extra_urls+=("http://${ts_ip}:${PORT}/")
        ;;
    lan)
        host="0.0.0.0"
        lan_ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
        [[ -n "$lan_ip" ]] && extra_urls+=("http://${lan_ip}:${PORT}/")
        ;;
esac

echo "🚀 Starting Jekyll (${mode})..."
echo ""
echo "   http://localhost:${PORT}/"
for url in ${extra_urls[@]+"${extra_urls[@]}"}; do
    echo "   $url"
done
if [[ "$mode" == "lan" ]]; then
    echo ""
    echo "   ⚠️  Bound to all interfaces — anyone on this network can reach it."
fi
echo ""
echo "   Ctrl+C to stop."
echo ""

exec bundle exec jekyll serve \
    --host "$host" \
    --port "$PORT" \
    --livereload \
    --livereload-port "$LIVERELOAD_PORT" \
    ${passthrough[@]+"${passthrough[@]}"}
