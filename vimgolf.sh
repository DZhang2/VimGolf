#!/bin/bash

# Vim Golf - Terminal Edition
# Solve editing challenges in as few keystrokes as possible!


SCORE_FILE="/tmp/vimgolf_scores"
LEVEL_DIR="/tmp/vimgolf_levels"
mkdir -p "$LEVEL_DIR"

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

setup_level() {
    local level=$1
    local start_file="$LEVEL_DIR/start_${level}.txt"
    local goal_file="$LEVEL_DIR/goal_${level}.txt"
    local par=""
    local hint=""
    local desc=""

    case $level in
        1)
            desc="Delete the middle line"
            par=3
            hint1="Think: go to line, delete it"
            hint2="j moves down, dd deletes a whole line"
            cat > "$start_file" << 'EOF'
hello
delete this line
world
EOF
            cat > "$goal_file" << 'EOF'
hello
world
EOF
            ;;
        2)
            desc="Change 'foo' to 'bar' on every line"
            par=12
            hint1="Global substitution is your friend"
            hint2=":%s — no g flag needed when there's one match per line"
            cat > "$start_file" << 'EOF'
the foo is here
foo again
one more foo
EOF
            cat > "$goal_file" << 'EOF'
the bar is here
bar again
one more bar
EOF
            ;;
        3)
            desc="Reverse the order of these lines"
            par=8
            hint1="Think about move commands"
            hint2=":global can execute a move on every line — what happens if you move each to line 0?"
            cat > "$start_file" << 'EOF'
first
second
third
fourth
fifth
EOF
            cat > "$goal_file" << 'EOF'
fifth
fourth
third
second
first
EOF
            ;;
        4)
            desc="Surround each word with quotes"
            par=11
            hint1="Macros or substitution?"
            hint2="In :s replacement, & refers to the entire match — .* grabs the whole line"
            cat > "$start_file" << 'EOF'
apple
banana
cherry
date
elderberry
EOF
            cat > "$goal_file" << 'EOF'
"apple"
"banana"
"cherry"
"date"
"elderberry"
EOF
            ;;
        5)
            desc="Convert camelCase to snake_case"
            par=16
            hint1="Substitution with regex"
            hint2="\\u matches uppercase in a pattern, \\l lowercases in replacement"
            cat > "$start_file" << 'EOF'
camelCase
getUserName
processItem
doStuff
valueOf
EOF
            cat > "$goal_file" << 'EOF'
camel_case
get_user_name
process_item
do_stuff
value_of
EOF
            ;;
        6)
            desc="Sort lines and remove duplicates"
            par=7
            hint1="Ex commands can sort"
            hint2=":sort has a flag that removes duplicates in one shot"
            cat > "$start_file" << 'EOF'
cherry
apple
banana
apple
date
cherry
banana
EOF
            cat > "$goal_file" << 'EOF'
apple
banana
cherry
date
EOF
            ;;
        7)
            desc="Increment all numbers by 1"
            par=10
            hint1="Ctrl-A increments numbers in normal mode"
            hint2="Record a macro: Ctrl-A finds the next number on the line and increments it"
            cat > "$start_file" << 'EOF'
item 1: value 10
item 2: value 20
item 3: value 30
item 4: value 40
item 5: value 50
EOF
            cat > "$goal_file" << 'EOF'
item 2: value 11
item 3: value 21
item 4: value 31
item 5: value 41
item 6: value 51
EOF
            ;;
        8)
            desc="Convert this CSV to a markdown table"
            par=30
            hint1="Substitution + manual header separator"
            hint2="Replace commas with ' | ', add leading/trailing pipes, then type the --- row"
            cat > "$start_file" << 'EOF'
name,age,city
Alice,30,NYC
Bob,25,LA
Carol,35,SF
EOF
            cat > "$goal_file" << 'EOF'
| name | age | city |
|------|-----|------|
| Alice | 30 | NYC |
| Bob | 25 | LA |
| Carol | 35 | SF |
EOF
            ;;
        9)
            desc="Align the equals signs"
            par=20
            hint1="Think column-wise or dot command"
            hint2="f finds =, insert a space before it, then . repeats — skip already-aligned lines"
            cat > "$start_file" << 'EOF'
