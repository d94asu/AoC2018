#!/bin/bash

PROBLEM_NAMES=(\
"Day 1: Chronal Calibration" \
"Day 2: Inventory Management System" \
"Day 3: No Matter How You Slice It" \
"Day 4: Repose Record" \
"Day 5: Alchemical Reduction" \
"Day 6: Chronal Coordinates" \
"Day 7: The Sum of Its Parts" \
"Day 8: Memory Maneuver" \
"Day 9: Marble Mania" \
"Day 10: The Stars Align" \
"Day 11: Chronal Charge" \
"Day 12: Subterranean Sustainability" \
"Day 13: Mine Cart Madness" \
"Day 14: Chocolate Charts"\
)


for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14
do

mkdir -p $i/magnus/
NAME=${PROBLEM_NAMES[$i-1]}
cat << EOF > $i/magnus/README.md
# ${PROBLEM_NAMES[$i-1]}

- [Problem](https://adventofcode.com/2018/day/$i)
- [Solution](https://github.com/kyeett/adventofcode/tree/master/2018/day-$i) by Magnus

![Magnus](https://avatars1.githubusercontent.com/u/737646?s=100&u=0076f6745a279a959157b3c57d325a11340f70c6&v=4)
EOF

done