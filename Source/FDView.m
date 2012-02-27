/*
    This file is part of Tupi.

    Tupi is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Tupi is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Tupi.  If not, see <http://www.gnu.org/licenses/>.
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
  provider = nil;
  highlighted = nil;
  return self;
}

- (void) setProvider: (Tupi *) p
{
  provider = p;
}

- (void) setLayout: (Layout *) l
{
  layout = l;
}

- (void) drawRect: (NSRect)frame
{
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);

  NSAffineTransform* transform = [self transform];
  [transform concat];


  [[NSColor blackColor] set];
  [[NSBezierPath bezierPathWithRect: NSMakeRect(-10, -10, 20, 20)] fill];


  NSRect rootCellBB = [provider boundingBox];
  rootCellBB.origin = LMSMultiplyPoint (rootCellBB.origin, 100);
  rootCellBB.size.width *= 100;
  rootCellBB.size.height *= 100;
  NSBezierPath *bbpath = [NSBezierPath bezierPathWithRect: rootCellBB];
  [[NSColor greenColor] set];
  [bbpath stroke];


  NSEnumerator *en = [provider graphNodesEnumerator];
  GraphNode *node;
  while ((node = [en nextObject])){
    NSPoint pos = [node position];


    NSPoint poss = NSMakePoint (pos.x*100, pos.y*100);
    NSRect bb = NSMakeRect (poss.x - 5, poss.y - 5, 20, 20);
    [node setBoundingBox: bb];
    if ([node highlighted]){
      [[NSColor redColor] set];
    }else{
      [[NSColor blueColor] set];
    }
    [[NSBezierPath bezierPathWithRect: bb] fill];
    [[node name] drawAtPoint:NSMakePoint(poss.x+15, poss.y+15)
              withAttributes:nil];

    // draw connections
    NSEnumerator *en0 = [[node connectedNodes] objectEnumerator];
    GraphNode *gn0;
    while ((gn0 = [en0 nextObject])){
      NSPoint p0 = [gn0 position];
      NSPoint p0s = NSMakePoint (p0.x*100, p0.y*100);
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint: poss];
      [path lineToPoint: p0s];
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
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
  NSAffineTransform *t = [self transform];
  [t invert];
  mouse = [t transformPoint: mouse];
  NSEnumerator *en = [provider graphNodesEnumerator];
  GraphNode *node;
  if (highlighted){
    [highlighted setHighlighted: NO];
    [layout freezeNode: highlighted frozen: NO];
    highlighted = nil;
  }
  while ((node = [en nextObject])){
    if (NSPointInRect (mouse, [node boundingBox])){
      highlighted = node;
      [highlighted setHighlighted: YES];
      [layout freezeNode: highlighted frozen: YES];
      break;
    }
  }
  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  if (highlighted == nil){
    [super mouseDown: event];
  }
}

- (void) mouseDragged:(NSEvent *)event
{
  if (highlighted == nil){
    [super mouseDragged: event];
  }else{
    //move the node
    NSPoint mouse = [self convertPoint:[event locationInWindow] fromView:nil];
    NSAffineTransform *t = [self transform];
    [t invert];
    mouse = [t transformPoint: mouse];
    mouse.x /= 100;
    mouse.y /= 100;
    [layout moveNode: highlighted toLocation: mouse];
    [self setNeedsDisplay: YES];
  }
}

- (void) mouseUp:(NSEvent *)event
{
  if (highlighted){
    [highlighted setHighlighted: NO];
    [layout freezeNode: highlighted frozen: NO];
    highlighted = nil;
    [self setNeedsDisplay: YES];
  }
  [super mouseUp: event];
}
@end
