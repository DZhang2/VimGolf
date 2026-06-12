#!/bin/bash

# Vim Golf - Terminal Edition
# Solve editing challenges in as few keystrokes as possible!


SCORE_FILE="/tmp/vimgolf_scores"
LEVEL_DIR="/tmp/vimgolf_levels"
mkdir -p "$LEVEL_DIR"

# Level definitions live in data files (one per level) next to this script.
# This keeps the game logic separate from content so new levels can be added
# by dropping in a NN.level file — no code changes required.
#   tutorial/  — beginner track: motions, text objects, visual block, macros
#   levels/    — normal track: powerful Ex commands (:s, :g, :sort, filters)
#   expert/    — expert track: multi-stage challenges, no solution key
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEVELS_DATA_DIR="$SCRIPT_DIR/levels"
TUTORIAL_DATA_DIR="$SCRIPT_DIR/tutorial"
EXPERT_DATA_DIR="$SCRIPT_DIR/expert"

# Map a mode name to the directory holding its .level files.
mode_data_dir() {
    case "$1" in
        tutorial) echo "$TUTORIAL_DATA_DIR" ;;
        expert)   echo "$EXPERT_DATA_DIR" ;;
        *)        echo "$LEVELS_DATA_DIR" ;;
    esac
}

# Count of .level files in a directory (defaults if the dir is missing).
count_data_levels() {
    local n
    n=$(ls "$1"/[0-9][0-9].level 2>/dev/null | wc -l | tr -d ' ')
    { [ -z "$n" ] || [ "$n" -eq 0 ]; } && n=0
    echo "$n"
}

TOTAL_LEVELS=$(count_data_levels "$LEVELS_DATA_DIR");      [ "$TOTAL_LEVELS" -eq 0 ] && TOTAL_LEVELS=15
TOTAL_TUTORIAL_LEVELS=$(count_data_levels "$TUTORIAL_DATA_DIR"); [ "$TOTAL_TUTORIAL_LEVELS" -eq 0 ] && TOTAL_TUTORIAL_LEVELS=15
TOTAL_EXPERT_LEVELS=$(count_data_levels "$EXPERT_DATA_DIR")

# Hard mode is the programmatically-scaled variant of the normal levels.
TOTAL_HARD_LEVELS=15

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

print_banner() {
    echo -e "${GREEN}"
    echo '  ╦  ╦╦╔╦╗  ╔═╗╔═╗╦  ╔═╗'
    echo '  ╚╗╔╝║║║║  ║ ╦║ ║║  ╠╣ '
    echo '   ╚╝ ╩╩ ╩  ╚═╝╚═╝╩═╝╚  '
    echo -e "${NC}"
    echo -e "  ${DIM}Terminal Edition — fewest keystrokes wins${NC}"
    echo ""
}

# Parse a level data file (<dir>/NN.level) for the given level number.
# Args: <level> [mode]   (mode: normal | tutorial; defaults to normal)
# Writes the START block to start_file and GOAL block to goal_file, then
# echoes "par|hint1|hint2|desc" on stdout (matching the legacy interface).
# Returns 1 if the data file is missing.
setup_level() {
    local level=$1
    local mode=${2:-normal}
    local data_dir
    data_dir=$(mode_data_dir "$mode")
    local start_file="$LEVEL_DIR/${mode}_start_${level}.txt"
    local goal_file="$LEVEL_DIR/${mode}_goal_${level}.txt"
    local data_file
    data_file=$(printf '%s/%02d.level' "$data_dir" "$level")
    [ -f "$data_file" ] || return 1

    # awk splits the file into the metadata header and the START/GOAL bodies,
    # writing the two bodies straight to their target files (preserving every
    # space) and printing the metadata fields back for the caller to capture.
    awk -v sf="$start_file" -v gf="$goal_file" '
        BEGIN { section = "meta"; par = ""; h1 = ""; h2 = ""; desc = "" }
        /^--- START ---$/ { section = "start"; next }
        /^--- GOAL ---$/  { section = "goal";  next }
        /^--- END ---$/   { section = "done";  next }
        section == "meta" {
            key = $0; sub(/:.*/, "", key)
            val = $0; sub(/^[^:]*: ?/, "", val)
            if (key == "par")   par = val
            else if (key == "hint1") h1 = val
            else if (key == "hint2") h2 = val
            else if (key == "desc")  desc = val
            next
        }
        section == "start" { print > sf; next }
        section == "goal"  { print > gf; next }
        END { printf "%s|%s|%s|%s\n", par, h1, h2, desc }
    ' "$data_file"
}

is_level_completed() {
    local level=$1
    [ -f "$SCORE_FILE" ] && grep -q "^level${level}:" "$SCORE_FILE"
}

