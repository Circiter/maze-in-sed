# maze-in-sed
Maze generator and solver in sed.

An attempt to reimplement [this thing](https://gist.github.com/xsot/99a8a4304660916455ba2c2c774e623a).

Usage:
    cat sample_maze | ./with-wavefront.sed # To solve.
    cat sample_maze | ./fast-and-dirty.sed # Solve, faster.
    echo | ./cellular-generator.sed # Incomplete.
