/*
    This file is part of ForceDirected.

    ForceDirected is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ForceDirected is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ForceDirected.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __DrawView_h
#define __DrawView_h

#include <AppKit/AppKit.h>
#include <graphviz/gvc.h>

//for compatibility with some graphviz's
//installations (ubuntu's lucid, for example)
#ifndef ND_coord
#define ND_coord ND_coord_i
#endif

@interface DrawView : NSView
{
  NSPoint move; //for use in mouse(down|dragged)

  id springSlider;
  id chargeSlider;
  id dampingSlider;

  //for screen transformation
  NSPoint translate;
  double ratio;

  //to keep graph info
  GVC_t *gvc;
  graph_t *graph;
}
- (NSAffineTransform*) transform;
- (void) setGVC: (GVC_t *) g;
- (void) setGraph: (graph_t *) g;
- (void) reset: (id) sender;
- (double) applyForceDirectedWithSpring: (float) spring
                              andCharge: (float) charge
                             andDamping: (float) damping;
- (void) exportPositions;
@end

#endif