setup_hard_level() {
    local level=$1
    local start_file="$LEVEL_DIR/hard_start_${level}.txt"
    local goal_file="$LEVEL_DIR/hard_goal_${level}.txt"
    local par=""
    local hint1=""
    local hint2=""
    local desc=""

    case $level in
        1)
            desc="Delete line 50 (out of 100)"
            par=5
            hint1="Line addressing is faster than scrolling"
            hint2="Ex command :Nd deletes line N directly"
            # 100 lines, need to delete line 50
            seq 1 100 | sed 's/^/line /' > "$start_file"
            seq 1 100 | sed 's/^/line /' | sed '50d' > "$goal_file"
            ;;
        2)
            desc="Change 'foo' to 'bar' on 100 lines"
            par=12
            hint1="The same command scales to any file size"
            hint2=":%s doesn't care if the file is 3 or 3000 lines"
            for i in $(seq 1 100); do echo "line $i has foo in it"; done > "$start_file"
            for i in $(seq 1 100); do echo "line $i has bar in it"; done > "$goal_file"
            ;;
        3)
            desc="Reverse 100 lines"
            par=8
            hint1="Your solution should be line-count agnostic"
            hint2="The same global+move trick works regardless of file length"
            seq 1 100 > "$start_file"
            seq 100 -1 1 > "$goal_file"
            ;;
        4)
            desc="Surround 100 words with quotes"
            par=11
            hint1="If your solution mentions a count, it won't scale"
            hint2=":%s on .* works for any number of lines"
            local words=("alpha" "bravo" "charlie" "delta" "echo" "foxtrot" "golf" "hotel"
                        "india" "juliet" "kilo" "lima" "mike" "november" "oscar" "papa"
                        "quebec" "romeo" "sierra" "tango" "uniform" "victor" "whiskey" "xray"
                        "yankee" "zulu" "amber" "bronze" "coral" "dusk" "ember" "frost"
                        "garnet" "haze" "ivory" "jade" "karma" "lapis" "mango" "nebula"
                        "opal" "prism" "quartz" "ruby" "slate" "topaz" "umber" "velvet"
                        "willow" "xenon" "yarrow" "zinc" "acacia" "basil" "cedar" "daisy"
                        "elm" "fern" "ginger" "holly" "iris" "jasmine" "kelp" "laurel"
                        "maple" "nettle" "orchid" "palm" "reed" "sage" "thyme" "violet"
                        "wisteria" "yarrow" "azalea" "birch" "clover" "daffodil" "eucalyptus"
                        "fig" "grape" "hazel" "ivy" "juniper" "kale" "lemon" "mint"
                        "nutmeg" "olive" "peach" "rose" "saffron" "tulip" "vanilla"
                        "walnut" "xylose" "yew" "zinnia" "apricot" "bay" "cumin")
            printf '%s\n' "${words[@]:0:100}" > "$start_file"
            sed 's/.*/"&"/' "$start_file" > "$goal_file"
            ;;
        5)
            desc="Convert 50 camelCase identifiers to snake_case"
            par=16
            hint1="The regex solution is O(1) keystrokes regardless of line count"
            hint2=":%s/\\u/_\\l&/g with % range — same command, 50 lines"
            local camels=("camelCase" "getUserName" "processItem" "doStuff" "valueOf"
                         "getFirstName" "setLastName" "isReady" "hasPermission" "canExecute"
                         "findElement" "createElement" "removeChild" "appendChild" "insertBefore"
                         "getContext" "setInterval" "clearTimeout" "addListener" "removeHandler"
                         "fetchData" "parseResult" "formatOutput" "validateInput" "transformItem"
                         "openFile" "closeStream" "readBuffer" "writeContent" "flushCache"
                         "startEngine" "stopProcess" "pauseTimer" "resumeTask" "cancelJob"
                         "buildProject" "deployService" "testModule" "debugError" "logMessage"
                         "sendRequest" "getResponse" "postUpdate" "deleteRecord" "patchConfig"
                         "mountVolume" "unmountDisk" "formatDrive" "scanPort" "pingHost")
            printf '%s\n' "${camels[@]}" > "$start_file"
            perl -pe 's/([a-z])([A-Z])/${1}_\l$2/g' "$start_file" > "$goal_file"
            ;;
        6)
            desc="Sort and deduplicate 200 lines (50 unique)"
            par=7
            hint1="The ex command doesn't care about input size"
            hint2=":sort u — same 7 keystrokes whether it's 7 or 700 lines"
            local items=("apple" "banana" "cherry" "date" "elderberry" "fig" "grape"
                        "honeydew" "kiwi" "lemon" "mango" "nectarine" "orange" "papaya"
                        "quince" "raspberry" "strawberry" "tangerine" "ugli" "vanilla"
                        "watermelon" "ximenia" "yuzu" "zucchini" "almond" "blueberry"
                        "coconut" "dragonfruit" "eggplant" "fennel" "guava" "hazelnut"
                        "jackfruit" "kumquat" "lime" "mulberry" "nutmeg" "olive" "peach"
                        "raisin" "sage" "tamarind" "ube" "vine" "walnut" "xigua"
                        "yam" "zest" "apricot" "boysenberry")
            # Repeat each item ~4 times in random-ish order
            for rep in 1 2 3 4; do
                for item in "${items[@]}"; do echo "$item"; done
            done | sort -R 2>/dev/null | head -200 > "$start_file"
            # If sort -R not available, use a deterministic shuffle
            if [ ! -s "$start_file" ]; then
                for rep in 1 2 3 4; do
                    for item in "${items[@]}"; do echo "$item"; done
                done | awk 'BEGIN{srand(42)}{print rand()"\t"$0}' | sort -n | cut -f2 | head -200 > "$start_file"
            fi
            sort -u "$start_file" > "$goal_file"
            ;;
        7)
            desc="Increment all numbers by 1 (50 lines, 2 numbers each)"
            par=12
            hint1="A macro that handles one line replays to handle all"
            hint2="Record: Ctrl-A, move past, Ctrl-A, next line — then replay 49 times"
            for i in $(seq 1 50); do
                printf "item %d: value %d\n" "$i" "$((i * 10))"
            done > "$start_file"
            for i in $(seq 1 50); do
                printf "item %d: value %d\n" "$((i + 1))" "$((i * 10 + 1))"
            done > "$goal_file"
            ;;
        8)
            desc="Convert 30-row CSV to markdown table"
            par=30
            hint1="Same substitution approach — the manual part is just the separator"
            hint2=":%s handles all rows; you only type the --- line once"
            {
                echo "name,age,city,role"
                local names=("Alice" "Bob" "Carol" "Dave" "Eve" "Frank" "Grace" "Hank"
                           "Iris" "Jack" "Kate" "Leo" "Mia" "Nick" "Olga" "Pete"
                           "Quinn" "Rose" "Sam" "Tina" "Uma" "Vince" "Wendy" "Xander"
                           "Yuki" "Zane" "Amy" "Brian" "Chloe" "Derek")
                local cities=("NYC" "LA" "SF" "CHI" "SEA" "ATX" "DEN" "MIA" "BOS" "PDX")
                local roles=("eng" "mgr" "ops" "sre" "qa")
                for i in $(seq 0 29); do
                    echo "${names[$i]},$((20 + RANDOM % 40)),${cities[$((i % 10))]},${roles[$((i % 5))]}"
                done
            } > "$start_file"
            {
                # Build the goal
                local header
                header=$(head -1 "$start_file")
                echo "| ${header//,/ | } |"
                echo "|------|-----|------|------|"
                tail -n +2 "$start_file" | while IFS= read -r line; do
                    echo "| ${line//,/ | } |"
                done
            } > "$goal_file"
            ;;
        9)
            desc="Align = signs across 30 variable assignments"
            par=22
            hint1="Manual dot-repeat won't scale — think substitution or external tools"
            hint2=":%!column -t or a clever substitution with \\s can align columns"
            local varnames=("x" "ip" "url" "name" "port" "host" "timeout"
                          "db" "key" "val" "max" "min" "count" "index"
                          "path" "file" "mode" "size" "type" "flag"
                          "mask" "base" "root" "node" "edge" "rate"
                          "step" "seed" "tag" "log")
            for v in "${varnames[@]}"; do
                echo "$v = 1"
            done > "$start_file"
            # Align: pad each name to length of longest (7 = "timeout")
            for v in "${varnames[@]}"; do
                printf "%-7s = 1\n" "$v"
            done > "$goal_file"
            ;;
        10)
            desc="Extract 50 function names from Python source"
            par=20
            hint1="Same approach scales — inverse global + norm"
            hint2=":v/^d/d removes non-def lines, :%norm trims the rest"
            {
                local fnames=("init" "setup" "teardown" "connect" "disconnect"
                             "send_data" "recv_data" "parse_msg" "validate_req" "handle_err"
                             "open_conn" "close_conn" "read_buf" "write_buf" "flush_buf"
                             "start_srv" "stop_srv" "restart_srv" "check_health" "get_status"
                             "set_config" "load_config" "save_config" "reset_config" "dump_state"
                             "create_user" "delete_user" "update_user" "find_user" "list_users"
                             "add_item" "remove_item" "get_item" "put_item" "scan_items"
                             "encode_msg" "decode_msg" "compress" "decompress" "encrypt"
                             "decrypt" "sign_token" "verify_token" "refresh_token" "revoke_token"
                             "run_task" "stop_task" "queue_task" "poll_queue" "drain_queue")
                for f in "${fnames[@]}"; do
                    echo "def ${f}(self, *args):"
                    echo "    logger.info('${f} called')"
                    echo "    pass"
                    echo ""
                done
            } > "$start_file"
            printf '%s\n' "${fnames[@]}" > "$goal_file"
            ;;
        11)
            desc="Swap two columns (100 rows)"
            par=27
            hint1="External filter doesn't care about row count"
            hint2=":%!awk — same command, 100 lines processed instantly"
            for i in $(seq 1 100); do
                printf "user%-4d %03d\n" "$i" "$((RANDOM % 999))"
            done > "$start_file"
            awk '{printf "%s   %s\n", $2, $1}' "$start_file" > "$goal_file"
            ;;
        12)
            desc="Remove 50 blank lines from 100 content lines"
            par=7
            hint1="Same command, bigger file — still 7 keystrokes"
            hint2=":v/./d works on any file size"
            {
                for i in $(seq 1 100); do
                    echo "content line $i"
                    echo ""
                done
            } > "$start_file"
            grep -v '^$' "$start_file" > "$goal_file"
            ;;
        13)
            desc="Convert 50 items to JSON array"
            par=24
            hint1="Substitution + edge fixes — count doesn't matter"
            hint2=":%s wraps all lines; \$x removes last comma; add brackets"
            local colors=("red" "orange" "yellow" "green" "blue" "indigo" "violet"
                         "crimson" "scarlet" "coral" "salmon" "peach" "amber" "gold"
                         "lime" "emerald" "teal" "cyan" "azure" "navy" "cobalt"
                         "plum" "magenta" "fuchsia" "pink" "rose" "maroon" "burgundy"
                         "chocolate" "sienna" "tan" "khaki" "ivory" "cream" "snow"
                         "silver" "charcoal" "slate" "onyx" "obsidian" "jet" "ebony"
                         "pearl" "opal" "ruby" "sapphire" "topaz" "garnet" "jade" "amethyst")
            printf '%s\n' "${colors[@]}" > "$start_file"
            {
                echo "["
                local total=${#colors[@]}
                for ((i=0; i<total; i++)); do
                    if [ $i -lt $((total - 1)) ]; then
                        echo "  \"${colors[$i]}\","
                    else
                        echo "  \"${colors[$i]}\""
                    fi
                done
                echo "]"
            } > "$goal_file"
            ;;
        14)
            desc="Number 100 lines (1. through 100.)"
            par=17
            hint1="Sequential increment is the only sane approach at scale"
            hint2="Prepend 0. then visual-block g Ctrl-A — handles multi-digit numbers"
            local items=("apple" "banana" "cherry" "date" "elderberry" "fig" "grape"
                        "honeydew" "kiwi" "lemon" "mango" "nectarine" "orange" "papaya"
                        "quince" "raspberry" "strawberry" "tangerine" "ugli" "vanilla"
                        "watermelon" "ximenia" "yuzu" "zucchini" "almond" "blueberry"
                        "coconut" "dragonfruit" "eggplant" "fennel" "guava" "hazelnut"
                        "jackfruit" "kumquat" "lime" "mulberry" "nutmeg" "olive" "peach"
                        "raisin" "sage" "tamarind" "ube" "vine" "walnut" "xigua"
                        "yam" "zest" "apricot" "boysenberry" "cantaloupe" "damson"
                        "entawak" "feijoa" "gooseberry" "huckleberry" "imbe" "jambul"
                        "kiwano" "longan" "mangosteen" "nance" "otaheite" "pitaya"
                        "quandong" "rambutan" "soursop" "tamarillo" "ugni" "voavanga"
                        "wampee" "xoconostle" "yangmei" "zapote" "acerola" "bilberry"
                        "calamansi" "durian" "etrog" "fingerlime" "gac" "honeyberry"
                        "ilama" "jabuticaba" "korlan" "lucuma" "mamey" "noni"
                        "olallieberry" "pawpaw" "quararibea" "rollinia" "salak" "tucuma"
                        "uvalha" "velvet" "whitecurrant" "xylocarp" "yellowhorn" "ziziphus")
            printf '%s\n' "${items[@]:0:100}" > "$start_file"
            {
                local n=1
                while IFS= read -r line; do
                    echo "${n}. ${line}"
                    n=$((n + 1))
                done < "$start_file"
            } > "$goal_file"
            ;;
        15)
            desc="Final Boss x10: flatten 20 objects to YAML"
            par=25
            hint1="Same regex, bigger file — prove it scales"
            hint2="The :%s with \\| alternation handles any number of lines"
            {
                local sections=("server" "database" "cache" "auth" "logging" "metrics"
                               "storage" "queue" "email" "cdn" "proxy" "scheduler"
                               "worker" "gateway" "monitor" "backup" "search" "notify"
                               "billing" "audit")
                local keys=("host" "port" "timeout" "retries" "enabled")
                local vals=("localhost" "8080" "30" "3" "true")
                for s in "${sections[@]}"; do
                    local pairs=""
                    for i in $(seq 0 4); do
                        if [ -n "$pairs" ]; then
                            pairs="${pairs}, ${keys[$i]}: ${vals[$i]}"
                        else
                            pairs="${keys[$i]}: ${vals[$i]}"
                        fi
                    done
                    echo "${s}: {${pairs}}"
                done
            } > "$start_file"
            {
                local sections=("server" "database" "cache" "auth" "logging" "metrics"
                               "storage" "queue" "email" "cdn" "proxy" "scheduler"
                               "worker" "gateway" "monitor" "backup" "search" "notify"
                               "billing" "audit")
                local keys=("host" "port" "timeout" "retries" "enabled")
                local vals=("localhost" "8080" "30" "3" "true")
                for s in "${sections[@]}"; do
                    echo "${s}:"
                    for i in $(seq 0 4); do
                        echo "  ${keys[$i]}: ${vals[$i]}"
                    done
                done
            } > "$goal_file"
            ;;
        *)
            return 1
            ;;
    esac

    echo "$par|$hint1|$hint2|$desc"
}

