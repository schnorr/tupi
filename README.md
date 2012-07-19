Tupi
====

Tupi is an interactive graph placement tool that uses the Barnes-Hut
algorithm to define nodes position. The program is released under the
GPLv3 license, and is inspired by the
[GraphStream-Project](http://graphstream-project.org/), a very
powerfull library to deal with dynamic graphs. The algorithm with
complexity __nlogn__ uses the Hooke Attraction's Law when two nodes
are connected and the Coulomb Repulsion's Law that considers all
nodes.

Dependencies
------------

Tupi needs a recent [GNUstep environment](http://gnustep.org)
(gnustep-make, gnustep-base, gnustep-gui), better if compiled with
[clang](http://clang.llvm.org/), [GNUstep
Renaissance](http://www.gnustep.it/Renaissance/), and the [Graphviz
library](http://www.graphviz.org/) (used for parsing dot files).

Clone and Compilation
---------------------

No secrets here, just do:

    $ git clone git://github.com/schnorr/tupi.git
    $ cd tupi
    $ make
    $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/Source/Tupi.framework/Versions/Current
    $ ./Source/tupi.app/tupi

Install
-------

You can optionally install Tupi:

    $ make install # you'll probably need root privileges for this

or install in your user directory (such as $HOME/GNUstep/...)

    $ make install GNUSTEP_INSTALLATION_DOMAIN=USER

Examples
--------

Tupi uses dot files (in the graphviz's dot file format) as
input. There are some examples in the `Examples` directory. If you
want to give a try, without installing the tupi tool, type:

    $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/Source/Tupi.framework/Versions/Current
    $ ./Source/tupi.app/tupi Examples/teste.dot

And, if you installed the tool, just type:

    $ tupi your_graphviz_file.dot

Interactions
------------

Just after being launched with a valid dot file, Tupi will open a
window so you can visually play with the graph. You can:

* click and drag, changing the portion of the graph that you see
* use the mouse wheel, zooming in and out to see details
* move a node by clicking and dragging it
* right click over a node removes it
* shake the graph by using the "Shake" option in the menu or ALT+S
* reset the graph by using the "Reset" option in the menu or ALT+R
* show the barnes-hut cells by using the option in the menu or ALT+C

Nodes are expected to stop moving after the graph achieves a stable
placement (defined by the sum of energy of all nodes when they move).

Roadmap
-------

* Export the resulting layout in a vector format (such as SVG)
* Allow the user to change the several parameters of the placement algorithm
  to fine-tune the algorithm according to the graph
* Increase the scalability of the algorithm implementation
* Create a short documentation inside the application itself
