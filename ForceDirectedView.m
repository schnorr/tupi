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

- (void) setGraph: (NSDictionary*)g withConditionLock: (NSConditionLock *)l;
{
  graph = g;
  lock = l;
}

- (void) drawRect: (NSRect)frame
{
  if (!graph) return;

  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);

  NSAffineTransform* transform = [self transform];
  [transform concat]; 

  [[NSColor redColor] set];

  [lock lock];
  NSEnumerator *en = [graph objectEnumerator];
  GraphNode *node;
  while ((node = [en nextObject])){
    NSPoint pos = [node position];
    NSRect r = NSMakeRect (pos.x, pos.y, 10, 10);
    NSBezierPath *p = [NSBezierPath bezierPathWithRect: r];
    [p stroke];

    NSEnumerator *connectedEn = [[node connectedNodes] objectEnumerator];
    GraphNode *connectedNode;
    while ((connectedNode = [connectedEn nextObject])){
      NSPoint connectedNodePosition = [connectedNode position];
      NSPoint src, dst;
      src.x = pos.x+10/2;
      src.y = pos.y+10/2;
      dst.x = connectedNodePosition.x+10/2;
      dst.y = connectedNodePosition.y+10/2;
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint: src];
      [path lineToPoint: dst];
      [path stroke];
    }
  }


  [tree drawCellsWithLevel:0];
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

- (void) setTree: (FDTree*) t
{
  tree = t;
}
@end
