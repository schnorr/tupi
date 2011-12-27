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
#include "Particle.h"

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
  [[NSColor whiteColor] set];
  NSRectFill([self bounds]);

  NSAffineTransform* transform = [self transform];
  [transform concat];


  NSEnumerator *en = [provider nodesEnumerator];
  Particle *node;
  int i = 0;
  while ((node = [en nextObject])){
    NSPoint pos = [node position];
    NSPoint vpos = NSMakePoint (pos.x*100, pos.y*100);
    NSRect r = NSMakeRect (vpos.x*100, vpos.y*100, 1,1);
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
  }


  [transform invert];
  [transform concat];
}
@end