count_keystrokes() {
    local script_file="/tmp/vimgolf_keys_$$"
    local input_file="$1"
    local output_file="/tmp/vimgolf_output_$$"

    cp "$input_file" "$output_file"

    vim -u NONE -N -i NONE -W "$script_file" "$output_file" </dev/tty >/dev/tty 2>/dev/null

    local keystrokes=0
    if [ -f "$script_file" ]; then
        # Count real keystrokes from the scriptout. Two things need care:
        #   1. Commands that wait for a literal char argument (f t F T r `) make
        #      vim write a 3-byte internal artifact 0x80 0xfd 0xNN into the log
        #      that is NOT a keystroke the user typed. With a replayed macro this
        #      artifact is emitted on every replay and badly inflates the count.
        #   2. Genuine special keys (arrows, etc.) are written as 0x80 + 2 bytes
        #      and should count as a single keystroke.
        #   3. The trailing save command (:wq, :q!, :x, :w, ZZ) is not counted.
        keystrokes=$(perl -e '
            local $/;
            open(my $fh, "<:raw", $ARGV[0]) or do { print 0; exit };
            my $d = <$fh>;
            close $fh;

            # Drop the char-argument artifacts left by f/t/F/T/r/`
            $d =~ s/\x80\xfd.//gs;

            # Strip the trailing save command
            $d =~ s/(?::wq|:q!|:x|:w)[\r\n]\z// or $d =~ s/ZZ\z//;

            # Count: a 0x80-prefixed special key (3 bytes) is one keystroke;
            # every other byte is one keystroke.
            my @b = unpack("C*", $d);
            my $n = 0;
            for (my $i = 0; $i < @b; $i++) {
                if ($b[$i] == 0x80 && $i + 2 < @b) { $i += 2; }
                $n++;
            }
            print $n;
        ' "$script_file")
        [ -z "$keystrokes" ] && keystrokes=0
    fi

    rm -f "$script_file"
    echo "$keystrokes|$output_file"
}

# Render a single line with whitespace made visible (spaces -> ·) and pad it
# to `width` display columns. Padding is added manually from the raw character
# count so it stays correct even though · is a multibyte glyph.
fmt_line() {
    local raw="$1" width="$2"
    local len=${#raw}
    local vis=${raw// /·}
    local pad=$((width - len))
    [ "$pad" -lt 0 ] && pad=0
    printf '%s%*s' "$vis" "$pad" ""
}

# Print lines from stdin with a 4-space display indent, whitespace made
# visible, and an optional color applied to the content.
print_vis() {
    local color="$1"
    while IFS= read -r line; do
        printf "    %b%s%b\n" "$color" "${line// /·}" "$NC"
    done
}

play_level() {
    local level=$1
    local mode=${2:-normal}  # "normal", "hard", or "tutorial"
    local level_info

    if [ "$mode" = "hard" ]; then
        level_info=$(setup_hard_level "$level") || { echo "Invalid level"; return 1; }
    else
        level_info=$(setup_level "$level" "$mode") || { echo "Invalid level"; return 1; }
    fi

    local par=$(echo "$level_info" | cut -d'|' -f1)
    local hint1=$(echo "$level_info" | cut -d'|' -f2)
    local hint2=$(echo "$level_info" | cut -d'|' -f3)
    local desc=$(echo "$level_info" | cut -d'|' -f4)
    # File paths must match what setup_level / setup_hard_level wrote.
    local start_file goal_file
    if [ "$mode" = "hard" ]; then
        start_file="$LEVEL_DIR/hard_start_${level}.txt"
        goal_file="$LEVEL_DIR/hard_goal_${level}.txt"
    else
        start_file="$LEVEL_DIR/${mode}_start_${level}.txt"
        goal_file="$LEVEL_DIR/${mode}_goal_${level}.txt"
    fi
    local hint_level=0
    local mode_label=""
    [ "$mode" = "hard" ] && mode_label="${RED}[HARD] ${NC}"
    [ "$mode" = "tutorial" ] && mode_label="${CYAN}[TUTORIAL] ${NC}"
    [ "$mode" = "expert" ] && mode_label="${RED}${BOLD}[EXPERT] ${NC}"

    while true; do
        clear
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  ${mode_label}Level $level: ${desc}${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}  Par: $par keystrokes${NC}"
        echo ""

        # Show START and GOAL side by side only if the terminal is wide enough
        # AND the lines are short enough to fit in columns without wrapping.
        # Long lines (e.g. level 15) fall back to a stacked layout instead.
        local cols=$(tput cols 2>/dev/null || echo 80)
        local start_lines goal_lines max_lines max_len
        start_lines=$(wc -l < "$start_file")
        goal_lines=$(wc -l < "$goal_file")
        max_lines=$((start_lines > goal_lines ? start_lines : goal_lines))
        max_len=$(awk '{ if (length > m) m = length } END { print m + 0 }' "$start_file" "$goal_file")
        local show_max=15  # truncate display for large files

        # Column width adapts to the content; side-by-side is only used when
        # two such columns actually fit within the terminal width.
        local col_width=$max_len
        [ "$col_width" -lt 20 ] && col_width=20

        if [ "$cols" -ge 70 ] && [ $((2 * col_width + 6)) -le "$cols" ]; then
            local dashes
            dashes=$(printf '%*s' "$col_width" '' | tr ' ' '─')
            printf "  ${DIM}%-${col_width}s  %-${col_width}s${NC}\n" "START (${start_lines} lines):" "GOAL (${goal_lines} lines):"
            printf "  ${DIM}%s  %s${NC}\n" "$dashes" "$dashes"

            if [ $max_lines -le $show_max ]; then
                for i in $(seq 1 $max_lines); do
                    local sline gline
                    sline=$(sed -n "${i}p" "$start_file")
                    gline=$(sed -n "${i}p" "$goal_file")
                    printf "  %s  ${GREEN}%s${NC}\n" "$(fmt_line "$sline" "$col_width")" "$(fmt_line "$gline" "$col_width")"
                done
            else
                # Show first 5 and last 5. Each column is truncated relative to
                # its OWN length so neither the start nor the goal ending (e.g.
                # the closing } of a JSON goal) ever gets cut off, even when the
                # two files differ in line count.
                for i in $(seq 1 5); do
                    local sline gline
                    sline=$(sed -n "${i}p" "$start_file")
                    gline=$(sed -n "${i}p" "$goal_file")
                    printf "  %s  ${GREEN}%s${NC}\n" "$(fmt_line "$sline" "$col_width")" "$(fmt_line "$gline" "$col_width")"
                done
                printf "  ${DIM}%-${col_width}s  %-${col_width}s${NC}\n" "  ... ($((start_lines - 10)) more)" "  ... ($((goal_lines - 10)) more)"
                local k
                for k in 0 1 2 3 4; do
                    local sline gline
                    sline=$(sed -n "$((start_lines - 4 + k))p" "$start_file")
                    gline=$(sed -n "$((goal_lines - 4 + k))p" "$goal_file" 2>/dev/null)
                    printf "  %s  ${GREEN}%s${NC}\n" "$(fmt_line "$sline" "$col_width")" "$(fmt_line "$gline" "$col_width")"
                done
            fi
        else
            echo -e "${DIM}  START (${start_lines} lines):${NC}"
            echo -e "${DIM}  ─────${NC}"
            if [ $start_lines -le $show_max ]; then
                print_vis "" < "$start_file"
            else
                head -5 "$start_file" | print_vis ""
                echo -e "    ${DIM}... ($((start_lines - 10)) more lines)${NC}"
                tail -5 "$start_file" | print_vis ""
            fi
            echo ""
            echo -e "${DIM}  GOAL (${goal_lines} lines):${NC}"
            echo -e "${DIM}  ─────${NC}"
            if [ $goal_lines -le $show_max ]; then
                print_vis "$GREEN" < "$goal_file"
            else
                head -5 "$goal_file" | print_vis "$GREEN"
                echo -e "    ${DIM}... ($((goal_lines - 10)) more lines)${NC}"
                tail -5 "$goal_file" | print_vis "$GREEN"
            fi
        fi

        echo ""
        echo -e "  ${DIM}( · = a space )${NC}"
        echo ""
        if [ $hint_level -ge 1 ]; then
            echo -e "  ${YELLOW}Hint 1: ${hint1}${NC}"
        fi
        if [ $hint_level -ge 2 ]; then
            echo -e "  ${YELLOW}Hint 2: ${hint2}${NC}"
        fi
        echo ""
        echo -e "  ${BOLD}[Enter]${NC} Play  ${BOLD}[h]${NC} Hint  ${BOLD}[s]${NC} Skip  ${BOLD}[q]${NC} Quit"
        echo ""

        local choice
        read -rsn1 choice
        case "$choice" in
            "") ;;  # proceed to play
            s|S) return 2 ;;
            q|Q) return 1 ;;
            h|H)
                if [ $hint_level -lt 2 ]; then
                    hint_level=$((hint_level + 1))
                fi
                continue
                ;;
            *) continue ;;
        esac

        echo -e "  ${DIM}Vim will open. Transform START → GOAL, then :wq${NC}"
        echo -e "  ${DIM}Press Enter to launch vim...${NC}"
        read -rsn1

        local result
        result=$(count_keystrokes "$start_file")
        local keystrokes=$(echo "$result" | cut -d'|' -f1)
        local output_file=$(echo "$result" | cut -d'|' -f2)

        echo ""
        if diff -q "$output_file" "$goal_file" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ CORRECT!${NC}"
            echo ""

            if [ "$keystrokes" -le "$par" ]; then
                if [ "$keystrokes" -lt "$par" ]; then
                    echo -e "  ${GREEN}${BOLD}★ EAGLE! ${keystrokes} keystrokes (par: ${par})${NC}"
                else
                    echo -e "  ${GREEN}${BOLD}● PAR! ${keystrokes} keystrokes${NC}"
                fi
            else
                local over=$((keystrokes - par))
                echo -e "  ${YELLOW}○ +${over} over par (${keystrokes}/${par} keystrokes)${NC}"
            fi

            local score_prefix="level"
            [ "$mode" = "hard" ] && score_prefix="hard"
            [ "$mode" = "tutorial" ] && score_prefix="tut"
            [ "$mode" = "expert" ] && score_prefix="exp"
            echo "${score_prefix}${level}:${keystrokes}:${par}" >> "$SCORE_FILE"
            echo ""
            echo -e "  ${BOLD}[Enter]${NC} Next level  ${BOLD}[r]${NC} Retry  ${BOLD}[m]${NC} Menu  ${BOLD}[q]${NC} Quit"
            local post_choice=""
            while true; do
                read -rsn1 post_choice
                case "$post_choice" in
                    r|R|q|Q|m|M) break ;;
                    "") break ;;
                    *) ;;
                esac
            done
            rm -f "$output_file"
            case "$post_choice" in
                r|R) continue ;;
                q|Q) return 1 ;;
                m|M) return 3 ;;
                "") return 0 ;;
            esac
        else
            echo -e "  ${RED}✗ Output doesn't match goal${NC}"
            echo ""
            echo -e "  ${DIM}Your output:${NC}"
            print_vis "" < "$output_file"
            echo ""
            echo -e "  ${DIM}Diff (< yours, > expected):${NC}"
            diff "$output_file" "$goal_file" 2>/dev/null | sed 's/^/    /' || true
            echo ""
            echo -e "  ${BOLD}[r]${NC} Retry  ${BOLD}[s]${NC} Skip  ${BOLD}[m]${NC} Menu  ${BOLD}[q]${NC} Quit"
            read -rsn1 choice
            case "$choice" in
                s|S) rm -f "$output_file"; return 2 ;;
                q|Q) rm -f "$output_file"; return 1 ;;
                m|M) rm -f "$output_file"; return 3 ;;
                *) rm -f "$output_file"; continue ;;
            esac
        fi
    done
}

