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
#include "FDView.h"
#include "NSPointFunctions.h"
#include "GraphNode.h"
#include "Particle.h"

extern double gettime();

@implementation FDView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  return self;
}

- (void) setProvider: (id) p
{
  provider = p;
}

- (void) drawRect: (NSRect)frame
{
  double t1 = gettime();

  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);

  NSAffineTransform* transform = [self transform];
  [transform concat];

  NSRect rootCellBB = [provider boundingBox];
  rootCellBB.origin = LMSMultiplyPoint (rootCellBB.origin, 100);
  rootCellBB.size.width *= 100;
  rootCellBB.size.height *= 100;
  NSBezierPath *bbpath = [NSBezierPath bezierPathWithRect: rootCellBB];
  [[NSColor greenColor] set];
  [bbpath stroke];

  NSEnumerator *en = [provider graphNodesEnumerator];
  GraphNode *node;
  int i = 0;

  while ((node = [en nextObject])){
    NSPoint pos = [node position];
    NSPoint vpos = NSMakePoint (pos.x*100, pos.y*100);
    NSRect r = NSMakeRect (vpos.x, vpos.y, 10,10);
    NSBezierPath *p = [NSBezierPath bezierPathWithRect: r];
    i = (i+1)%2;
    if (i == 0){
      [[NSColor blueColor] set];
    }else{
      [[NSColor redColor] set];  
    }

    [p fill];
    [[node name] drawAtPoint:vpos 
              withAttributes:nil];

    //draw connections
    NSEnumerator *en0 = [[node connectedNodes] objectEnumerator];
    GraphNode *gn0;
    while ((gn0 = [en0 nextObject])){
      NSPoint p0 = [gn0 position];
      NSPoint vp0 = NSMakePoint (p0.x*100, p0.y*100);
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint: vpos];
      [path lineToPoint: vp0];
      [path stroke];
    }
  }

  en = [provider particlesEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    //draw the cell
    NSRect cellRect = [[[p cell] space] bb];
    cellRect.origin = LMSMultiplyPoint (cellRect.origin, 100);
    cellRect.size.width *= 100;
    cellRect.size.height *= 100;
    NSBezierPath *p2 = [NSBezierPath bezierPathWithRect: cellRect];
    [[NSColor yellowColor] set];
    [p2 stroke];
  }

  [transform invert];
  [transform concat];

  double t2 = gettime();
  // NSLog (@"drawing duration = %f frame = %@",
  //        t2-t1,
  //        NSStringFromRect(frame));
}
@end
