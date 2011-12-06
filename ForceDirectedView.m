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
#include "ForceDirectedView.h"
#include "NSPointFunctions.h"

@implementation ForceDirectedView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  return self;
}

- (void) setGraph: (Agraph_t *)g withConditionLock: (NSConditionLock*)l
{
  graph = g;
  lock = l;
}

- (void) drawRect: (NSRect)frame
{
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);

  NSAffineTransform* transform = [self transform];
  [transform concat]; 

  NSLog (@"%s waiting for lock", __FUNCTION__);
  [lock lock];
  NSLog (@"%s locked", __FUNCTION__);
  if (graph){
    [[NSColor redColor] set];
    Agnode_t *node = agfstnode(graph);
    while (node){
      NSRect r = NSMakeRect (ND_coord(node).x,ND_coord(node).y,10,10);
      NSRectFill(r);
      // NSLog (@"drawing %s", node->name);


      Agedge_t *edge = agfstedge (graph, node);
      while (edge){
        NSPoint src, dst;
        src.x = ND_coord(edge->head).x+10/2;
        src.y = ND_coord(edge->head).y+10/2;
        dst.x = ND_coord(edge->tail).x+10/2;
        dst.y = ND_coord(edge->tail).y+10/2;
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint: src];
        [path lineToPoint: dst];
        [path stroke];

        edge = agnxtedge (graph, edge, node);
      }

      node = agnxtnode(graph, node);
    }
  }
  NSLog (@"%s unlock", __FUNCTION__);
  [lock unlock];

  [transform invert];
  [transform concat];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}
@end