show_scores() {
    clear
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SCOREBOARD${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCORE_FILE" ]; then
        echo -e "  ${DIM}No scores yet. Play some levels!${NC}"
    else
        local total_strokes=0
        local total_par=0
        local levels_completed=0
        local hard_strokes=0
        local hard_par=0
        local hard_completed=0

        echo -e "  ${DIM}Level  Strokes  Par   Score    Hard   Par   Score${NC}"
        echo -e "  ${DIM}─────  ───────  ───   ─────    ────   ───   ─────${NC}"

        for i in $(seq 1 "$TOTAL_LEVELS"); do
            local best=$(grep "^level${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
            local hbest=""
            if [ "$i" -le "$TOTAL_HARD_LEVELS" ]; then
                hbest=$(grep "^hard${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
            fi

            local normal_col=""
            if [ -n "$best" ]; then
                local lpar=$(grep "^level${i}:" "$SCORE_FILE" | cut -d: -f3 | head -1)
                local diff=$((best - lpar))
                local score_str=""
                if [ $diff -lt 0 ]; then
                    score_str="${GREEN}${diff}${NC}"
                elif [ $diff -eq 0 ]; then
                    score_str="${CYAN}PAR${NC}"
                else
                    score_str="${YELLOW}+${diff}${NC}"
                fi
                normal_col=$(printf "%-8s %-5s %b" "$best" "$lpar" "$score_str")
                total_strokes=$((total_strokes + best))
                total_par=$((total_par + lpar))
                levels_completed=$((levels_completed + 1))
            else
                normal_col=$(printf "%-8s %-5s %s" "-" "-" " ")
            fi

            local hard_col=""
            if [ -n "$hbest" ]; then
                local hpar=$(grep "^hard${i}:" "$SCORE_FILE" | cut -d: -f3 | head -1)
                local hdiff=$((hbest - hpar))
                local hscore_str=""
                if [ $hdiff -lt 0 ]; then
                    hscore_str="${GREEN}${hdiff}${NC}"
                elif [ $hdiff -eq 0 ]; then
                    hscore_str="${CYAN}PAR${NC}"
                else
                    hscore_str="${YELLOW}+${hdiff}${NC}"
                fi
                hard_col=$(printf "%-6s %-5s %b" "$hbest" "$hpar" "$hscore_str")
                hard_strokes=$((hard_strokes + hbest))
                hard_par=$((hard_par + hpar))
                hard_completed=$((hard_completed + 1))
            elif [ "$i" -le "$TOTAL_HARD_LEVELS" ]; then
                hard_col=$(printf "%-6s %-5s %s" "-" "-" " ")
            else
                hard_col=""  # no hard variant for levels beyond the original set
            fi

            printf "  %-6s %b    %b\n" "$i" "$normal_col" "$hard_col"
        done

        # Tutorial and Expert progress are summarized rather than shown per-row.
        local tut_completed=0 exp_completed=0 t
        for t in $(seq 1 "$TOTAL_TUTORIAL_LEVELS"); do
            grep -q "^tut${t}:" "$SCORE_FILE" && tut_completed=$((tut_completed + 1))
        done
        for t in $(seq 1 "$TOTAL_EXPERT_LEVELS"); do
            grep -q "^exp${t}:" "$SCORE_FILE" && exp_completed=$((exp_completed + 1))
        done

        echo ""
        echo -e "  ${DIM}─────────────────────────────────────────────${NC}"
        printf "  ${DIM}Tutorial: %d/%d completed${NC}\n" "$tut_completed" "$TOTAL_TUTORIAL_LEVELS"
        printf "  ${DIM}Normal:   %d/%d completed${NC}\n" "$levels_completed" "$TOTAL_LEVELS"
        printf "  ${DIM}Hard:     %d/%d completed${NC}\n" "$hard_completed" "$TOTAL_HARD_LEVELS"
        printf "  ${DIM}Expert:   %d/%d completed${NC}\n" "$exp_completed" "$TOTAL_EXPERT_LEVELS"
    fi

    echo ""
    echo -e "  ${DIM}Press any key to return...${NC}"
    read -rsn1
}

# Print the solution key for one track. Reads solution + note lines straight
# from each data file so the key never drifts out of sync with the levels.
# Args: <data_dir> <count> <section_title>
# Returns 1 if the viewer asked to stop paging.
show_key_track() {
    local data_dir=$1 count=$2 title=$3
    echo -e "  ${BOLD}${title}${NC}"
    echo -e "  ${DIM}Lvl  Par  Solution${NC}"
    echo -e "  ${DIM}───  ───  ────────${NC}"

    local i
    for i in $(seq 1 "$count"); do
        local data_file
        data_file=$(printf '%s/%02d.level' "$data_dir" "$i")
        [ -f "$data_file" ] || continue

        local par sol
        par=$(awk -F': ' '/^par: /{print $2; exit}' "$data_file")
        sol=$(awk '/^solution: /{sub(/^solution: /,""); print; exit}' "$data_file")

        if [ -z "$sol" ]; then
            # Expert levels intentionally ship without a solution — figure it out.
            printf "  %2d  %3s  ${DIM}(hidden — no solution provided)${NC}\n\n" "$i" "$par"
            continue
        fi

        printf "  %2d  %3s  ${YELLOW}%s${NC}\n" "$i" "$par" "$sol"
        awk '/^note: /{sub(/^note: /,""); print}' "$data_file" | while IFS= read -r n; do
            echo -e "         ${DIM}${n}${NC}"
        done
        echo ""

        # Page every 6 levels so the list stays readable.
        if [ $((i % 6)) -eq 0 ] && [ "$i" -lt "$count" ]; then
            echo -e "  ${DIM}-- more (${i}/${count}) — press any key, or q to stop --${NC}"
            local k; read -rsn1 k
            { [ "$k" = "q" ] || [ "$k" = "Q" ]; } && return 1
            clear
            echo -e "  ${BOLD}${title}${NC}"
            echo -e "  ${DIM}Lvl  Par  Solution${NC}"
            echo -e "  ${DIM}───  ───  ────────${NC}"
        fi
    done
    return 0
}

show_key() {
    clear
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SOLUTION KEY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""

    local k
    if show_key_track "$TUTORIAL_DATA_DIR" "$TOTAL_TUTORIAL_LEVELS" "TUTORIAL"; then
        echo -e "  ${DIM}-- press any key for the Normal track, or q to stop --${NC}"
        read -rsn1 k
        if [ "$k" != "q" ] && [ "$k" != "Q" ]; then
            clear
            if show_key_track "$LEVELS_DATA_DIR" "$TOTAL_LEVELS" "NORMAL" \
               && [ "$TOTAL_EXPERT_LEVELS" -gt 0 ]; then
                echo -e "  ${DIM}-- press any key for the Expert track, or q to stop --${NC}"
                read -rsn1 k
                if [ "$k" != "q" ] && [ "$k" != "Q" ]; then
                    clear
                    show_key_track "$EXPERT_DATA_DIR" "$TOTAL_EXPERT_LEVELS" "EXPERT (solutions hidden)"
                fi
            fi
        fi
    fi

    echo -e "  ${DIM}Notation: <CR>=Enter, <C-A>=Ctrl-A, <C-V>=Ctrl-V, <Esc>=Escape${NC}"
    echo -e "  ${DIM}These are PAR solutions — shorter solutions may exist!${NC}"
    echo ""
    echo -e "  ${DIM}Press any key to return...${NC}"
    read -rsn1
}

level_select() {
    local select_mode=${1:-normal}

    # Per-mode display title, level count, and score-file prefix.
    local title max_level score_prefix
    case "$select_mode" in
        hard)     title="${RED}HARD MODE — SELECT LEVEL${NC}";       max_level=$TOTAL_HARD_LEVELS;     score_prefix="hard" ;;
        tutorial) title="${CYAN}TUTORIAL — SELECT LEVEL${NC}";        max_level=$TOTAL_TUTORIAL_LEVELS; score_prefix="tut" ;;
        expert)   title="${RED}${BOLD}EXPERT — SELECT LEVEL${NC}";     max_level=$TOTAL_EXPERT_LEVELS;   score_prefix="exp" ;;
        *)        title="${CYAN}SELECT LEVEL${NC}";                   max_level=$TOTAL_LEVELS;          score_prefix="level" ;;
    esac

    clear
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    echo -e "  $title"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    echo ""

    for i in $(seq 1 "$max_level"); do
        local info
        if [ "$select_mode" = "hard" ]; then
            info=$(setup_hard_level "$i" 2>/dev/null)
        else
            info=$(setup_level "$i" "$select_mode" 2>/dev/null)
        fi
        local par=$(echo "$info" | cut -d'|' -f1)
        local desc=$(echo "$info" | cut -d'|' -f4)

        local status=" "
        local locked=""
        local best=""
        local score_str=""
        if [ "$select_mode" = "hard" ] && ! is_level_completed "$i"; then
            # Hard levels unlock only after the matching normal level is done.
            locked="${DIM}[LOCKED]${NC}"
        elif [ -f "$SCORE_FILE" ]; then
            best=$(grep "^${score_prefix}${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
        fi

        if [ -n "$best" ]; then
            local diff=$((best - par))
            if [ "$diff" -lt 0 ]; then
                status="${GREEN}*${NC}"
                score_str="${GREEN}${best}/${par} (${diff})${NC}"
            elif [ "$diff" -eq 0 ]; then
                status="${GREEN}*${NC}"
                score_str="${CYAN}${best}/${par} (PAR)${NC}"
            else
                status="${YELLOW}o${NC}"
                score_str="${YELLOW}${best}/${par} (+${diff})${NC}"
            fi
        fi

        if [ -n "$locked" ]; then
            printf "  %b %2d. ${DIM}%-40s${NC} %b\n" "$status" "$i" "$desc" "$locked"
        elif [ -n "$score_str" ]; then
            printf "  %b %2d. %-40s ${DIM}best:${NC} %b\n" "$status" "$i" "$desc" "$score_str"
        else
            printf "  %b %2d. %-40s ${DIM}(par %d)${NC}\n" "$status" "$i" "$desc" "$par"
        fi
    done

    echo ""
    echo -e "  ${DIM}Enter level number (1-${max_level}) or [q] to go back:${NC} "
    read -r choice

    case "$choice" in
        q|Q) return ;;
        ''|*[!0-9]*) echo "Invalid choice"; sleep 1; return ;;
    esac
    if [ "$choice" -lt 1 ] || [ "$choice" -gt "$max_level" ]; then
        echo "Invalid choice"; sleep 1; return
    fi

    if [ "$select_mode" = "hard" ] && ! is_level_completed "$choice"; then
        echo -e "  ${RED}Complete normal level $choice first to unlock!${NC}"
        sleep 2
        return
    fi
    local lvl=$choice
    while [ "$lvl" -le "$max_level" ]; do
        if [ "$select_mode" = "hard" ] && ! is_level_completed "$lvl"; then
            echo -e "  ${RED}Level $lvl locked — complete normal mode first${NC}"
            sleep 2
            return
        fi
        play_level "$lvl" "$select_mode"
        local ret=$?
        case $ret in
            0) lvl=$((lvl + 1)) ;;  # next level
            1) return ;;            # quit
            2) lvl=$((lvl + 1)) ;;  # skip
            3) return ;;            # back to menu
        esac
    done
}