x = 1
foo = 2
hello = 3
ab = 4
world = 5
EOF
            cat > "$goal_file" << 'EOF'
x     = 1
foo   = 2
hello = 3
ab    = 4
world = 5
EOF
            ;;
        10)
            desc="Extract function names into a list"
            par=20
            hint1="Global command + delete what you don't need"
            hint2=":v (inverse global) deletes non-matching lines; :%norm applies keys to every line"
            cat > "$start_file" << 'EOF'
def initialize(config):
    pass

def process_data(input, output):
    pass

def validate(schema):
    pass

def cleanup():
    pass
EOF
            cat > "$goal_file" << 'EOF'
initialize
process_data
validate
cleanup
EOF
            ;;
        11)
            desc="Swap the two columns"
            par=27
            hint1="Filter through an external command"
            hint2=":%! pipes the buffer through a shell command — awk can reorder fields"
            cat > "$start_file" << 'EOF'
Alice   100
Bob     200
Carol   300
Dave    400
Eve     500
EOF
            cat > "$goal_file" << 'EOF'
100   Alice
200   Bob
300   Carol
400   Dave
500   Eve
EOF
            ;;
        12)
            desc="Remove blank lines"
            par=7
            hint1="Two substitutions or one clever command"
            hint2=":v matches lines that DON'T contain a pattern — delete those lines"
            cat > "$start_file" << 'EOF'
hello

world

foo

bar
EOF
            cat > "$goal_file" << 'EOF'
hello
world
foo
bar
EOF
            ;;
        13)
            desc="Convert flat list to JSON array"
            par=24
            hint1="Macros + manual structure"
            hint2="Substitution wraps all lines with indent+quotes+comma, then fix first/last manually"
            cat > "$start_file" << 'EOF'
red
green
blue
yellow
purple
EOF
            cat > "$goal_file" << 'EOF'
[
  "red",
  "green",
  "blue",
  "yellow",
  "purple"
]
EOF
            ;;
        14)
            desc="Number each line (1. 2. 3. etc)"
            par=16
            hint1="A put command with expression, or a macro"
            hint2="g Ctrl-A in visual block mode creates sequential numbers starting from a base"
            cat > "$start_file" << 'EOF'
apple
banana
cherry
date
elderberry
fig
grape
EOF
            cat > "$goal_file" << 'EOF'
1. apple
2. banana
3. cherry
4. date
5. elderberry
6. fig
7. grape
EOF
            ;;
        15)
            desc="The Final Boss: flatten to valid YAML"
            par=25
            hint1="Everything you've learned — substitution, macros, structure"
            hint2="Replace delimiters ({ and ,) with \\r+indent using \\|, then strip closing braces"
            cat > "$start_file" << 'EOF'
server: {host: localhost, port: 8080, debug: true}
database: {host: db.local, port: 5432, name: myapp}
cache: {host: redis.local, port: 6379, ttl: 300}
EOF
            cat > "$goal_file" << 'EOF'
server:
  host: localhost
  port: 8080
  debug: true
database:
  host: db.local
  port: 5432
  name: myapp
cache:
  host: redis.local
  port: 6379
  ttl: 300
EOF
            ;;
        *)
            return 1
            ;;
    esac

    echo "$par|$hint1|$hint2|$desc"
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

