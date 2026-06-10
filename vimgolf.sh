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

count_keystrokes() {
    local script_file="/tmp/vimgolf_keys_$$"
    local input_file="$1"
    local output_file="/tmp/vimgolf_output_$$"

    cp "$input_file" "$output_file"

    vim -u NONE -N -i NONE -W "$script_file" "$output_file" </dev/tty >/dev/tty 2>/dev/null

    local keystrokes=0
    if [ -f "$script_file" ]; then
        local total_bytes
        total_bytes=$(wc -c < "$script_file" | tr -d ' ')

        # Detect the save command at the end and subtract it
        local save_len=0
        local tail4
        tail4=$(tail -c 4 "$script_file" | xxd -p | tr -d '\n')
        local tail3
        tail3=$(tail -c 3 "$script_file" | xxd -p | tr -d '\n')
        local tail2
        tail2=$(tail -c 2 "$script_file" | xxd -p | tr -d '\n')

        if [[ "$tail4" == "3a77710a" || "$tail4" == "3a77710d" ]]; then
            save_len=4   # :wq<CR>
        elif [[ "$tail4" == "3a71210a" || "$tail4" == "3a71210d" ]]; then
            save_len=4   # :q!<CR>
        elif [[ "$tail3" == "3a780a" || "$tail3" == "3a780d" ]]; then
            save_len=3   # :x<CR>
        elif [[ "$tail3" == "3a770a" || "$tail3" == "3a770d" ]]; then
            save_len=3   # :w<CR>
        elif [[ "$tail2" == "5a5a" ]]; then
            save_len=2   # ZZ
        fi

        keystrokes=$((total_bytes - save_len))
        if [ $keystrokes -lt 0 ]; then
            keystrokes=0
        fi
    fi

    rm -f "$script_file"
    echo "$keystrokes|$output_file"
}