main_menu() {
    while true; do
        clear
        print_banner
        echo -e "  ${BOLD}[t]${NC} ${CYAN}Tutorial${NC}             ${BOLD}[p]${NC} Play (sequential)"
        echo -e "  ${BOLD}[l]${NC} Level select         ${BOLD}[h]${NC} ${RED}Hard mode${NC}"
        echo -e "  ${BOLD}[e]${NC} ${RED}${BOLD}Expert${NC}               ${BOLD}[s]${NC} Scoreboard"
        echo -e "  ${BOLD}[k]${NC} Solution key         ${BOLD}[r]${NC} Reset scores"
        echo -e "  ${BOLD}[q]${NC} Quit"
        echo ""
        echo -e "  ${DIM}Rules: Transform START into GOAL using vim.${NC}"
        echo -e "  ${DIM}Your keystrokes are counted. Beat par to earn *${NC}"
        echo -e "  ${DIM}Tutorial: learn vim basics — motions, text objects, macros.${NC}"
        echo -e "  ${DIM}Hard mode: same concept at 50-100x scale. Unlocked per level.${NC}"
        echo -e "  ${DIM}Expert: brutal multi-stage challenges — no solution key.${NC}"
        echo ""

        read -rsn1 choice
        case "$choice" in
            t|T)
                for i in $(seq 1 "$TOTAL_TUTORIAL_LEVELS"); do
                    play_level "$i" tutorial
                    local ret=$?
                    [ $ret -eq 1 ] && break
                    [ $ret -eq 3 ] && break
                done
                ;;
            e|E) level_select expert ;;
            p|P)
                for i in $(seq 1 "$TOTAL_LEVELS"); do
                    play_level "$i" normal
                    local ret=$?
                    [ $ret -eq 1 ] && break
                    [ $ret -eq 3 ] && break
                done
                ;;
            l|L) level_select normal ;;
            h|H) level_select hard ;;
            s|S) show_scores ;;
            k|K) show_key ;;
            r|R)
                rm -f "$SCORE_FILE"
                echo -e "  ${GREEN}Scores reset!${NC}"
                sleep 1
                ;;
            q|Q) clear; echo "Thanks for playing!"; exit 0 ;;
        esac
    done
}

main_menu