play_level() {
    local level=$1
    local mode=${2:-normal}  # "normal" or "hard"
    local level_info

    if [ "$mode" = "hard" ]; then
        level_info=$(setup_hard_level "$level") || { echo "Invalid level"; return 1; }
    else
        level_info=$(setup_level "$level") || { echo "Invalid level"; return 1; }
    fi

    local par=$(echo "$level_info" | cut -d'|' -f1)
    local hint1=$(echo "$level_info" | cut -d'|' -f2)
    local hint2=$(echo "$level_info" | cut -d'|' -f3)
    local desc=$(echo "$level_info" | cut -d'|' -f4)
    local prefix="start"
    [ "$mode" = "hard" ] && prefix="hard_start"
    local start_file="$LEVEL_DIR/${prefix}_${level}.txt"
    local goal_prefix="goal"
    [ "$mode" = "hard" ] && goal_prefix="hard_goal"
    local goal_file="$LEVEL_DIR/${goal_prefix}_${level}.txt"
    local hint_level=0
    local mode_label=""
    [ "$mode" = "hard" ] && mode_label="${RED}[HARD] ${NC}"

    while true; do
        clear
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  ${mode_label}Level $level: ${desc}${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}  Par: $par keystrokes${NC}"
        echo ""

        # Show START and GOAL side by side if terminal is wide enough
        local cols=$(tput cols 2>/dev/null || echo 80)
        local start_lines goal_lines max_lines
        start_lines=$(wc -l < "$start_file")
        goal_lines=$(wc -l < "$goal_file")
        max_lines=$((start_lines > goal_lines ? start_lines : goal_lines))
        local show_max=15  # truncate display for large files

        if [ "$cols" -ge 70 ]; then
            printf "  ${DIM}%-30s  %-30s${NC}\n" "START (${start_lines} lines):" "GOAL (${goal_lines} lines):"
            printf "  ${DIM}%-30s  %-30s${NC}\n" "─────────────────────────────" "─────────────────────────────"

            if [ $max_lines -le $show_max ]; then
                for i in $(seq 1 $max_lines); do
                    local sline gline
                    sline=$(sed -n "${i}p" "$start_file")
                    gline=$(sed -n "${i}p" "$goal_file")
                    printf "  %-30s  ${GREEN}%-30s${NC}\n" "$sline" "$gline"
                done
            else
                # Show first 5 and last 5
                for i in $(seq 1 5); do
                    local sline gline
                    sline=$(sed -n "${i}p" "$start_file")
                    gline=$(sed -n "${i}p" "$goal_file")
                    printf "  %-30s  ${GREEN}%-30s${NC}\n" "$sline" "$gline"
                done
                printf "  ${DIM}%-30s  %-30s${NC}\n" "  ... ($((start_lines - 10)) more)" "  ... ($((goal_lines - 10)) more)"
                for i in $(seq $((start_lines - 4)) $start_lines); do
                    local sline gline
                    sline=$(sed -n "${i}p" "$start_file")
                    gline=$(sed -n "${i}p" "$goal_file" 2>/dev/null)
                    printf "  %-30s  ${GREEN}%-30s${NC}\n" "$sline" "$gline"
                done
            fi
        else
            echo -e "${DIM}  START (${start_lines} lines):${NC}"
            echo -e "${DIM}  ─────${NC}"
            if [ $start_lines -le $show_max ]; then
                sed 's/^/    /' "$start_file"
            else
                head -5 "$start_file" | sed 's/^/    /'
                echo -e "    ${DIM}... ($((start_lines - 10)) more lines)${NC}"
                tail -5 "$start_file" | sed 's/^/    /'
            fi
            echo ""
            echo -e "${DIM}  GOAL (${goal_lines} lines):${NC}"
            echo -e "${DIM}  ─────${NC}"
            if [ $goal_lines -le $show_max ]; then
                sed 's/^/    /' "$goal_file" | while IFS= read -r line; do echo -e "  ${GREEN}${line}${NC}"; done
            else
                head -5 "$goal_file" | sed 's/^/    /' | while IFS= read -r line; do echo -e "  ${GREEN}${line}${NC}"; done
                echo -e "    ${DIM}... ($((goal_lines - 10)) more lines)${NC}"
                tail -5 "$goal_file" | sed 's/^/    /' | while IFS= read -r line; do echo -e "  ${GREEN}${line}${NC}"; done
            fi
        fi

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
            sed 's/^/    /' "$output_file"
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

        for i in $(seq 1 15); do
            local best=$(grep "^level${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
            local hbest=$(grep "^hard${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)

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
            else
                hard_col=$(printf "%-6s %-5s %s" "-" "-" " ")
            fi

            printf "  %-6s %b    %b\n" "$i" "$normal_col" "$hard_col"
        done

        echo ""
        echo -e "  ${DIM}─────────────────────────────────────────────${NC}"
        printf "  ${DIM}Normal: %d/15 completed${NC}\n" "$levels_completed"
        printf "  ${DIM}Hard:   %d/15 completed${NC}\n" "$hard_completed"
    fi

    echo ""
    echo -e "  ${DIM}Press any key to return...${NC}"
    read -rsn1
}

show_key() {
    clear
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SOLUTION KEY${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${DIM}Lvl  Par  Solution${NC}"
    echo -e "  ${DIM}───  ───  ────────${NC}"

    echo -e "   1    3  ${YELLOW}jdd${NC}"
    echo -e "         ${DIM}j moves down one line to the target; dd deletes that whole line.${NC}"
    echo ""
    echo -e "   2   12  ${YELLOW}:%s/foo/bar<CR>${NC}"
    echo -e "         ${DIM}:%s substitutes on every line (%); swaps the first 'foo' per line for 'bar'.${NC}"
    echo ""
    echo -e "   3    8  ${YELLOW}:g/^/m0<CR>${NC}"
    echo -e "         ${DIM}:g/^/ runs on every line; m0 moves each to the top, reversing the order.${NC}"
    echo ""
    echo -e "   4   11  ${YELLOW}:%s/.*/\"&\"<CR>${NC}"
    echo -e "         ${DIM}.* matches the whole line; & in the replacement re-inserts it, wrapped in quotes.${NC}"
    echo ""
    echo -e "   5   16  ${YELLOW}:%s/\\\\u/_\\\\l&/g<CR>${NC}"
    echo -e "         ${DIM}\\u matches an uppercase letter; replace with _ plus its lowercase (\\l&). g = all per line.${NC}"
    echo ""
    echo -e "   6    7  ${YELLOW}:sor u<CR>${NC}"
    echo -e "         ${DIM}:sort with the u flag sorts all lines and drops duplicates in one pass.${NC}"
    echo ""
    echo -e "   7   10  ${YELLOW}qa<C-A>l<C-A>+q4@a${NC}"
    echo -e "         ${DIM}Record macro a: <C-A> increments a number, l steps onto the next, <C-A> again,${NC}"
    echo -e "         ${DIM}+ drops to the next line; q ends it. 4@a replays it on the remaining 4 lines.${NC}"
    echo ""
    echo -e "   8   30  ${YELLOW}:%s/,/ | /g<CR> :%s/^/| <CR> :%s/\$/ |<CR> + manual sep${NC}"
    echo -e "         ${DIM}Turn commas into ' | ', add a leading and trailing pipe, then hand-type the |---| row.${NC}"
    echo ""
    echo -e "   9   20  ${YELLOW}f=i <Esc>...+f=..++f=...${NC}"
    echo -e "         ${DIM}f= jumps to the =, i <Esc> inserts a space before it; . repeats that edit,${NC}"
    echo -e "         ${DIM}padding each line until the = signs line up (skip already-aligned lines).${NC}"
    echo ""
    echo -e "  10   20  ${YELLOW}:v/^d/d<CR>:%norm 4xf(D<CR>${NC}"
    echo -e "         ${DIM}:v/^d/d deletes lines NOT starting with 'd'; :%norm runs keys on each survivor:${NC}"
    echo -e "         ${DIM}4x strips 'def ', f( jumps to '(', D deletes to end — leaving just the name.${NC}"
    echo ""
    echo -e "  11   27  ${YELLOW}:%!awk '{print \$2\"   \"\$1}'<CR>${NC}"
    echo -e "         ${DIM}:%! pipes the whole buffer through awk, which prints field 2 then field 1, swapped.${NC}"
    echo ""
    echo -e "  12    7  ${YELLOW}:v/./d<CR>${NC}"
    echo -e "         ${DIM}:v/./d deletes every line with no character at all — i.e. the blank lines.${NC}"
    echo ""
    echo -e "  13   24  ${YELLOW}:%s/.*/  \"&\",<CR>\$xo]<Esc>ggO[<Esc>${NC}"
    echo -e "         ${DIM}Wrap each line as '  \"line\",'; \$x removes the trailing comma on the last line;${NC}"
    echo -e "         ${DIM}o]<Esc> adds the closing bracket, ggO[<Esc> adds the opening one at the top.${NC}"
    echo ""
    echo -e "  14   16  ${YELLOW}:%s/^/0. <CR>gg<C-V>Gg<C-A>${NC}"
    echo -e "         ${DIM}Prefix every line with '0. '; select the 0 column with <C-V>, then g<C-A>${NC}"
    echo -e "         ${DIM}increments each selected number sequentially (1, 2, 3, ...).${NC}"
    echo ""
    echo -e "  15   25  ${YELLOW}:%s/ {\\\\|, /\\\\r  /g|%s/}//<CR>${NC}"
    echo -e "         ${DIM}Replace ' {' or ', ' (\\| = OR) with a newline + 2-space indent (\\r  ),${NC}"
    echo -e "         ${DIM}then a second :%s strips the leftover closing braces.${NC}"
    echo ""
    echo -e "  ${DIM}Notation: <CR>=Enter, <C-A>=Ctrl-A, <C-V>=Ctrl-V, <Esc>=Escape${NC}"
    echo -e "  ${DIM}These are PAR solutions — shorter solutions may exist!${NC}"
    echo ""
    echo -e "  ${DIM}Press any key to return...${NC}"
    read -rsn1
}

level_select() {
    local select_mode=${1:-normal}

    clear
    if [ "$select_mode" = "hard" ]; then
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo -e "${RED}  HARD MODE — SELECT LEVEL${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    else
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  SELECT LEVEL${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    fi
    echo ""

    for i in $(seq 1 15); do
        local info
        if [ "$select_mode" = "hard" ]; then
            info=$(setup_hard_level "$i" 2>/dev/null)
        else
            info=$(setup_level "$i" 2>/dev/null)
        fi
        local par=$(echo "$info" | cut -d'|' -f1)
        local desc=$(echo "$info" | cut -d'|' -f4)

        local status="  "
        local locked=""
        if [ "$select_mode" = "hard" ]; then
            # Check if normal level is completed (unlock requirement)
            if ! is_level_completed "$i"; then
                locked="${DIM}[LOCKED]${NC}"
            elif [ -f "$SCORE_FILE" ]; then
                local best=$(grep "^hard${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
                if [ -n "$best" ]; then
                    if [ "$best" -le "$par" ]; then
                        status="${GREEN}*${NC}"
                    else
                        status="${YELLOW}o${NC}"
                    fi
                fi
            fi
        else
            if [ -f "$SCORE_FILE" ]; then
                local best=$(grep "^level${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
                if [ -n "$best" ]; then
                    if [ "$best" -le "$par" ]; then
                        status="${GREEN}*${NC}"
                    else
                        status="${YELLOW}o${NC}"
                    fi
                fi
            fi
        fi

        if [ -n "$locked" ]; then
            printf "  %b %2d. ${DIM}%-40s${NC} %b\n" "  " "$i" "$desc" "$locked"
        else
            printf "  %b %2d. %-40s ${DIM}(par %d)${NC}\n" "$status" "$i" "$desc" "$par"
        fi
    done

    echo ""
    echo -e "  ${DIM}Enter level number (1-15) or [q] to go back:${NC} "
    read -r choice

    case "$choice" in
        [1-9]|1[0-5])
            if [ "$select_mode" = "hard" ] && ! is_level_completed "$choice"; then
                echo -e "  ${RED}Complete normal level $choice first to unlock!${NC}"
                sleep 2
                return
            fi
            local lvl=$choice
            while [ "$lvl" -le 15 ]; do
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
            ;;
        q|Q) return ;;
        *) echo "Invalid choice"; sleep 1 ;;
    esac
}

main_menu() {
    while true; do
        clear
        print_banner
        echo -e "  ${BOLD}[p]${NC} Play (sequential)    ${BOLD}[l]${NC} Level select"
        echo -e "  ${BOLD}[h]${NC} ${RED}Hard mode${NC}            ${BOLD}[s]${NC} Scoreboard"
        echo -e "  ${BOLD}[k]${NC} Solution key         ${BOLD}[r]${NC} Reset scores"
        echo -e "  ${BOLD}[q]${NC} Quit"
        echo ""
        echo -e "  ${DIM}Rules: Transform START into GOAL using vim.${NC}"
        echo -e "  ${DIM}Your keystrokes are counted. Beat par to earn *${NC}"
        echo -e "  ${DIM}Hard mode: same concept at 50-100x scale. Unlocked per level.${NC}"
        echo ""

        read -rsn1 choice
        case "$choice" in
            p|P)
                for i in $(seq 1 15); do
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