play_level() {
    local level=$1
    local level_info
    level_info=$(setup_level "$level") || { echo "Invalid level"; return 1; }

    local par=$(echo "$level_info" | cut -d'|' -f1)
    local hint1=$(echo "$level_info" | cut -d'|' -f2)
    local hint2=$(echo "$level_info" | cut -d'|' -f3)
    local desc=$(echo "$level_info" | cut -d'|' -f4)
    local start_file="$LEVEL_DIR/start_${level}.txt"
    local goal_file="$LEVEL_DIR/goal_${level}.txt"
    local hint_level=0

    while true; do
        clear
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}  Level $level: ${desc}${NC}"
        echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}  Par: $par keystrokes${NC}"
        echo ""

        # Show START and GOAL side by side if terminal is wide enough
        local cols=$(tput cols 2>/dev/null || echo 80)
        if [ "$cols" -ge 70 ]; then
            local start_lines goal_lines max_lines
            start_lines=$(wc -l < "$start_file")
            goal_lines=$(wc -l < "$goal_file")
            max_lines=$((start_lines > goal_lines ? start_lines : goal_lines))

            printf "  ${DIM}%-30s  %-30s${NC}\n" "START:" "GOAL:"
            printf "  ${DIM}%-30s  %-30s${NC}\n" "─────────────────────────────" "─────────────────────────────"

            for i in $(seq 1 $max_lines); do
                local sline gline
                sline=$(sed -n "${i}p" "$start_file")
                gline=$(sed -n "${i}p" "$goal_file")
                printf "  %-30s  ${GREEN}%-30s${NC}\n" "$sline" "$gline"
            done
        else
            echo -e "${DIM}  START:${NC}"
            echo -e "${DIM}  ─────${NC}"
            sed 's/^/    /' "$start_file"
            echo ""
            echo -e "${DIM}  GOAL:${NC}"
            echo -e "${DIM}  ─────${NC}"
            sed 's/^/    /' "$goal_file" | while IFS= read -r line; do echo -e "  ${GREEN}${line}${NC}"; done
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

            echo "level${level}:${keystrokes}:${par}" >> "$SCORE_FILE"
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
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  SCOREBOARD${NC}"
    echo -e "${BOLD}═══════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCORE_FILE" ]; then
        echo -e "  ${DIM}No scores yet. Play some levels!${NC}"
    else
        local total_strokes=0
        local total_par=0
        local levels_completed=0

        echo -e "  ${DIM}Level  Strokes  Par   Score${NC}"
        echo -e "  ${DIM}─────  ───────  ───   ─────${NC}"

        for i in $(seq 1 15); do
            local best=$(grep "^level${i}:" "$SCORE_FILE" | cut -d: -f2 | sort -n | head -1)
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
                printf "  %-6s %-8s %-5s %b\n" "$i" "$best" "$lpar" "$score_str"
                total_strokes=$((total_strokes + best))
                total_par=$((total_par + lpar))
                levels_completed=$((levels_completed + 1))
            fi
        done

        echo ""
        echo -e "  ${DIM}─────────────────────────────${NC}"
        local total_diff=$((total_strokes - total_par))
        local diff_str=""
        if [ $total_diff -lt 0 ]; then
            diff_str="${GREEN}${total_diff}${NC}"
        elif [ $total_diff -eq 0 ]; then
            diff_str="${CYAN}EVEN${NC}"
        else
            diff_str="${YELLOW}+${total_diff}${NC}"
        fi
        printf "  %-6s %-8s %-5s %b\n" "Total" "$total_strokes" "$total_par" "$diff_str"
        echo -e "  ${DIM}Levels completed: ${levels_completed}/15${NC}"
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
    echo -e "   2   12  ${YELLOW}:%s/foo/bar<CR>${NC}"
    echo -e "   3    8  ${YELLOW}:g/^/m0<CR>${NC}"
    echo -e "   4   11  ${YELLOW}:%s/.*/\"&\"<CR>${NC}"
    echo -e "   5   16  ${YELLOW}:%s/\\\\u/_\\\\l&/g<CR>${NC}  (only single uppercase boundaries)"
    echo -e "   6    7  ${YELLOW}:sor u<CR>${NC}"
    echo -e "   7   10  ${YELLOW}qa<C-A>l<C-A>+q4@a${NC}"
    echo -e "   8   30  ${YELLOW}:%s/,/ | /g<CR> :%s/^/| <CR> :%s/\$/ |<CR> + manual sep${NC}"
    echo -e "   9   20  ${YELLOW}f=i <Esc>...+f=..++f=...${NC}  (. repeats space insert)"
    echo -e "  10   20  ${YELLOW}:v/^d/d<CR>:%norm 4xf(D<CR>${NC}"
    echo -e "  11   27  ${YELLOW}:%!awk '{print \$2\"   \"\$1}'<CR>${NC}"
    echo -e "  12    7  ${YELLOW}:v/./d<CR>${NC}"
    echo -e "  13   24  ${YELLOW}:%s/.*/  \"&\",<CR>\$xo]<Esc>ggO[<Esc>${NC}"
    echo -e "  14   16  ${YELLOW}:%s/^/0. <CR>gg<C-V>Gg<C-A>${NC}  (g<C-A> = sequential increment)"
    echo -e "  15   25  ${YELLOW}:%s/ {\\\\|, /\\\\r  /g|%s/}//<CR>${NC}"
    echo ""
    echo -e "  ${DIM}Notation: <CR>=Enter, <C-A>=Ctrl-A, <C-V>=Ctrl-V, <Esc>=Escape${NC}"
    echo -e "  ${DIM}These are PAR solutions — shorter solutions may exist!${NC}"
    echo ""
    echo -e "  ${DIM}Press any key to return...${NC}"
    read -rsn1
}

level_select() {
    clear
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  SELECT LEVEL${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════${NC}"
    echo ""

    for i in $(seq 1 15); do
        local info
        info=$(setup_level "$i" 2>/dev/null)
        local par=$(echo "$info" | cut -d'|' -f1)
        local desc
        desc=$(echo "$info" | rev | cut -d'|' -f1 | rev)

        local status="  "
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

        printf "  %b %2d. %-40s ${DIM}(par %d)${NC}\n" "$status" "$i" "$desc" "$par"
    done

    echo ""
    echo -e "  ${DIM}Enter level number (1-15) or [q] to go back:${NC} "
    read -r choice

    case "$choice" in
        [1-9]|1[0-5])
            local lvl=$choice
            while [ "$lvl" -le 15 ]; do
                play_level "$lvl"
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
        echo -e "  ${BOLD}[s]${NC} Scoreboard           ${BOLD}[k]${NC} Solution key"
        echo -e "  ${BOLD}[r]${NC} Reset scores         ${BOLD}[q]${NC} Quit"
        echo ""
        echo -e "  ${DIM}Rules: Transform START into GOAL using vim.${NC}"
        echo -e "  ${DIM}Your keystrokes are counted. Beat par to earn *${NC}"
        echo ""

        read -rsn1 choice
        case "$choice" in
            p|P)
                for i in $(seq 1 15); do
                    play_level "$i"
                    local ret=$?
                    [ $ret -eq 1 ] && break
                    [ $ret -eq 3 ] && break
                done
                ;;
            l|L) level_select ;;
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
